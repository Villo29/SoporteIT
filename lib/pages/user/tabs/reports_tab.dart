import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../create_report_page.dart';
import '../../ticket_chat_page.dart';
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
      'description': apiReport['descripcion'] ?? 'Sin descripción',
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
