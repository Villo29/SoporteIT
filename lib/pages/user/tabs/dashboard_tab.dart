import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../create_report_page.dart';
import '../../../services/auth_service.dart';

class DashboardTab extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const DashboardTab({super.key, this.onTabChange});

  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  List<Map<String, dynamic>> _myTickets = [];
  bool _isLoadingTickets = true;

  @override
  void initState() {
    super.initState();
    _loadUserTickets();
  }

  Future<void> _loadUserTickets() async {
    try {
      setState(() {
        _isLoadingTickets = true;
      });

      final token = await AuthService.getCurrentToken();
      if (token == null) {
        setState(() {
          _isLoadingTickets = false;
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
        final List<dynamic> ticketsData = json.decode(response.body);

        setState(() {
          _myTickets = ticketsData
              .map((ticket) => _mapTicketFromApi(ticket))
              .toList();
          _isLoadingTickets = false;
        });
      } else {
        setState(() {
          _isLoadingTickets = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingTickets = false;
      });
    }
  }

  Map<String, dynamic> _mapTicketFromApi(Map<String, dynamic> apiTicket) {
    return {
      'id': 'TK-${apiTicket['id']}',
      'title': apiTicket['titulo'] ?? 'Sin título',
      'status': _mapStatusFromApi(apiTicket['estado'] ?? 'abierto'),
      'time': _formatTimeFromApi(apiTicket['created_at'] ?? ''),
      'priority': _mapPriorityFromApi(apiTicket['prioridad'] ?? 'media'),
    };
  }

  String _mapStatusFromApi(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'abierto':
        return 'Abierto';
      case 'en_proceso':
      case 'procesando':
        return 'En progreso';
      case 'cerrado':
      case 'resuelto':
        return 'Resuelto';
      default:
        return 'Abierto';
    }
  }

  String _mapPriorityFromApi(String apiPriority) {
    switch (apiPriority.toLowerCase()) {
      case 'baja':
      case 'bajo':
        return 'Baja';
      case 'media':
      case 'medio':
        return 'Media';
      case 'alta':
      case 'alto':
        return 'Alta';
      case 'critica':
      case 'crítica':
        return 'Crítica';
      default:
        return 'Media';
    }
  }

  String _formatTimeFromApi(String isoDate) {
    try {
      final DateTime ticketDate = DateTime.parse(isoDate);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(ticketDate);

      if (difference.inMinutes < 60) {
        return 'hace ${difference.inMinutes} minutos';
      } else if (difference.inHours < 24) {
        return 'hace ${difference.inHours} horas';
      } else {
        return 'hace ${difference.inDays} días';
      }
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 30),
          _buildNewReportCard(context),
          SizedBox(height: 30),
          _buildMyReports(),
          SizedBox(height: 30),
          _buildTips(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola! ¿Necesitas ayuda?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Reporta cualquier problema técnico y te ayudaremos a solucionarlo',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNewReportCard(BuildContext context) {
    return Card(
      color: Colors.blue,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reportar Nuevo Problema',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Describe tu problema y te contactaremos pronto',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateReportPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 4),
                  Text('Nuevo Reporte'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyReports() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Reportes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isLoadingTickets)
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
            ),
            SizedBox(height: 16),
            _isLoadingTickets
                ? Container(
                    height: 100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1C9985),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cargando reportes...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _myTickets.isEmpty
                ? Container(
                    height: 100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No tienes reportes aún',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      ..._myTickets.take(3).map((ticket) {
                        return _buildTicketCard(ticket);
                      }).toList(),
                      if (_myTickets.length > 3) ...[
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'y ${_myTickets.length - 3} más...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (widget.onTabChange != null) {
                    widget.onTabChange!(1);
                  }
                },
                child: Text('Ver Todos Mis Reportes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Abierto':
        return Colors.red;
      case 'En progreso':
        return Colors.orange;
      case 'Resuelto':
        return Colors.green;
      case 'Cerrado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Abierto':
        return Icons.warning;
      case 'En progreso':
        return Icons.access_time;
      case 'Resuelto':
        return Icons.check_circle;
      case 'Cerrado':
        return Icons.lock;
      default:
        return Icons.help_outline;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _getStatusIcon(ticket['status'] ?? 'Abierto'),
              color: _getStatusColor(ticket['status'] ?? 'Abierto'),
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ticket['id'] ?? 'TK-000',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            ticket['status'] ?? 'Abierto',
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ticket['status'] ?? 'Sin estado',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(
                              ticket['status'] ?? 'Abierto',
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            ticket['priority'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ticket['priority'] ?? 'Normal',
                          style: TextStyle(
                            color: _getPriorityColor(ticket['priority']),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    ticket['title'] ?? 'Sin título',
                    style: TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    ticket['time'] ?? 'Sin fecha',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTips() {
    final tips = [
      {
        'emoji': '💡',
        'text':
            'Sé específico: Describe exactamente qué estaba haciendo cuando ocurrió el problema',
      },
      {
        'emoji': '⚡',
        'text':
            'Urgente: Para problemas críticos, también puedes llamar al ext. 1234',
      },
      {
        'emoji': '📋',
        'text':
            'Seguimiento: Recibirás notificaciones por email sobre el estado de tu reporte',
      },
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consejos Útiles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Column(
              children: tips.map((tip) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(tip['emoji']!, style: TextStyle(fontSize: 16)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip['text']!,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
