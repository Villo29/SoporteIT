import 'package:flutter/material.dart';

class TicketChatPage extends StatefulWidget {
  final String ticketId;

  const TicketChatPage({Key? key, required this.ticketId}) : super(key: key);

  @override
  _TicketChatPageState createState() => _TicketChatPageState();
}

class _TicketChatPageState extends State<TicketChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'sender': 'support',
      'content': 'Hemos recibido tu reporte sobre el problema con la computadora. Un técnico lo revisará pronto.',
      'timestamp': '10:30 AM',
      'type': 'message'
    },
    {
      'id': '2',
      'sender': 'support',
      'content': 'Estado actualizado: En progreso',
      'timestamp': '11:15 AM',
      'type': 'status_update'
    },
    {
      'id': '3',
      'sender': 'support',
      'content': 'Hola! Soy Carlos del equipo técnico. He visto tu reporte y me dirijo a tu oficina para revisar el problema. ¿Estarás disponible en los próximos 15 minutos?',
      'timestamp': '11:45 AM',
      'type': 'message'
    },
    {
      'id': '4',
      'sender': 'user',
      'content': 'Sí, estaré aquí. Gracias por la pronta respuesta.',
      'timestamp': '11:47 AM',
      'type': 'message'
    }
  ];

  @override
  void initState() {
    super.initState();
    // Scroll al final de los mensajes cuando se carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'sender': 'user',
      'content': _messageController.text.trim(),
      'timestamp': _getCurrentTime(),
      'type': 'message'
    };

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    // Simular respuesta automática del soporte
    Future.delayed(Duration(seconds: 1), () {
      final supportResponse = {
        'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        'sender': 'support',
        'content': 'Recibido. Te responderemos pronto.',
        'timestamp': _getCurrentTime(),
        'type': 'message'
      };

      setState(() {
        _messages.add(supportResponse);
      });
      _scrollToBottom();
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
            Text(
              'Ticket #${widget.ticketId}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 2),
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
            child: ListView.builder(
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
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi computadora se reinicia sola',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Estaba trabajando en Excel cuando de repente la pantalla se puso azul...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Creado: Hace 2 horas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    'Alta Prioridad',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
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
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
              child: Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
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
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
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
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}