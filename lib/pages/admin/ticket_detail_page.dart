import 'package:flutter/material.dart';
import 'voucher_print_page.dart';

/// =============================================================
/// TicketDetailPage - Vista detallada del ticket con chat completo
/// - Vista adaptada con header, badges de prioridad/estado,
///   info del ticket/usuario, acciones rápidas, adjuntos, conversación,
///   sección de descarga de voucher cuando está resuelto y compositor de mensaje.
/// =============================================================

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
  
  late List<Map<String, dynamic>> messages; // Conversación del ticket

  @override
  void initState() {
    super.initState();
    
    // Inicializar conversación mock (en un caso real vendría de API)
    messages = [
      {
        'id': 1,
        'author': widget.ticket['user'],
        'role': 'user',
        'content': widget.ticket['description'],
        'timestamp': widget.ticket['createdAt'],
        'isInternal': false,
      },
      {
        'id': 2,
        'author': widget.ticket['assignedTo'] ?? 'Técnico de Soporte',
        'role': 'support',
        'content': 'Hola ${widget.ticket['user']}, gracias por reportar el problema. Voy a revisar tu solicitud y trabajar en una solución.',
        'timestamp': widget.ticket['lastUpdate'],
        'isInternal': false,
      },
      if (widget.ticket['solution'] != null && widget.ticket['solution'].toString().isNotEmpty)
        {
          'id': 3,
          'author': widget.ticket['assignedTo'] ?? 'Técnico de Soporte',
          'role': 'support',
          'content': 'TICKET RESUELTO: ${widget.ticket['solution']}',
          'timestamp': widget.ticket['resolutionDate'] ?? widget.ticket['lastUpdate'],
          'isInternal': false,
        },
    ];
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  // Helpers de estilo para badges
  // ────────────────────────────────────────────────────────────
  Color priorityColor(String p, ColorScheme cs) {
    switch (p) {
      case 'critical':
        return Colors.red;
      case 'high':
        return const Color(0xFF1C9985); // Usando el color de la app
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }

  // ────────────────────────────────────────────────────────────
  // Acciones
  // ────────────────────────────────────────────────────────────
  void _handleSendMessage() {
    final txt = _replyCtrl.text.trim();
    if (txt.isEmpty) return;
    
    setState(() {
      final now = DateTime.now();
      final timestamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      messages.add({
        'id': (messages.isEmpty ? 0 : (messages.last['id'] as int)) + 1,
        'author': 'Tú (Admin)',
        'role': 'support',
        'content': (isInternalNote ? 'Nota interna: ' : '') + txt,
        'timestamp': timestamp,
        'isInternal': isInternalNote,
      });
      
      // Actualizar el timestamp del ticket
      widget.ticket['lastUpdate'] = timestamp;
      
      _replyCtrl.clear();
      isInternalNote = false;
    });
    
    // Actualizar ticket en el sistema
    widget.onUpdateTicket(widget.ticket);
    
    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isInternalNote ? 'Nota interna añadida' : 'Mensaje enviado'),
        backgroundColor: const Color(0xFF1C9985),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleStatusChange(String newStatus) {
    setState(() {
      widget.ticket['status'] = newStatus;
      final now = DateTime.now();
      widget.ticket['lastUpdate'] = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      if (newStatus == 'resuelto') {
        widget.ticket['resolutionDate'] = widget.ticket['lastUpdate'];
      }
    });
    widget.onUpdateTicket(widget.ticket);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado cambiado a "$newStatus"'),
        backgroundColor: const Color(0xFF1C9985),
      ),
    );
  }

  void _handleAssignTicket(String assignTo) {
    setState(() {
      widget.ticket['assignedTo'] = assignTo;
    });
    widget.onUpdateTicket(widget.ticket);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Asignado a $assignTo'),
        backgroundColor: const Color(0xFF1C9985),
      ),
    );
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
    final isResolved = widget.ticket['status'] == 'resuelto';

    return Scaffold(
      body: Column(
        children: [
          // Header estilo barra superior
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
                    label: widget.ticket['priority'],
                    color: priorityColor(widget.ticket['priority'], cs),
                  ),
                  const SizedBox(width: 8),
                  _Badge(
                    label: widget.ticket['status'],
                    color: statusColor(widget.ticket['status']),
                  ),
                ],
              ),
            ),
          ),

          // Contenido
          Expanded(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isEditing) ...[
                                    Text(
                                      widget.ticket['title'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.ticket['description'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                  ] else ...[
                                    TextFormField(
                                      initialValue: widget.ticket['title'],
                                      decoration: const InputDecoration(labelText: 'Título'),
                                      onChanged: (v) => widget.ticket['title'] = v,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue: widget.ticket['description'],
                                      maxLines: 5,
                                      decoration: const InputDecoration(labelText: 'Descripción'),
                                      onChanged: (v) => widget.ticket['description'] = v,
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
                              icon: Icon(isEditing ? Icons.save : Icons.edit, size: 18),
                              label: Text(isEditing ? 'Guardar' : 'Editar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Detalles (usuario / ticket)
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 700;
                    final children = [
                      _InfoCard(
                        title: 'Información del Usuario',
                        icon: Icons.person_outline,
                        rows: [
                          ['Nombre:', widget.ticket['user']],
                          ['Email:', widget.ticket['userEmail']],
                          ['Categoría:', widget.ticket['category']],
                          ['Prioridad:', widget.ticket['priority']],
                        ],
                      ),
                      _InfoCard(
                        title: 'Información del Ticket',
                        icon: Icons.schedule,
                        rows: [
                          ['Asignado a:', widget.ticket['assignedTo'] ?? 'Sin asignar'],
                          ['Creado:', widget.ticket['createdAt']],
                          ['Actualizado:', widget.ticket['lastUpdate']],
                          if (isResolved && widget.ticket['resolutionDate'] != null)
                            ['Resuelto:', widget.ticket['resolutionDate']],
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
                            children: [children[0], const SizedBox(height: 12), children[1]],
                          );
                  },
                ),

                const SizedBox(height: 12),

                // Acciones rápidas
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
                        Text('Acciones Rápidas', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Determinar número de columnas según ancho disponible
                            final width = constraints.maxWidth;
                            final crossAxisCount = width < 400 ? 2 : 3; // 2 columnas en móvil, 3 en tablet+
                            
                            final actions = [
                              _ActionButton(
                                onPressed: () => _handleStatusChange('en proceso'),
                                icon: Icons.play_arrow,
                                label: 'En Proceso',
                                isPrimary: true,
                              ),
                              _ActionButton(
                                onPressed: () => _handleStatusChange('pendiente'),
                                icon: Icons.schedule,
                                label: 'Pendiente',
                                isPrimary: false,
                              ),
                              _ActionButton(
                                onPressed: () => _handleStatusChange('resuelto'),
                                icon: Icons.check_circle_outline,
                                label: 'Resolver',
                                isPrimary: false,
                              ),
                              if (isResolved)
                                _ActionButton(
                                  onPressed: _printVoucher,
                                  icon: Icons.print,
                                  label: 'Imprimir',
                                  isPrimary: true,
                                  color: Colors.green,
                                ),
                              _ActionButton(
                                onPressed: () => _handleAssignTicket('Yo (Admin)'),
                                icon: Icons.person_add_alt_1,
                                label: 'Asignarme',
                                isPrimary: false,
                              ),
                            ];
                            
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 2.5, // Ratio ancho:alto para botones
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: actions.length,
                              itemBuilder: (context, index) => actions[index],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Conversación + Voucher + Responder
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
                            const Icon(Icons.forum_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Conversación (${messages.length})',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...messages.map((m) {
                          final bool internal = m['isInternal'] as bool;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(internal ? 12 : 0),
                            decoration: BoxDecoration(
                              color: internal ? Colors.yellow.withOpacity(0.12) : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: (m['role'] == 'user')
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            m['author'],
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 8),
                                          _Badge(
                                            label: m['role'] == 'user' ? 'Usuario' : 'Soporte',
                                            color: m['role'] == 'user' 
                                                ? Colors.blue 
                                                : const Color(0xFF1C9985),
                                          ),
                                          if (internal) ...[
                                            const SizedBox(width: 6),
                                            const _Badge(label: 'Interno', color: Colors.amber),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        m['content'],
                                        style: const TextStyle(fontSize: 14),
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
                        }).toList(),

                        const Divider(height: 28),

                        // Sección Voucher (si resuelto)
                        if (isResolved) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.08),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green.shade800,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Ticket Resuelto',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.w600,
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
                                  icon: const Icon(Icons.print, size: 18),
                                  label: const Text('Imprimir Voucher'),
                                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 28),
                        ],

                        // Responder
                        Row(
                          children: [
                            Text('Responder al ticket', style: Theme.of(context).textTheme.titleSmall),
                            const Spacer(),
                            IconButton(
                              onPressed: () => FocusScope.of(context).unfocus(),
                              icon: const Icon(Icons.keyboard_hide, size: 20),
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
                          onChanged: (value) => setState(() {}), // Para actualizar el estado del botón
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu respuesta...',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.send),
                          ),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 600;
                            
                            if (isMobile) {
                              // Layout móvil: Todo en columnas
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Primera fila: Adjuntar y Nota interna
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(Icons.attach_file, size: 16),
                                          label: const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('Adjuntar', style: TextStyle(fontSize: 12)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isInternalNote,
                                            onChanged: (v) => setState(() => isInternalNote = v ?? false),
                                          ),
                                          const Text('Interno', style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Segunda fila: Botones de acción
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _replyCtrl.clear(),
                                          icon: const Icon(Icons.close, size: 16),
                                          label: const Text('Cancelar', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: FilledButton.icon(
                                          onPressed: _replyCtrl.text.trim().isEmpty ? null : () {
                                            _handleSendMessage();
                                            FocusScope.of(context).unfocus();
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: const Color(0xFF1C9985),
                                            disabledBackgroundColor: Colors.grey[300],
                                          ),
                                          icon: const Icon(Icons.send, size: 16),
                                          label: const Text('Enviar', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              // Layout desktop: Una sola fila
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.attach_file, size: 18),
                                        label: const Text('Adjuntar'),
                                      ),
                                      const SizedBox(width: 12),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isInternalNote,
                                            onChanged: (v) => setState(() => isInternalNote = v ?? false),
                                          ),
                                          const Text('Nota interna'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _replyCtrl.clear(),
                                        icon: const Icon(Icons.close, size: 18),
                                        label: const Text('Cancelar'),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton.icon(
                                        onPressed: _replyCtrl.text.trim().isEmpty ? null : () {
                                          _handleSendMessage();
                                          FocusScope.of(context).unfocus();
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFF1C9985),
                                          disabledBackgroundColor: Colors.grey[300],
                                        ),
                                        icon: const Icon(Icons.send, size: 18),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Subcomponentes
// ──────────────────────────────────────────────────────────────
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
  const _InfoCard({required this.title, required this.icon, required this.rows});
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
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            ...rows.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        r.first,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
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
                )),
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

  final VoidCallback onPressed;
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