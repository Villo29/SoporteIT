import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../services/auth_service.dart';
import 'voucher_print_page.dart';

class TicketDetailPage extends StatefulWidget {
  const TicketDetailPage({
    super.key,
    required this.ticket,
    required this.onUpdateTicket,
  });

  final Map<String, dynamic> ticket;
  final Function(Map<String, dynamic>) onUpdateTicket;

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  bool isEditing = false;
  bool isInternalNote = false;
  final TextEditingController _replyCtrl = TextEditingController();

  late List<Map<String, dynamic>> messages;
  Map<String, dynamic>? ticketData;
  Map<String, dynamic>? perfilData;
  bool isLoadingTicket = false;
  
  // Chat-related state variables
  Map<String, dynamic>? _room;
  WebSocketChannel? _webSocketChannel;
  bool _isLoadingMessages = false;
  bool _isConnected = false;

  Future<void> _loadTicketDetails() async {
    if (widget.ticket['id'] == null) return;

    setState(() => isLoadingTicket = true);

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final ticketId = widget.ticket['id'];

      // Primero obtener los datos básicos del ticket
      final ticketResponse = await http.get(
        Uri.parse('http://127.0.0.1:8000/tickets/$ticketId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (ticketResponse.statusCode != 200) {
        throw Exception(
          'Error ${ticketResponse.statusCode}: ${ticketResponse.body}',
        );
      }

      final ticketBasicData = json.decode(ticketResponse.body);
      final empleadoId =
          ticketBasicData['id_empleado'] ?? widget.ticket['employeeId'];

      Map<String, dynamic>? empleadoPerfilData;
      if (empleadoId != null) {
        try {
          final empleadoResponse = await http.get(
            Uri.parse(
              'http://127.0.0.1:8000/empleados/$empleadoId/ticket/$ticketId',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (empleadoResponse.statusCode == 200) {
            final empleadoData = json.decode(empleadoResponse.body);

            if (empleadoData.containsKey('perfil')) {
              empleadoPerfilData = empleadoData['perfil'];
            }
          } else {}
        } catch (e) {}
      }

      setState(() {
        ticketData = ticketBasicData;
        perfilData = empleadoPerfilData;

        if (perfilData != null) {
        } else {}
      });
      _updateMessagesWithApiData();

      // Load chat room and messages after loading ticket details
      await _loadChatRoom();

      if (ticketBasicData['estado'] == 'abierto') {
        _autoChangeToInProgress();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar detalles del ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isLoadingTicket = false);
    }
  }

  Future<void> _autoChangeToInProgress() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final ticketId =
          ticketData?['id']?.toString() ?? widget.ticket['id']?.toString();
      if (ticketId == null) return;

      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/tickets/$ticketId/estado'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'estado': 'en_proceso'}),
      );

      if (response.statusCode == 200) {
        // Actualizar los datos locales
        setState(() {
          if (ticketData != null) {
            ticketData!['estado'] = 'en_proceso';
          }
          widget.ticket['status'] = 'en_proceso';
        });
      }
    } catch (e) {}
  }

  String get ticketTitle =>
      ticketData?['titulo'] ?? widget.ticket['title'] ?? 'Ticket sin título';
  String get ticketDescription =>
      ticketData?['descripcion_detallada'] ??
      widget.ticket['description'] ??
      '';
  String get ticketCategory =>
      ticketData?['categoria'] ?? widget.ticket['category'] ?? '';
  String get ticketPriority =>
      ticketData?['prioridad'] ?? widget.ticket['priority'] ?? '';
  String get ticketLocation =>
      ticketData?['ubicacion'] ?? widget.ticket['location'] ?? '';
  String get ticketStatus =>
      ticketData?['estado'] ?? widget.ticket['status'] ?? '';
  String get ticketCreatedAt =>
      ticketData?['created_at'] ?? widget.ticket['createdAt'] ?? '';
  int get ticketEmployeeId =>
      ticketData?['id_empleado'] ?? widget.ticket['employeeId'] ?? 0;
  List<dynamic> get ticketFiles => ticketData?['archivos'] ?? [];

  // Getters para datos del empleado/usuario desde el perfil
  String get empleadoNombre =>
      perfilData?['nombre'] ?? widget.ticket['user'] ?? 'Usuario desconocido';
  String get empleadoApellido => perfilData?['apellido'] ?? '';
  String get empleadoNombreCompleto {
    final result = perfilData != null
        ? '${perfilData!['nombre']} ${perfilData!['apellido']}'
        : widget.ticket['user'] ?? 'Usuario desconocido';
    return result;
  }

  String get empleadoEmail {
    final result = perfilData?['correo'] ?? widget.ticket['userEmail'] ?? '';
    return result;
  }

  String get empleadoArea {
    final result = perfilData?['area'] ?? '';
    return result;
  }

  String get empleadoCargo {
    final result = perfilData?['cargo'] ?? '';
    return result;
  }

  String get empleadoFechaNacimiento => perfilData?['fecha_nacimiento'] ?? '';
  String get displayStatus {
    switch (ticketStatus) {
      case 'en_proceso':
        return 'en proceso';
      default:
        return ticketStatus;
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'No disponible';
    try {
      final date = DateTime.parse(dateTime);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeMessages();
    _loadTicketDetails();
  }

  void _initializeMessages() {
    messages = [
      {
        'id': 1,
        'author': widget.ticket['user'] ?? 'Usuario',
        'role': 'user',
        'content': widget.ticket['description'] ?? '',
        'timestamp': widget.ticket['createdAt'],
        'isInternal': false,
      },
      {
        'id': 2,
        'author': widget.ticket['assignedTo'] ?? 'Técnico de Soporte',
        'role': 'support',
        'content':
            'Hola ${widget.ticket['user'] ?? 'Usuario'}, gracias por reportar el problema. Voy a revisar tu solicitud y trabajar en una solución.',
        'timestamp': widget.ticket['lastUpdate'],
        'isInternal': false,
      },
      if (widget.ticket['solution'] != null &&
          widget.ticket['solution'].toString().isNotEmpty)
        {
          'id': 3,
          'author': widget.ticket['assignedTo'] ?? 'Técnico de Soporte',
          'role': 'support',
          'content': 'TICKET RESUELTO: ${widget.ticket['solution']}',
          'timestamp':
              widget.ticket['resolutionDate'] ?? widget.ticket['lastUpdate'],
          'isInternal': false,
        },
    ];
  }

  void _updateMessagesWithApiData() {
    if (messages.isNotEmpty) {
      messages[0]['author'] = empleadoNombreCompleto;
      messages[0]['content'] = ticketDescription;
      if (messages.length > 1) {
        messages[1]['content'] =
            'Hola $empleadoNombreCompleto, gracias por reportar el problema. Voy a revisar tu solicitud y trabajar en una solución.';
      }
    }
  }

  Future<void> _loadChatRoom() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No se encontró el token de autorización');
      }
      
      final ticketId = widget.ticket['id'];
      if (ticketId == null) return;

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> chatRooms = jsonDecode(response.body);

        // Buscar la sala que corresponde a nuestro ticket
        try {
          final matchingRoom = chatRooms.firstWhere(
            (room) => room['ticket_id'].toString() == ticketId.toString(),
          );

          setState(() {
            _room = matchingRoom as Map<String, dynamic>;
          });

          await _loadChatMessages();
        } catch (e) {
          debugPrint('No se encontró sala de chat para el ticket: $ticketId');
        }
      }
    } catch (e) {
      debugPrint('Error al cargar la sala de chat: $e');
    }
  }

  Future<void> _loadChatMessages() async {
    try {
      setState(() {
        _isLoadingMessages = true;
      });

      final token = await AuthService.getToken();
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
        Uri.parse('${AuthService.baseUrl}/chats/$roomId/messages?limit=50'),
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
          messagesData = [];
        }

        setState(() {
          messages = messagesData
              .map((message) => _mapMessageFromApi(message))
              .toList();
          _isLoadingMessages = false;
        });

        _connectWebSocket(token);
      } else {
        setState(() {
          _isLoadingMessages = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar mensajes: $e');
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  Map<String, dynamic> _mapMessageFromApi(Map<String, dynamic> apiMessage) {
    // El sender_role en la API puede ser 'empleado' o 'admin'
    final senderRole = apiMessage['sender_role'] ?? '';
    final isUser = senderRole.toLowerCase() == 'empleado';
    
    return {
      'id': apiMessage['id'],
      'author': isUser ? empleadoNombreCompleto : 'Soporte Técnico',
      'role': isUser ? 'user' : 'support',
      'content': apiMessage['content'],
      'timestamp': _formatTimestampFromApi(apiMessage['created_at']),
      'isInternal': false,
    };
  }

  String _formatTimestampFromApi(String isoDate) {
    try {
      final DateTime messageDate = DateTime.parse(isoDate);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(messageDate);

      if (difference.inDays > 0) {
        return '${messageDate.year}-${messageDate.month.toString().padLeft(2, '0')}-${messageDate.day.toString().padLeft(2, '0')} ${messageDate.hour.toString().padLeft(2, '0')}:${messageDate.minute.toString().padLeft(2, '0')}';
      } else {
        return '${messageDate.hour.toString().padLeft(2, '0')}:${messageDate.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return isoDate;
    }
  }

  void _connectWebSocket(String token) {
    if (_room != null) {
      try {
        final roomId = _room!['id'];
        // Replace http with ws for WebSocket URL
        final baseWsUrl = AuthService.baseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
        final wsUrl = '$baseWsUrl/chats/ws/$roomId?token=$token';

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
                    messages.add(newMessage);
                  });
                }
              }
            } catch (e) {
              debugPrint('Error al procesar mensaje WebSocket: $e');
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
    _replyCtrl.dispose();
    super.dispose();
  }

  Color priorityColor(String p, ColorScheme cs) {
    switch (p) {
      case 'critical':
        return Colors.red;
      case 'high':
        return const Color(0xFF1C9985);
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color statusColor(String s) {
    switch (s) {
      case 'abierto':
        return const Color(0xFF1C9985);
      case 'en_proceso':
      case 'en proceso':
        return Colors.orange;
      case 'pendiente':
        return Colors.amber;
      case 'resuelto':
        return Colors.green;
      case 'cerrado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }

  void _handleSendMessage() async {
    final txt = _replyCtrl.text.trim();
    if (txt.isEmpty) return;

    // Clear the text field immediately
    final messageContent = txt;
    _replyCtrl.clear();

    // If we have a WebSocket connection and room, send through WebSocket
    if (_room != null && _isConnected && _webSocketChannel != null) {
      try {
        final messageData = {
          'type': 'message',
          'content': messageContent,
          'room_id': _room!['id'],
        };
        final jsonMessage = jsonEncode(messageData);
        
        _webSocketChannel?.sink.add(jsonMessage);
        
        setState(() {
          isInternalNote = false;
        });
      } catch (e) {
        debugPrint('Error al enviar mensaje: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar mensaje. Por favor intenta de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Fallback to the old method if WebSocket is not connected
      setState(() {
        final now = DateTime.now();
        final timestamp =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

        messages.add({
          'id': (messages.isEmpty ? 0 : (messages.last['id'] as int)) + 1,
          'author': 'Tú (Admin)',
          'role': 'support',
          'content': messageContent,
          'timestamp': timestamp,
          'isInternal': isInternalNote,
        });
        widget.ticket['lastUpdate'] = timestamp;

        isInternalNote = false;
      });
      widget.onUpdateTicket(widget.ticket);
    }
  }

  Future<void> _handleStatusChange(String newStatus) async {
    try {
      setState(() {
        isLoadingTicket = true;
      });
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token de autenticación no disponible');
      }
      final ticketId =
          ticketData?['id']?.toString() ?? widget.ticket['id']?.toString();
      if (ticketId == null) {
        throw Exception('ID del ticket no disponible');
      }

      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/tickets/$ticketId/estado'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'estado': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (ticketData != null) {
            ticketData!['estado'] = newStatus;
          }
          widget.ticket['status'] = newStatus;
          final now = DateTime.now();
          widget.ticket['lastUpdate'] =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

          if (newStatus == 'resuelto') {
            widget.ticket['resolutionDate'] = widget.ticket['lastUpdate'];
          }
        });

        widget.onUpdateTicket(widget.ticket);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado cambiado a "$newStatus" exitosamente'),
            backgroundColor: const Color(0xFF1C9985),
          ),
        );

        // Recargar los datos del ticket desde la API
        await _loadTicketDetails();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar el estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingTicket = false;
      });
    }
  }

  void _printVoucher() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VoucherPrintPage(ticket: widget.ticket),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isResolved = ticketStatus == 'resuelto' || ticketStatus == 'cerrado';

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1C9985),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ticket['id'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Detalle del Ticket',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _Badge(
                    label: ticketPriority,
                    color: priorityColor(ticketPriority, cs),
                  ),
                  const SizedBox(width: 8),
                  _Badge(
                    label: displayStatus,
                    color: statusColor(ticketStatus),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoadingTicket
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF1C9985)),
                        SizedBox(height: 16),
                        Text(
                          'Cargando detalles del ticket...',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTicketDetails,
                    color: const Color(0xFF1C9985),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Ticket info card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: cs.outlineVariant.withOpacity(0.5),
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (!isEditing) ...[
                                            Text(
                                              ticketTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              ticketDescription,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                            ),
                                          ] else ...[
                                            TextFormField(
                                              initialValue: ticketTitle,
                                              decoration: const InputDecoration(
                                                labelText: 'Título',
                                              ),
                                              onChanged: (v) =>
                                                  widget.ticket['title'] = v,
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              initialValue: ticketDescription,
                                              maxLines: 5,
                                              decoration: const InputDecoration(
                                                labelText: 'Descripción',
                                              ),
                                              onChanged: (v) =>
                                                  widget.ticket['description'] =
                                                      v,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() => isEditing = !isEditing);
                                        if (!isEditing) {
                                          widget.onUpdateTicket(widget.ticket);
                                        }
                                      },
                                      icon: Icon(
                                        isEditing ? Icons.save : Icons.edit,
                                        size: 18,
                                      ),
                                      label: Text(
                                        isEditing ? 'Guardar' : 'Editar',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, c) {
                            final isWide = c.maxWidth >= 700;
                            final children = [
                              _InfoCard(
                                title: 'Información del Usuario',
                                icon: Icons.person_outline,
                                rows: [
                                  ['Nombre:', empleadoNombreCompleto],
                                  ['Email:', empleadoEmail],
                                  if (perfilData != null) ...[
                                    ['Área:', empleadoArea],
                                    [
                                      'ID Empleado:',
                                      ticketEmployeeId.toString(),
                                    ],
                                  ],
                                  ['Categoría:', ticketCategory],
                                  ['Prioridad:', ticketPriority],
                                ],
                              ),
                              _InfoCard(
                                title: 'Información del Ticket',
                                icon: Icons.schedule,
                                rows: [
                                  if (ticketData != null) ...[
                                    [
                                      'ID Empleado:',
                                      ticketEmployeeId.toString(),
                                    ],
                                    [
                                      'Ubicación:',
                                      ticketLocation.isNotEmpty
                                          ? ticketLocation
                                          : 'No especificada',
                                    ],
                                    ['Estado:', displayStatus],
                                    [
                                      'Creado:',
                                      _formatDateTime(ticketCreatedAt),
                                    ],
                                    if (ticketFiles.isNotEmpty)
                                      [
                                        'Archivos:',
                                        '${ticketFiles.length} archivo(s)',
                                      ],
                                  ] else ...[
                                    [
                                      'Asignado a:',
                                      widget.ticket['assignedTo'] ??
                                          'Sin asignar',
                                    ],
                                    ['Creado:', widget.ticket['createdAt']],
                                    [
                                      'Actualizado:',
                                      widget.ticket['lastUpdate'],
                                    ],
                                  ],
                                  if (isResolved &&
                                      widget.ticket['resolutionDate'] != null)
                                    [
                                      'Resuelto:',
                                      widget.ticket['resolutionDate'],
                                    ],
                                ],
                              ),
                            ];
                            return isWide
                                ? Row(
                                    children: [
                                      Expanded(child: children[0]),
                                      const SizedBox(width: 12),
                                      Expanded(child: children[1]),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      children[0],
                                      const SizedBox(height: 12),
                                      children[1],
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(height: 12),
                        if (!isResolved)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: cs.outlineVariant.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Acciones Rápidas',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final width = constraints.maxWidth;
                                      final crossAxisCount = width < 400
                                          ? 2
                                          : 3;

                                      final actions = [
                                        _ActionButton(
                                          onPressed: isLoadingTicket
                                              ? null
                                              : () => _handleStatusChange(
                                                  'resuelto',
                                                ),
                                          icon: Icons.check_circle_outline,
                                          label: 'Resuelto',
                                          isPrimary: true,
                                        ),
                                        _ActionButton(
                                          onPressed: isLoadingTicket
                                              ? null
                                              : () => _handleStatusChange(
                                                  'cerrado',
                                                ),
                                          icon: Icons.lock,
                                          label: 'Cerrado',
                                          isPrimary: false,
                                        ),
                                      ];

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              childAspectRatio: 2.5,
                                              crossAxisSpacing: 8,
                                              mainAxisSpacing: 8,
                                            ),
                                        itemCount: actions.length,
                                        itemBuilder: (context, index) =>
                                            actions[index],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (isResolved)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: cs.outlineVariant.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ticket Finalizado',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _ActionButton(
                                      onPressed: _printVoucher,
                                      icon: Icons.print,
                                      label: 'Imprimir Comprobante',
                                      isPrimary: true,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),
                        if (!isResolved)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: cs.outlineVariant.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.forum_outlined,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Conversación (${messages.length})',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...messages.map((m) {
                                    final bool internal =
                                        m['isInternal'] as bool;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: EdgeInsets.all(
                                        internal ? 12 : 0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: internal
                                            ? Colors.yellow.withOpacity(0.12)
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor:
                                                (m['role'] == 'user')
                                                ? Colors.blue.shade100
                                                : const Color(0xFF1C9985),
                                            child: Text(
                                              _initials(m['author']),
                                              style: TextStyle(
                                                color: (m['role'] == 'user')
                                                    ? Colors.blue.shade700
                                                    : Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      m['author'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _Badge(
                                                      label: m['role'] == 'user'
                                                          ? 'Usuario'
                                                          : 'Soporte',
                                                      color: m['role'] == 'user'
                                                          ? Colors.blue
                                                          : const Color(
                                                              0xFF1C9985,
                                                            ),
                                                    ),
                                                    if (internal) ...[
                                                      const SizedBox(width: 6),
                                                      const _Badge(
                                                        label: 'Interno',
                                                        color: Colors.amber,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  m['content'],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  m['timestamp'],
                                                  style: TextStyle(
                                                    color: cs.onSurfaceVariant,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                  const Divider(height: 28),

                                  // Sección Voucher (si resuelto)
                                  if (isResolved) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.08),
                                        border: Border.all(
                                          color: Colors.green.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle_outline,
                                                    color:
                                                        Colors.green.shade800,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Ticket Resuelto',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.green.shade800,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Este ticket ha sido resuelto. Puedes imprimir el voucher.',
                                                style: TextStyle(
                                                  color: Colors.green.shade800,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          FilledButton.icon(
                                            onPressed: _printVoucher,
                                            icon: const Icon(
                                              Icons.print,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Imprimir Voucher',
                                            ),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 28),
                                  ],

                                  // Responder
                                  Row(
                                    children: [
                                      Text(
                                        'Responder al ticket',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () =>
                                            FocusScope.of(context).unfocus(),
                                        icon: const Icon(
                                          Icons.keyboard_hide,
                                          size: 20,
                                        ),
                                        tooltip: 'Cerrar teclado',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _replyCtrl,
                                    minLines: 3,
                                    maxLines: 6,
                                    textInputAction: TextInputAction.newline,
                                    onChanged: (value) => setState(
                                      () {},
                                    ), // Para actualizar el estado del botón
                                    decoration: const InputDecoration(
                                      hintText: 'Escribe tu respuesta...',
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.send),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isMobile =
                                          constraints.maxWidth < 600;

                                      if (isMobile) {
                                        // Layout móvil: Todo en columnas
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                      Icons.attach_file,
                                                      size: 16,
                                                    ),
                                                    label: const FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        'Adjuntar',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Row(),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            // Segunda fila: Botones de acción
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _replyCtrl.clear(),
                                                    icon: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                    ),
                                                    label: const Text(
                                                      'Cancelar',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  flex: 2,
                                                  child: FilledButton.icon(
                                                    onPressed:
                                                        _replyCtrl.text
                                                            .trim()
                                                            .isEmpty
                                                        ? null
                                                        : () {
                                                            _handleSendMessage();
                                                            FocusScope.of(
                                                              context,
                                                            ).unfocus();
                                                          },
                                                    style: FilledButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF1C9985,
                                                          ),
                                                      disabledBackgroundColor:
                                                          Colors.grey[300],
                                                    ),
                                                    icon: const Icon(
                                                      Icons.send,
                                                      size: 16,
                                                    ),
                                                    label: const Text(
                                                      'Enviar',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      } else {
                                        // Layout desktop: Una sola fila
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                OutlinedButton.icon(
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                    Icons.attach_file,
                                                    size: 18,
                                                  ),
                                                  label: const Text('Adjuntar'),
                                                ),
                                                const SizedBox(width: 12),
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: isInternalNote,
                                                      onChanged: (v) =>
                                                          setState(
                                                            () =>
                                                                isInternalNote =
                                                                    v ?? false,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                OutlinedButton.icon(
                                                  onPressed: () =>
                                                      _replyCtrl.clear(),
                                                  icon: const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                  ),
                                                  label: const Text('Cancelar'),
                                                ),
                                                const SizedBox(width: 8),
                                                FilledButton.icon(
                                                  onPressed:
                                                      _replyCtrl.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : () {
                                                          _handleSendMessage();
                                                          FocusScope.of(
                                                            context,
                                                          ).unfocus();
                                                        },
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF1C9985),
                                                    disabledBackgroundColor:
                                                        Colors.grey[300],
                                                  ),
                                                  icon: const Icon(
                                                    Icons.send,
                                                    size: 18,
                                                  ),
                                                  label: const Text('Enviar'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Información para tickets finalizados
                        if (isResolved)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: cs.outlineVariant.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    ticketStatus == 'resuelto'
                                        ? Icons.check_circle
                                        : Icons.lock,
                                    size: 48,
                                    color: ticketStatus == 'resuelto'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    ticketStatus == 'resuelto'
                                        ? 'Ticket Resuelto'
                                        : 'Ticket Cerrado',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: ticketStatus == 'resuelto'
                                              ? Colors.green
                                              : Colors.grey[700],
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ticketStatus == 'resuelto'
                                        ? 'Este ticket ha sido marcado como resuelto. Ya no se pueden enviar más mensajes.'
                                        : 'Este ticket ha sido cerrado y ya no acepta nuevos mensajes.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.rows,
  });
  final String title;
  final IconData icon;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.5), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            ...rows.map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r.first,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        r.last,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isPrimary,
    this.color,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF1C9985),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          icon: Icon(icon, size: 16),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          icon: Icon(icon, size: 16),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
            ),
          ),
        ),
      );
    }
  }
}
