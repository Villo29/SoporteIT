import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../create_report_page.dart';
import '../../../services/auth_service.dart';

class ReportsTab extends StatefulWidget {
  final Function(String) onOpenTicketChat;
  final Function onCreateReport;

  const ReportsTab({
    super.key,
    required this.onOpenTicketChat,
    required this.onCreateReport,
  });

  @override
  _ReportsTabState createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoadingReports = true;
  
  // Chat-related variables
  bool _isChatVisible = false;
  String? _selectedTicketId;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  WebSocketChannel? _webSocketChannel;
  Map<String, dynamic>? _chatRoom;
  bool _isLoadingMessages = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadUserReports();
  }

  Future<void> _loadUserReports() async {
    try {
      setState(() {
        _isLoadingReports = true;
      });

      final token = await AuthService.getCurrentToken();
      if (token == null) {
        setState(() {
          _isLoadingReports = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> reportsData = json.decode(response.body);
        setState(() {
          _reports = reportsData
              .map((report) => _mapReportFromApi(report))
              .toList();
          _isLoadingReports = false;
        });
      } else {
        setState(() {
          _isLoadingReports = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingReports = false;
      });
    }
  }

  Map<String, dynamic> _mapReportFromApi(Map<String, dynamic> apiReport) {
    return {
      'id': 'TK-${apiReport['id']}',
      'title': apiReport['titulo'] ?? 'Sin título',
      'description': apiReport['descripcion_detallada'] ?? 'Sin descripción',
      'status': _mapStatusFromApi(apiReport['estado'] ?? 'abierto'),
      'date': _formatDateFromApi(apiReport['created_at'] ?? ''),
      'priority': _mapPriorityFromApi(apiReport['prioridad'] ?? 'media'),
    };
  }

  String _mapStatusFromApi(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'abierto':
        return 'pending';
      case 'en_proceso':
      case 'procesando':
        return 'in_progress';
      case 'cerrado':
      case 'resuelto':
        return 'completed';
      default:
        return 'pending';
    }
  }

  String _mapPriorityFromApi(String apiPriority) {
    switch (apiPriority.toLowerCase()) {
      case 'baja':
      case 'bajo':
        return 'low';
      case 'media':
      case 'medio':
        return 'medium';
      case 'alta':
      case 'alto':
        return 'high';
      case 'critica':
      case 'crítica':
        return 'high';
      default:
        return 'medium';
    }
  }

  String _formatDateFromApi(String isoDate) {
    try {
      final DateTime reportDate = DateTime.parse(isoDate);
      return '${reportDate.day.toString().padLeft(2, '0')}-${reportDate.month.toString().padLeft(2, '0')}-${reportDate.year}';
    } catch (e) {
      return 'Sin fecha';
    }
  }

  @override
  void dispose() {
    _webSocketChannel?.sink.close();
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _openChatForTicket(String ticketId) async {
    setState(() {
      _selectedTicketId = ticketId;
      _isChatVisible = true;
      _isLoadingMessages = true;
      _messages = [];
    });

    await _loadChatRoom(ticketId);
  }

  void _closeChat() {
    setState(() {
      _isChatVisible = false;
      _selectedTicketId = null;
      _messages = [];
    });
    _webSocketChannel?.sink.close();
    _webSocketChannel = null;
  }

  Future<void> _loadChatRoom(String ticketId) async {
    try {
      final token = await AuthService.getCurrentToken();
      if (token == null) {
        throw Exception('No se encontró el token de autorización');
      }
      final ticketNumericId = ticketId.replaceFirst('TK-', '');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> chatRooms = jsonDecode(response.body);

        Map<String, dynamic>? matchingRoom;
        for (var room in chatRooms) {
          if (room['ticket_id'].toString() == ticketNumericId) {
            matchingRoom = room;
            break;
          }
        }

        if (matchingRoom != null) {
          setState(() {
            _chatRoom = matchingRoom;
          });

          _loadChatMessages(token);
        } else {
          throw Exception('No se encontró una sala de chat para este ticket');
        }
      } else {
        throw Exception('Error al cargar las salas de chat');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la sala de chat.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadChatMessages(String token) async {
    try {
      if (_chatRoom == null) {
        throw Exception('No se ha cargado la sala de chat');
      }

      final roomId = _chatRoom!['id'];

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
        } else if (responseData is Map && responseData.containsKey('messages')) {
          messagesData = responseData['messages'];
        } else if (responseData is Map && responseData.containsKey('data')) {
          messagesData = responseData['data'];
        } else {
          throw Exception('Estructura de respuesta no reconocida');
        }

        setState(() {
          _messages = messagesData
              .map((message) => _mapMessageFromApi(message))
              .toList();
          _isLoadingMessages = false;
        });

        _connectWebSocket(token);
        _scrollChatToBottom();
      } else {
        throw Exception('Error al cargar los mensajes');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el chat.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _mapMessageFromApi(Map<String, dynamic> apiMessage) {
    return {
      'id': apiMessage['id'].toString(),
      'sender': apiMessage['sender_role'] == 'empleado' ? 'user' : 'support',
      'content': apiMessage['content'],
      'timestamp': _formatTimestamp(apiMessage['created_at']),
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
    if (_chatRoom != null) {
      try {
        final roomId = _chatRoom!['id'];
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

                  _scrollChatToBottom();
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

  void _scrollChatToBottom() {
    if (_chatScrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageContent = _messageController.text.trim();
    _messageController.clear();

    if (_chatRoom == null || !_isConnected) {
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
        'room_id': _chatRoom!['id'],
      };
      final jsonMessage = jsonEncode(messageData);

      _webSocketChannel?.sink.add(jsonMessage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar mensaje.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 32,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Reportes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isLoadingReports) ...[
                        SizedBox(width: 12),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1C9985),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateReportPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 4),
                        Text('Nuevo Reporte'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingReports
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1C9985),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando reportes...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _reports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No tienes reportes aún',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Crea tu primer reporte usando el botón "Nuevo Reporte"',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUserReports,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return _buildReportCard(report, context);
                        },
                      ),
                    ),
            ),
            // Chat panel at the bottom
            if (_isChatVisible) _buildChatPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _openChatForTicket(report['id']);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['id'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          report['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  _buildStatusBadge(report['status']),
                ],
              ),
              SizedBox(height: 12),
              Text(
                report['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    report['date'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  _buildPriorityBadge(report['priority']),
                ],
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nota por ver el chat en vivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'completed':
          return Colors.green;
        case 'in_progress':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    IconData getStatusIcon(String status) {
      switch (status) {
        case 'pending':
          return Icons.access_time;
        case 'completed':
          return Icons.check_circle;
        case 'in_progress':
          return Icons.warning;
        default:
          return Icons.access_time;
      }
    }

    String getStatusText(String status) {
      switch (status) {
        case 'pending':
          return 'Pendiente';
        case 'completed':
          return 'Completado';
        case 'in_progress':
          return 'En Progreso';
        default:
          return 'Pendiente';
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getStatusColor(status), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getStatusIcon(status), size: 12, color: getStatusColor(status)),
          SizedBox(width: 4),
          Text(
            getStatusText(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color getPriorityColor(String priority) {
      switch (priority) {
        case 'high':
          return Colors.red;
        case 'medium':
          return Colors.orange;
        case 'low':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    String getPriorityText(String priority) {
      switch (priority) {
        case 'high':
          return 'Alta';
        case 'medium':
          return 'Media';
        case 'low':
          return 'Baja';
        default:
          return 'Media';
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getPriorityColor(priority), width: 1),
      ),
      child: Text(
        getPriorityText(priority),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: getPriorityColor(priority),
        ),
      ),
    );
  }

  Widget _buildChatPanel() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Chat header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Chat - Ticket $_selectedTicketId',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isConnected
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
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
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: _closeChat,
                ),
              ],
            ),
          ),
          // Messages list
          Expanded(
            child: _isLoadingMessages
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'No hay mensajes aún',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _chatScrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildChatMessage(message);
                        },
                      ),
          ),
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
      child: Row(
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
    );
  }
}
