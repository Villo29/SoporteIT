import 'package:flutter/material.dart';


class AdminTicketsTab extends StatefulWidget {
  const AdminTicketsTab({super.key, this.onOpenTicketDetail});
  final void Function(String ticketId)? onOpenTicketDetail; // opcional para navegación

  @override
  State<AdminTicketsTab> createState() => _AdminTicketsTabState();
}

class _AdminTicketsTabState extends State<AdminTicketsTab> {
  String searchTerm = '';
  String filterStatus = 'all';
  String filterPriority = 'all';

  final List<Map<String, dynamic>> tickets = [
    {
      'id': 'TK-001',
      'title': 'Problema con impresora HP LaserJet en oficina 201',
      'description': 'La impresora no responde y muestra error de papel atascado',
      'user': 'Juan Pérez',
      'userEmail': 'juan.perez@empresa.com',
      'category': 'Impresora',
      'priority': 'high',
      'status': 'abierto',
      'assignedTo': 'Ana García',
      'createdAt': '2024-01-15 10:30',
      'lastUpdate': '2024-01-15 14:20',
      'responses': 3,
    },
    {
      'id': 'TK-002',
      'title': 'Error en sistema de facturación - módulo de reportes',
      'description': 'Al generar reportes mensuales el sistema muestra error 500',
      'user': 'María García',
      'userEmail': 'maria.garcia@empresa.com',
      'category': 'Software',
      'priority': 'critical',
      'status': 'en proceso',
      'assignedTo': 'Carlos Ruiz',
      'createdAt': '2024-01-15 09:15',
      'lastUpdate': '2024-01-15 15:45',
      'responses': 7,
    },
    {
      'id': 'TK-003',
      'title': 'Solicitud de acceso a carpeta compartida del departamento',
      'description': 'Necesito acceso de lectura y escritura a /shared/marketing',
      'user': 'Carlos López',
      'userEmail': 'carlos.lopez@empresa.com',
      'category': 'Red',
      'priority': 'medium',
      'status': 'pendiente',
      'assignedTo': null,
      'createdAt': '2024-01-15 08:45',
      'lastUpdate': '2024-01-15 08:45',
      'responses': 0,
    },
    {
      'id': 'TK-004',
      'title': 'Computadora lenta - posible problema de malware',
      'description': 'La computadora del escritorio 15 funciona muy lenta desde ayer',
      'user': 'Ana Martínez',
      'userEmail': 'ana.martinez@empresa.com',
      'category': 'Computadora',
      'priority': 'medium',
      'status': 'resuelto',
      'assignedTo': 'Luis Torres',
      'createdAt': '2024-01-14 16:20',
      'lastUpdate': '2024-01-15 11:30',
      'responses': 5,
    },
    {
      'id': 'TK-005',
      'title': 'Teléfono IP no recibe llamadas entrantes',
      'description': 'El teléfono de la extensión 1205 no suena para llamadas entrantes',
      'user': 'Roberto Silva',
      'userEmail': 'roberto.silva@empresa.com',
      'category': 'Teléfono',
      'priority': 'high',
      'status': 'en proceso',
      'assignedTo': 'Ana García',
      'createdAt': '2024-01-15 13:10',
      'lastUpdate': '2024-01-15 16:00',
      'responses': 2,
    },
  ];

  Color _priorityColor(String p, ColorScheme cs) {
    switch (p) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Color(0xFF1C9985);
      case 'medium':
        return Colors.orange;
      case 'low':
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
      final matchesSearch = t['title'].toString().toLowerCase().contains(q) ||
          t['user'].toString().toLowerCase().contains(q) ||
          t['id'].toString().toLowerCase().contains(q);
      final matchesStatus = filterStatus == 'all' || t['status'] == filterStatus;
      final matchesPriority = filterPriority == 'all' || t['priority'] == filterPriority;
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  void _handleAssignTicket(String id, String assignTo) {
    debugPrint('Assigning ticket $id to $assignTo');
  }

  void _handleChangeStatus(String id, String newStatus) {
    debugPrint('Changing ticket $id status to $newStatus');
  }

  @override
  Widget build(BuildContext context) {
    final total = tickets.length;
    final abiertos = tickets.where((t) => t['status'] == 'abierto').length;
    final enProceso = tickets.where((t) => t['status'] == 'en proceso').length;
    final resueltos = tickets.where((t) => t['status'] == 'resuelto').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Text('Gestión de Tickets',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Administra y da seguimiento a todos los tickets del sistema',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todos los estados')),
                          DropdownMenuItem(value: 'abierto', child: Text('Abierto')),
                          DropdownMenuItem(value: 'en proceso', child: Text('En Proceso')),
                          DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                          DropdownMenuItem(value: 'resuelto', child: Text('Resuelto')),
                        ],
                        onChanged: (v) => setState(() => filterStatus = v ?? 'all'),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todas las prioridades')),
                          DropdownMenuItem(value: 'critical', child: Text('Crítica')),
                          DropdownMenuItem(value: 'high', child: Text('Alta')),
                          DropdownMenuItem(value: 'medium', child: Text('Media')),
                          DropdownMenuItem(value: 'low', child: Text('Baja')),
                        ],
                        onChanged: (v) => setState(() => filterPriority = v ?? 'all'),
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
                _SummaryCard(title: 'Abiertos', value: '$abiertos', valueColor: Color(0xFF1C9985)),
                _SummaryCard(title: 'En Proceso', value: '$enProceso', valueColor: Colors.orange),
                _SummaryCard(title: 'Resueltos', value: '$resueltos', valueColor: Colors.green),
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
                child: Text('No se encontraron tickets que coincidan con los filtros.'),
              ),
            ),
          )
        else
          ..._filteredTickets.map((t) => _TicketCard(
                data: t,
                onOpen: () => widget.onOpenTicketDetail?.call(t['id'] as String),
                onAssign: (assignee) => _handleAssignTicket(t['id'] as String, assignee),
                onChangeStatus: (s) => _handleChangeStatus(t['id'] as String, s),
                statusColor: _statusColor,
                statusIcon: _statusIcon,
                priorityColor: (p) => _priorityColor(p, Theme.of(context).colorScheme),
              )),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value, this.valueColor});
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
    final String lastUpdate = (DateTime.tryParse(data['lastUpdate']) ?? DateTime.now())
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
                          Text(id, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          _Badge(label: priority, color: priorityColor(priority)),
                          const SizedBox(width: 6),
                          _Badge(label: status, color: statusColor(status), icon: statusIcon(status)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'detalle':
                        onOpen?.call();
                        break;
                      case 'proceso':
                        onChangeStatus('en proceso');
                        break;
                      case 'reasignar':
                        onAssign('admin');
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'detalle', child: Text('Ver Detalles')),
                    PopupMenuItem(value: 'proceso', child: Text('Cambiar Estado')),
                    PopupMenuItem(value: 'reasignar', child: Text('Reasignar')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Details line
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 400;
                  
                  if (isMobile) {
                    // Mobile layout: stack vertically
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(children: [
                          Text(user),
                          const Text(' • '),
                          Text(category),
                          if (assignedTo != null) ...[
                            const Text(' • '),
                            Text('Asignado: $assignedTo'),
                          ],
                        ]),
                        const SizedBox(height: 4),
                        Wrap(children: [
                          Text('$responses respuestas'),
                          const Text(' • '),
                          Text('Actualizado: $lastUpdate'),
                        ]),
                      ],
                    );
                  }
                  
                  // Desktop layout: original horizontal
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(children: [
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
                        ]),
                      ),
                      Flexible(
                        child: Row(children: [
                          Text('$responses respuestas'),
                          const SizedBox(width: 12),
                          Text('Actualizado: $lastUpdate'),
                        ]),
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
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
