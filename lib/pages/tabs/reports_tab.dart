import 'package:flutter/material.dart';
import '../create_report_page.dart';
import '../ticket_chat_page.dart';

class ReportsTab extends StatelessWidget {
  final Function(String) onOpenTicketChat;
  final Function onCreateReport;

  const ReportsTab({
    super.key,
    required this.onOpenTicketChat,
    required this.onCreateReport,
  });

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        'id': "TK-156",
        'title': "Problema con impresora HP",
        'description': "La impresora no responde a los comandos de impresión",
        'status': "pending",
        'date': "2024-01-15",
        'priority': "medium",
      },
      {
        'id': "TK-142",
        'title': "Conexión de red lenta",
        'description':
            "Velocidad de internet muy baja en el área de contabilidad",
        'status': "completed",
        'date': "2024-01-14",
        'priority': "high",
      },
      {
        'id': "TK-138",
        'title': "Software no inicia",
        'description': "El programa de gestión no se ejecuta correctamente",
        'status': "in_progress",
        'date': "2024-01-13",
        'priority': "low",
      },
    ];

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
                Text(
                  'Reportes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _buildReportCard(report, context);
              },
            ),
          ),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketChatPage(ticketId: report['id']),
            ),
          );
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
}
