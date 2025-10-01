import 'package:flutter/material.dart';
import '../../create_report_page.dart';


class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

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
    final myTickets = [
      {
        'id': 'TK-156',
        'title': 'Mi computadora se reinicia sola',
        'status': 'En progreso',
        'time': 'hace 2 horas',
        'priority': 'Media',
      },
      {
        'id': 'TK-142',
        'title': 'No puedo acceder a mi email',
        'status': 'Resuelto',
        'time': 'hace 1 día',
        'priority': 'Alta',
      },
      {
        'id': 'TK-138',
        'title': 'Impresora no imprime',
        'status': 'Abierto',
        'time': 'hace 3 días',
        'priority': 'Baja',
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
              'Mis Reportes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Column(
              children: myTickets.map((ticket) {
                return _buildTicketCard(ticket);
              }).toList(),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // Ver todos los reportes
                },
                child: Text('Ver Todos Mis Reportes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'Abierto':
          return Colors.red;
        case 'En progreso':
          return Colors.orange;
        case 'Resuelto':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    IconData getStatusIcon(String status) {
      switch (status) {
        case 'Abierto':
          return Icons.warning;
        case 'En progreso':
          return Icons.access_time;
        case 'Resuelto':
          return Icons.check_circle;
        default:
          return Icons.access_time;
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              getStatusIcon(ticket['status']),
              color: getStatusColor(ticket['status']),
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
                        ticket['id'],
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
                          color: getStatusColor(
                            ticket['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ticket['status'],
                          style: TextStyle(
                            fontSize: 12,
                            color: getStatusColor(ticket['status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(ticket['title'], style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    ticket['time'],
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
