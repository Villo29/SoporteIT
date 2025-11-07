import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/auth_service.dart';

class TicketChatPage extends StatefulWidget {
  final String ticketId;

  const TicketChatPage({super.key, required this.ticketId});

  @override
  _TicketChatPageState createState() => _TicketChatPageState();
}

class _TicketChatPageState extends State<TicketChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  WebSocketChannel? _webSocketChannel;
  Map<String, dynamic>? _room;
  Map<String, dynamic>? _ticketData;
  bool _isLoadingMessages = true;
  bool _isLoadingTicket = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadTicketData();
    _loadChatRoom();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _loadTicketData() async {
    try {
      setState(() {
        _isLoadingTicket = true;
      });

      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No se encontró el token de autorización');
      }

      // Extraer el ID numérico del ticket (TK-9 -> 9)
      final ticketNumericId = widget.ticketId.replaceFirst('TK-', '');
      print('Cargando ticket ID: $ticketNumericId');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/tickets/$ticketNumericId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          _ticketData = responseData;
          _isLoadingTicket = false;
        });

      } else {
        throw Exception(
          'Error al cargar la información del ticket - Status: ${response.statusCode}',
        );
      }
    } catch (e) {

      setState(() {
        _isLoadingTicket = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar el ticket. Por favor intenta de nuevo.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadChatRoom() async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No se encontró el token de autorización');
      }
      final ticketNumericId = widget.ticketId.replaceFirst('TK-', '');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> chatRooms = jsonDecode(response.body);

        // Buscar la sala que corresponde a nuestro ticket
        Map<String, dynamic>? matchingRoom;
        for (var room in chatRooms) {
          if (room['ticket_id'].toString() == ticketNumericId) {
            matchingRoom = room;
            break;
          }
        }

        if (matchingRoom != null) {
          setState(() {
            _room = matchingRoom;
          });

          _loadChatMessages();
        } else {
          throw Exception('No se encontró una sala de chat para este ticket');
        }
      } else {
        throw Exception(
          'Error al cargar las salas de chat - Status: ${response.statusCode}',
        );
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar la sala de chat. Por favor intenta de nuevo.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadChatMessages() async {
    try {
      setState(() {
        _isLoadingMessages = true;
      });

      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No se encontró el token de autorización');
      }

      // Verificar que tenemos la sala de chat
      if (_room == null) {
        throw Exception('No se ha cargado la sala de chat');
      }

      // Usar el room_id que ya obtuvimos
      final roomId = _room!['id'];

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/chats/$roomId/messages?limit=50'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        List<dynamic> messagesData;

        if (responseData is List) {
          messagesData = responseData;
        } else if (responseData is Map &&
            responseData.containsKey('messages')) {
          messagesData = responseData['messages'];
        } else if (responseData is Map && responseData.containsKey('data')) {
          messagesData = responseData['data'];
        } else {
          throw Exception(
            'Estructura de respuesta no reconocida: ${responseData.keys}',
          );
        }

        setState(() {
          _messages = messagesData
              .map((message) => _mapMessageFromApi(message))
              .toList();
          _isLoadingMessages = false;
        });

        _connectWebSocket(token);

        _scrollToBottom();
      } else {
        throw Exception(
          'Error al cargar los mensajes - Status: ${response.statusCode}',
        );
      }
    } catch (e) {

      setState(() {
        _isLoadingMessages = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar el chat. Por favor intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _mapMessageFromApi(Map<String, dynamic> apiMessage) {
    return {
      'id': apiMessage['id'].toString(),
      'sender': apiMessage['sender_role'] == 'empleado' ? 'user' : 'support',
      'content': apiMessage['content'],
      'timestamp': _formatTimestamp(apiMessage['created_at']),
      'type': 'message',
    };
  }

  String _formatTimestamp(String isoDate) {
    try {
      final DateTime messageDate = DateTime.parse(isoDate);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(messageDate);

      if (difference.inDays > 0) {
        return '${messageDate.day}/${messageDate.month} ${messageDate.hour.toString().padLeft(2, '0')}:${messageDate.minute.toString().padLeft(2, '0')}';
      } else {
        return '${messageDate.hour.toString().padLeft(2, '0')}:${messageDate.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return 'Error de fecha';
    }
  }

  void _connectWebSocket(String token) {
    if (_room != null) {
      try {
        final roomId = _room!['id'];
        final wsUrl = 'ws://127.0.0.1:8000/chats/ws/$roomId?token=$token';

        _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

        setState(() {
          _isConnected = true;
        });
        _webSocketChannel!.stream.listen(
          (data) {
            try {
              final messageData = jsonDecode(data);

              if (messageData['type'] == 'message') {
                final newMessage = _mapMessageFromApi(messageData);

                if (mounted) {
                  setState(() {
                    _messages.add(newMessage);
                  });

                  _scrollToBottom();
                }
              }
            } catch (e) {
              print('Error al procesar mensaje WebSocket: $e');
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _isConnected = false;
              });
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _isConnected = false;
              });
            }
          },
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _webSocketChannel?.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageContent = _messageController.text.trim();
    _messageController.clear();

    if (_room == null || !_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No hay conexión al chat.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final messageData = {
        'type': 'message',
        'content': messageContent,
        'room_id': _room!['id'],
      };
      final jsonMessage = jsonEncode(messageData);

      _webSocketChannel?.sink.add(jsonMessage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar mensaje. Por favor intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('Ticket #${widget.ticketId}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'En Progreso',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isConnected
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        _isConnected ? 'En línea' : 'Desconectado',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Información del ticket
          _buildTicketInfo(),
          SizedBox(height: 8),

          // Lista de mensajes
          Expanded(
            child: _isLoadingMessages
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando conversación...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessage(message);
                    },
                  ),
          ),

          // Input de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTicketInfo() {
    if (_isLoadingTicket) {
      return Card(
        margin: EdgeInsets.all(16),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_ticketData == null) {
      return Card(
        margin: EdgeInsets.all(16),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Error al cargar la información del ticket',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final priority = _ticketData!['prioridad']?.toString() ?? 'Media';
    final title = _ticketData!['titulo']?.toString() ?? 'Sin título';
    final description =
        _ticketData!['descripcion_detallada']?.toString() ?? 'Sin descripción';

    String formattedDate = 'Fecha desconocida';
    if (_ticketData!['created_at'] != null) {
      try {
        final createdAt = DateTime.parse(_ticketData!['created_at']);
        final now = DateTime.now();
        final difference = now.difference(createdAt);

        if (difference.inDays > 0) {
          formattedDate =
              'Creado: Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
        } else if (difference.inHours > 0) {
          formattedDate =
              'Creado: Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
        } else {
          formattedDate =
              'Creado: Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
        }
      } catch (e) {
        formattedDate = 'Fecha inválida';
      }
    }

    // Configurar colores según prioridad
    Color priorityColor = Colors.grey;
    if (priority.toLowerCase() == 'alta' || priority.toLowerCase() == 'high') {
      priorityColor = Colors.red;
    } else if (priority.toLowerCase() == 'media' ||
        priority.toLowerCase() == 'medium') {
      priorityColor = Colors.orange;
    } else if (priority.toLowerCase() == 'baja' ||
        priority.toLowerCase() == 'low') {
      priorityColor = Colors.green;
    }

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: priorityColor),
                  ),
                  child: Text(
                    '${priority.toUpperCase()} PRIORIDAD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    if (message['type'] == 'status_update') {
      return _buildStatusUpdate(message);
    }

    return _buildChatMessage(message);
  }

  Widget _buildStatusUpdate(Map<String, dynamic> message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${message['content']} • ${message['timestamp']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent, color: Colors.white, size: 16),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message['content'],
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message['timestamp'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Tiempo de respuesta promedio: 15 minutos',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
