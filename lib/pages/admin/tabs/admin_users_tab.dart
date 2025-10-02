import 'package:flutter/material.dart';


class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key, this.onOpenUserDetail});
  final void Function(String userId)? onOpenUserDetail; // opcional para navegación

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String searchTerm = '';
  String filterRole = 'all';

  // Mock user data (idéntico a tu ejemplo)
  final List<Map<String, dynamic>> users = [
    {
      'id': 'USR-001',
      'name': 'Juan Pérez',
      'email': 'juan.perez@empresa.com',
      'phone': '+58 412-1234567',
      'department': 'Ventas',
      'role': 'user',
      'status': 'active',
      'lastLogin': '2024-01-15 16:30',
      'createdAt': '2023-06-15',
      'ticketsCreated': 12,
      'ticketsResolved': 8,
    },
    {
      'id': 'USR-002',
      'name': 'María García',
      'email': 'maria.garcia@empresa.com',
      'phone': '+58 424-2345678',
      'department': 'Contabilidad',
      'role': 'user',
      'status': 'active',
      'lastLogin': '2024-01-15 14:45',
      'createdAt': '2023-03-20',
      'ticketsCreated': 8,
      'ticketsResolved': 6,
    },
    {
      'id': 'USR-003',
      'name': 'Carlos López',
      'email': 'carlos.lopez@empresa.com',
      'phone': '+58 416-3456789',
      'department': 'Marketing',
      'role': 'user',
      'status': 'inactive',
      'lastLogin': '2024-01-10 09:20',
      'createdAt': '2023-08-10',
      'ticketsCreated': 5,
      'ticketsResolved': 4,
    },
    {
      'id': 'USR-004',
      'name': 'Ana García',
      'email': 'ana.garcia@empresa.com',
      'phone': '+58 414-4567890',
      'department': 'IT',
      'role': 'admin',
      'status': 'active',
      'lastLogin': '2024-01-15 17:15',
      'createdAt': '2022-11-05',
      'ticketsCreated': 3,
      'ticketsResolved': 45,
    },
    {
      'id': 'USR-005',
      'name': 'Luis Torres',
      'email': 'luis.torres@empresa.com',
      'phone': '+58 426-5678901',
      'department': 'IT',
      'role': 'support',
      'status': 'active',
      'lastLogin': '2024-01-15 16:50',
      'createdAt': '2023-01-12',
      'ticketsCreated': 2,
      'ticketsResolved': 38,
    },
  ];

  // ────────────────────────────────────────────────────────────
  // Helpers visuales (colores/labels)
  // ────────────────────────────────────────────────────────────
  Color roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red; // destructivo
      case 'support':
        return const Color(0xFF1C9985); // color del tema
      case 'user':
        return Colors.blue; // usuario
      default:
        return Colors.grey;
    }
  }

  String roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'support':
        return 'Soporte';
      case 'user':
        return 'Usuario';
      default:
        return 'Usuario';
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'inactive':
        return 'Inactivo';
      case 'suspended':
        return 'Suspendido';
      default:
        return 'Desconocido';
    }
  }

  String _initialsFrom(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((u) {
      final q = searchTerm.toLowerCase();
      final matchesSearch = u['name'].toString().toLowerCase().contains(q) ||
          u['email'].toString().toLowerCase().contains(q) ||
          u['department'].toString().toLowerCase().contains(q);
      final matchesRole = filterRole == 'all' || u['role'] == filterRole;
      return matchesSearch && matchesRole;
    }).toList();
  }

  // ────────────────────────────────────────────────────────────
  // Diálogo de creación de usuario (mock)
  // ────────────────────────────────────────────────────────────
  Future<void> _openCreateUserDialog() async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String phone = '';
    String department = '';
    String role = 'user';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Nuevo Usuario'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre Completo'),
                    onSaved: (v) => name = v?.trim() ?? '',
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (v) => email = v?.trim() ?? '',
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    onSaved: (v) => phone = v?.trim() ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Departamento'),
                    onSaved: (v) => department = v?.trim() ?? '',
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('Usuario')),
                      DropdownMenuItem(value: 'support', child: Text('Soporte')),
                      DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    ],
                    onChanged: (v) => role = v ?? 'user',
                    decoration: const InputDecoration(labelText: 'Rol'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  // Aquí iría la llamada al backend
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario creado (mock)')),
                  );
                }
              },
              child: const Text('Crear Usuario'),
            ),
          ],
        );
      },
    );
  }
  void handleChangeUserRole(String userId, String newRole) {
    debugPrint('Changing user $userId role to $newRole');
  }

  void handleToggleUserStatus(String userId) {
    debugPrint('Toggling status for user $userId');
  }

  @override
  Widget build(BuildContext context) {
    final total = users.length;
    final activos = users.where((u) => u['status'] == 'active').length;
    final admins = users.where((u) => u['role'] == 'admin').length;
    final soporte = users.where((u) => u['role'] == 'support').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header + botón nuevo usuario - Responsive
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 500;
            
            if (isMobile) {
              // Layout vertical para móvil
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestión de Usuarios',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Administra los usuarios y sus permisos en el sistema',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openCreateUserDialog,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Nuevo Usuario'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1C9985),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ],
              );
            }
            
            // Layout horizontal para escritorio
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gestión de Usuarios',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Administra los usuarios y sus permisos en el sistema',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _openCreateUserDialog,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Nuevo Usuario'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1C9985),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Búsqueda y filtro
        Card(
          elevation: 0,
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
                    hintText: 'Buscar por nombre, email o departamento...',
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
                        value: filterRole,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todos los roles')),
                          DropdownMenuItem(value: 'admin', child: Text('Administradores')),
                          DropdownMenuItem(value: 'support', child: Text('Soporte')),
                          DropdownMenuItem(value: 'user', child: Text('Usuarios')),
                        ],
                        onChanged: (v) => setState(() => filterRole = v ?? 'all'),
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
            final isMobile = constraints.maxWidth < 600;
            final crossAxisCount = isMobile ? 2 : 4;
            
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isMobile ? 1.6 : 1.4,
              ),
              children: [
                _SummaryCard(title: 'Total', value: '$total'),
                _SummaryCard(title: 'Activos', value: '$activos', valueColor: Colors.green),
                _SummaryCard(title: 'Admins', value: '$admins', valueColor: Colors.red),
                _SummaryCard(title: 'Soporte', value: '$soporte', valueColor: const Color(0xFF1C9985)),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Lista de usuarios
        if (filteredUsers.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No se encontraron usuarios que coincidan con los filtros.'),
              ),
            ),
          )
        else
          ...filteredUsers.map((u) => _UserCard(
                data: u,
                initials: _initialsFrom(u['name'] as String),
                roleColor: roleColor,
                roleLabel: roleLabel,
                statusColor: statusColor,
                statusLabel: statusLabel,
                onOpen: () => widget.onOpenUserDetail?.call(u['id'] as String),
                onChangeRole: (newRole) => handleChangeUserRole(u['id'] as String, newRole),
                onToggleStatus: () => handleToggleUserStatus(u['id'] as String),
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
      elevation: 2,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1C9985),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.data,
    required this.initials,
    required this.roleColor,
    required this.roleLabel,
    required this.statusColor,
    required this.statusLabel,
    required this.onOpen,
    required this.onChangeRole,
    required this.onToggleStatus,
  });

  final Map<String, dynamic> data;
  final String initials;
  final Color Function(String) roleColor;
  final String Function(String) roleLabel;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;
  final VoidCallback onOpen;
  final void Function(String role) onChangeRole;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final String name = data['name'];
    final String email = data['email'];
    final String phone = data['phone'];
    final String department = data['department'];
    final String role = data['role'];
    final String status = data['status'];
    final int created = data['ticketsCreated'];
    final int resolved = data['ticketsResolved'];
    final DateTime last = DateTime.tryParse(data['lastLogin']) ?? DateTime.now();
    final String lastAccess = last.toLocal().toString().split(' ').first;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 500;
            
            if (isMobile) {
              // Mobile layout: vertical stacking
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar and name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF1C9985),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name, 
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              children: [
                                _Badge(label: roleLabel(role), color: roleColor(role)),
                                _Badge(label: statusLabel(status), color: statusColor(status)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'perfil':
                              onOpen();
                              break;
                            case 'rolAdmin':
                              onChangeRole('admin');
                              break;
                            case 'toggle':
                              onToggleStatus();
                              break;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'perfil', child: Text('Ver Perfil')),
                          PopupMenuItem(value: 'rolAdmin', child: Text('Cambiar Rol')),
                          PopupMenuItem(value: 'toggle', child: Text('Activar/Desactivar')),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Contact info
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.grey[600],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.mail_outline, size: 14),
                          const SizedBox(width: 4),
                          Flexible(child: Text(email)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.phone, size: 14),
                          const SizedBox(width: 4),
                          Text(phone),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.business, size: 14),
                          const SizedBox(width: 4),
                          Text(department),
                        ]),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$created', 
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C9985),
                            ),
                          ),
                          Text(
                            'Creados', 
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$resolved', 
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Resueltos', 
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined, 
                            size: 16, 
                            color: Colors.grey[600],
                          ),
                          Text(
                            lastAccess, 
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }
            
            // Desktop layout: original horizontal
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF1C9985),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                Text(
                                  name, 
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _Badge(label: roleLabel(role), color: roleColor(role)),
                                const SizedBox(width: 6),
                                _Badge(label: statusLabel(status), color: statusColor(status)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            DefaultTextStyle(
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Colors.grey[600],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(children: [
                                    const Icon(Icons.mail_outline, size: 14),
                                    const SizedBox(width: 4),
                                    Text(email),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.phone, size: 14),
                                    const SizedBox(width: 4),
                                    Text(phone),
                                  ]),
                                  const SizedBox(height: 4),
                                  Wrap(children: [
                                    Text(department),
                                    const SizedBox(width: 8),
                                    const Text('•'),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.calendar_today_outlined, size: 14),
                                    const SizedBox(width: 4),
                                    Text('Último acceso: $lastAccess'),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$created', 
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Creados', 
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$resolved', 
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Resueltos', 
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case 'perfil':
                            onOpen();
                            break;
                          case 'rolAdmin':
                            onChangeRole('admin');
                            break;
                          case 'toggle':
                            onToggleStatus();
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'perfil', child: Text('Ver Perfil')),
                        PopupMenuItem(value: 'rolAdmin', child: Text('Cambiar Rol')),
                        PopupMenuItem(value: 'toggle', child: Text('Activar/Desactivar')),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}