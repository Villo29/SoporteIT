import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ticket_detail_page.dart';
import '../../../services/auth_service.dart';

class AdminTicketsTab extends StatefulWidget {
  const AdminTicketsTab({super.key, this.onOpenTicketDetail});
  final void Function(String ticketId)? onOpenTicketDetail;

  @override
  State<AdminTicketsTab> createState() => _AdminTicketsTabState();
}

class _AdminTicketsTabState extends State<AdminTicketsTab> {
  String searchTerm = '';
  String filterStatus = 'all';
  String filterPriority = 'all';

  List<Map<String, dynamic>> tickets = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    if (!mounted) return;

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/tickets'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        if (mounted) {
          setState(() {
            tickets = data.map((ticket) => _mapApiTicketToUI(ticket)).toList();
            isLoading = false;
            hasError = false;
          });
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  Map<String, dynamic> _mapApiTicketToUI(Map<String, dynamic> apiTicket) {
    return {
      'id': apiTicket['id']?.toString() ?? 'N/A',
      'title': apiTicket['titulo'] ?? 'Sin título',
      'description': apiTicket['descripcion_detallada'] ?? 'Sin descripción',
      'user': apiTicket['usuario']?['nombre'] ?? 'Usuario desconocido',
      'userEmail': apiTicket['usuario']?['email'] ?? 'email@desconocido.com',
      'employeeId': apiTicket['usuario']?['id'] ?? apiTicket['id_empleado'],
      'category': _mapCategory(apiTicket['categoria']),
      'priority': _mapPriority(apiTicket['prioridad']),
      'status': _mapStatus(apiTicket['estado']),
      'assignedTo': apiTicket['empleado']?['nombre'],
      'createdAt': _formatDateTime(apiTicket['fecha_creacion']),
      'lastUpdate': _formatDateTime(
        apiTicket['fecha_actualizacion'] ?? apiTicket['fecha_creacion'],
      ),
      'responses':
          0,
      'solution': apiTicket['solucion'] ?? '',
      'resolutionDate': apiTicket['fecha_resolucion'] != null
          ? _formatDateTime(apiTicket['fecha_resolucion'])
          : null,
    };
  }

  String _mapCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'hardware':
        return 'Hardware';
      case 'software':
        return 'Software';
      case 'red':
        return 'Red';
      case 'telefonia':
        return 'Telefonía';
      default:
        return category ?? 'General';
    }
  }

  String _mapPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critica':
        return 'Critico';
      case 'alta':
        return 'Alto';
      case 'media':
        return 'Medio';
      case 'baja':
        return 'Bajo';
      default:
        return 'medium';
    }
  }

  String _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'abierto':
        return 'abierto';
      case 'en_proceso':
        return 'en proceso';
      case 'pendiente':
        return 'pendiente';
      case 'resuelto':
        return 'resuelto';
      case 'cerrado':
        return 'cerrado';
      default:
        return 'abierto';
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return DateTime.now().toString();

    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return DateTime.now().toString();
    }
  }

  Color _priorityColor(String p, ColorScheme cs) {
    switch (p) {
      case 'Critico':
        return Colors.red;
      case 'Alto':
        return Color(0xFF1C9985);
      case 'Medio':
        return Colors.orange;
      case 'Bajo':
        return Color(0xFF1C9985);
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'abierto':
        return Color(0xFF1C9985);
      case 'en proceso':
        return Colors.orange;
      case 'pendiente':
        return Colors.amber;
      case 'resuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'abierto':
        return Icons.error_outline;
      case 'en proceso':
        return Icons.schedule;
      case 'pendiente':
        return Icons.schedule;
      case 'resuelto':
        return Icons.check_circle_outline;
      default:
        return Icons.error_outline;
    }
  }

  List<Map<String, dynamic>> get _filteredTickets {
    return tickets.where((t) {
      final q = searchTerm.toLowerCase();
      final matchesSearch =
          t['title'].toString().toLowerCase().contains(q) ||
          t['user'].toString().toLowerCase().contains(q) ||
          t['id'].toString().toLowerCase().contains(q);
      final matchesStatus =
          filterStatus == 'all' || t['status'] == filterStatus;
      final matchesPriority =
          filterPriority == 'all' || t['priority'] == filterPriority;
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  void _handleAssignTicket(String id, String assignTo) {
    debugPrint('Assigning ticket $id to $assignTo');
  }

  void _handleChangeStatus(String id, String newStatus) {
    setState(() {
      final ticketIndex = tickets.indexWhere((t) => t['id'] == id);
      if (ticketIndex != -1) {
        tickets[ticketIndex]['status'] = newStatus;
        if (newStatus == 'resuelto') {
          final now = DateTime.now();
          tickets[ticketIndex]['resolutionDate'] =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
          tickets[ticketIndex]['solution'] =
              'Ticket resuelto por el administrador.';
        }
      }
    });
  }

  void _openTicketDetail(Map<String, dynamic> ticket) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TicketDetailPage(
          ticket: ticket,
          onUpdateTicket: (updatedTicket) {
            setState(() {
              final index = tickets.indexWhere(
                (t) => t['id'] == updatedTicket['id'],
              );
              if (index != -1) {
                tickets[index] = updatedTicket;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1C9985)),
            SizedBox(height: 16),
            Text('Cargando tickets...'),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar tickets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTickets,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final total = tickets.length;
    final abiertos = tickets.where((t) => t['status'] == 'abierto').length;
    final enProceso = tickets.where((t) => t['status'] == 'en proceso').length;
    final resueltos = tickets.where((t) => t['status'] == 'resuelto').length;

    return RefreshIndicator(
      onRefresh: _loadTickets,
      color: const Color(0xFF1C9985),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            'Gestión de Tickets',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Administra y da seguimiento a todos los tickets del sistema',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Filtros y búsqueda
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar por título, usuario o ID...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (v) => setState(() => searchTerm = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: filterStatus,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('Todos los estados'),
                            ),
                            DropdownMenuItem(
                              value: 'abierto',
                              child: Text('Abierto'),
                            ),
                            DropdownMenuItem(
                              value: 'en proceso',
                              child: Text('En Proceso'),
                            ),
                            DropdownMenuItem(
                              value: 'pendiente',
                              child: Text('Pendiente'),
                            ),
                            DropdownMenuItem(
                              value: 'resuelto',
                              child: Text('Resuelto'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => filterStatus = v ?? 'all'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: filterPriority,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('Todas las prioridades'),
                            ),
                            DropdownMenuItem(
                              value: 'critical',
                              child: Text('Crítica'),
                            ),
                            DropdownMenuItem(
                              value: 'high',
                              child: Text('Alta'),
                            ),
                            DropdownMenuItem(
                              value: 'medium',
                              child: Text('Media'),
                            ),
                            DropdownMenuItem(value: 'low', child: Text('Baja')),
                          ],
                          onChanged: (v) =>
                              setState(() => filterPriority = v ?? 'all'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Resumen - Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;

              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 4,
                  mainAxisSpacing: isMobile ? 8 : 12,
                  crossAxisSpacing: isMobile ? 8 : 12,
                  childAspectRatio: isMobile ? 1.8 : 1.4,
                ),
                children: [
                  _SummaryCard(title: 'Total', value: '$total'),
                  _SummaryCard(
                    title: 'Abiertos',
                    value: '$abiertos',
                    valueColor: Color(0xFF1C9985),
                  ),
                  _SummaryCard(
                    title: 'En Proceso',
                    value: '$enProceso',
                    valueColor: Colors.orange,
                  ),
                  _SummaryCard(
                    title: 'Resueltos',
                    value: '$resueltos',
                    valueColor: Colors.green,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Lista de tickets
          if (_filteredTickets.isEmpty)
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No se encontraron tickets que coincidan con los filtros.',
                  ),
                ),
              ),
            )
          else
            ..._filteredTickets.map(
              (t) => _TicketCard(
                data: t,
                onOpen: () => _openTicketDetail(t),
                onAssign: (assignee) =>
                    _handleAssignTicket(t['id'] as String, assignee),
                onChangeStatus: (s) =>
                    _handleChangeStatus(t['id'] as String, s),
                statusColor: _statusColor,
                statusIcon: _statusIcon,
                priorityColor: (p) =>
                    _priorityColor(p, Theme.of(context).colorScheme),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    this.valueColor,
  });
  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.data,
    required this.onOpen,
    required this.onAssign,
    required this.onChangeStatus,
    required this.statusColor,
    required this.statusIcon,
    required this.priorityColor,
  });

  final Map<String, dynamic> data;
  final VoidCallback? onOpen;
  final void Function(String assignee) onAssign;
  final void Function(String status) onChangeStatus;
  final Color Function(String) statusColor;
  final IconData Function(String) statusIcon;
  final Color Function(String) priorityColor;

  @override
  Widget build(BuildContext context) {
    final String id = data['id'];
    final String title = data['title'];
    final String desc = data['description'];
    final String user = data['user'];
    final String category = data['category'];
    final String? assignedTo = data['assignedTo'];
    final String status = data['status'];
    final String priority = data['priority'];
    final int responses = data['responses'];
    final String lastUpdate =
        (DateTime.tryParse(data['lastUpdate']) ?? DateTime.now())
            .toLocal()
            .toString()
            .split(' ')
            .first;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 400;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _Badge(
                                label: priority,
                                color: priorityColor(priority),
                              ),
                              const SizedBox(width: 6),
                              _Badge(
                                label: status,
                                color: statusColor(status),
                                icon: statusIcon(status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Details line
                DefaultTextStyle(
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 400;

                      if (isMobile) {
                        // Mobile layout: stack vertically
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                Text(user),
                                const Text(' • '),
                                Text(category),
                                if (assignedTo != null) ...[
                                  const Text(' • '),
                                  Text('Asignado: $assignedTo'),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              children: [
                                Text('$responses respuestas'),
                                const Text(' • '),
                                Text('Actualizado: $lastUpdate'),
                              ],
                            ),
                          ],
                        );
                      }

                      // Desktop layout: original horizontal
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Text(user),
                                const SizedBox(width: 6),
                                const Text('•'),
                                const SizedBox(width: 6),
                                Text(category),
                                if (assignedTo != null) ...[
                                  const SizedBox(width: 6),
                                  const Text('•'),
                                  const SizedBox(width: 6),
                                  Text('Asignado: $assignedTo'),
                                ],
                              ],
                            ),
                          ),
                          Flexible(
                            child: Row(
                              children: [
                                Text('$responses respuestas'),
                                const SizedBox(width: 12),
                                Text('Actualizado: $lastUpdate'),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Actions
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onOpen,
                      child: const Text('Ver Ticket'),
                    ),
                    const SizedBox(width: 8),
                    if (status != 'resuelto')
                      OutlinedButton(
                        onPressed: onOpen,
                        child: const Text('Resolver Ticket'),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Badge/chip minimalista
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
