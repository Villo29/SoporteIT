import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key, this.onOpenUserDetail});
  final void Function(String userId)?
  onOpenUserDetail; // opcional para navegación

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String searchTerm = '';
  String filterRole = 'all';

  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<Map<String, dynamic>> _createEmployee({
    required String nombre,
    required String apellido,
    required String area,
    required String cargo,
    required String fechaNacimiento,
    required String correo,
    required String password,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/empleados/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nombre': nombre,
          'apellido': apellido,
          'area': area,
          'cargo': cargo,
          'fecha_nacimiento': fechaNacimiento,
          'correo': correo,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['ok'] == true) {
          return responseData;
        } else {
          throw Exception('Error en la respuesta del servidor');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Error ${response.statusCode}: ${errorData['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildTextFormField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    required void Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      onSaved: onSaved,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1C9985)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1C9985), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/empleados'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        if (mounted) {
          setState(() {
            // Mapear datos del API a formato esperado por la UI
            users = data
                .map((employee) => _mapApiEmployeeToUI(employee))
                .toList();
            isLoading = false;
            hasError = false;
          });
        }

        print('✅ [AdminUsers] Empleados cargados: ${users.length}');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ [AdminUsers] Error: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  Map<String, dynamic> _mapApiEmployeeToUI(Map<String, dynamic> apiEmployee) {
    return {
      'id': 'EMP-${apiEmployee['id_empleado']?.toString() ?? 'N/A'}',
      'name': '${apiEmployee['nombre'] ?? ''} ${apiEmployee['apellido'] ?? ''}'
          .trim(),
      'email': apiEmployee['correo'] ?? 'Sin email',
      'phone': 'N/A',
      'department': apiEmployee['area'] ?? 'Sin área',
      'role': 'empleado',
      'status': 'active',
      'lastLogin': 'N/A',
      'createdAt': _formatDate(apiEmployee['fecha_nacimiento']),
      'ticketsCreated': 0,
      'ticketsResolved': 0,
      'position': apiEmployee['cargo'] ?? 'Sin cargo',
      'birthDate': _formatDate(apiEmployee['fecha_nacimiento']),
      // Excluimos intencionalmente 'password' por seguridad
    };
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Color roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
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
      final matchesSearch =
          u['name'].toString().toLowerCase().contains(q) ||
          u['email'].toString().toLowerCase().contains(q) ||
          u['department'].toString().toLowerCase().contains(q);
      final matchesRole = filterRole == 'all' || u['role'] == filterRole;
      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> _openCreateUserDialog() async {
    final formKey = GlobalKey<FormState>();
    String nombre = '';
    String apellido = '';
    String correo = '';
    String area = '';
    String cargo = '';
    String fechaNacimiento = '';
    String password = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Nuevo Empleado'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextFormField(
                    label: 'Nombre',
                    icon: Icons.badge,
                    onSaved: (v) => nombre = v?.trim() ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    label: 'Apellido',
                    icon: Icons.badge_outlined,
                    onSaved: (v) => apellido = v?.trim() ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (v) => correo = v?.trim() ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Área'),
                    onSaved: (v) => area = v?.trim() ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Cargo'),
                    onSaved: (v) => cargo = v?.trim() ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Nacimiento (YYYY-MM-DD)',
                      hintText: '1999-02-11',
                    ),
                    onSaved: (v) => fechaNacimiento = v?.trim() ?? '',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      try {
                        DateTime.parse(v);
                        return null;
                      } catch (e) {
                        return 'Formato inválido (YYYY-MM-DD)';
                      }
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    onSaved: (v) => password = v?.trim() ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1C9985),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();

                  try {
                    // Mostrar loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1C9985),
                        ),
                      ),
                    );

                    // Crear empleado y obtener respuesta
                    final responseData = await _createEmployee(
                      nombre: nombre,
                      apellido: apellido,
                      area: area,
                      cargo: cargo,
                      fechaNacimiento: fechaNacimiento,
                      correo: correo,
                      password: password,
                    );
                    if (mounted) Navigator.pop(context);
                    if (mounted) Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Empleado creado exitosamente (ID: ${responseData['id_empleado']})',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }

                    // Recargar lista
                    _loadUsers();
                  } catch (e) {
                    // Cerrar loading
                    if (mounted) Navigator.pop(context);

                    // Mostrar error
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Crear Empleado'),
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
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1C9985)),
            SizedBox(height: 16),
            Text('Cargando empleados...'),
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
              'Error al cargar empleados',
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
              onPressed: _loadUsers,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final total = users.length;
    final activos = users.where((u) => u['status'] == 'active').length;
    final inactivos = total - activos;
    final sistemas = users
        .where(
          (u) =>
              u['area']?.toString().toLowerCase().contains('sistema') ?? false,
        )
        .length;

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: const Color(0xFF1C9985),
      child: ListView(
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
                    Text(
                      'Gestión de Usuarios',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Administra los usuarios y sus permisos en el sistema',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestión de Usuarios',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Administra los usuarios y sus permisos en el sistema',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
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
                  childAspectRatio: isMobile ? 1.8 : 1.6,
                ),
                children: [
                  _EnhancedSummaryCard(
                    title: 'Total Empleados',
                    value: '$total',
                    icon: Icons.people,
                    color: const Color(0xFF1C9985),
                    backgroundColor: const Color(0xFF1C9985).withOpacity(0.1),
                  ),
                  _EnhancedSummaryCard(
                    title: 'Activos',
                    value: '$activos',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                  _EnhancedSummaryCard(
                    title: 'Inactivos',
                    value: '$inactivos',
                    icon: Icons.cancel,
                    color: Colors.orange,
                    backgroundColor: Colors.orange.withOpacity(0.1),
                  ),
                  _EnhancedSummaryCard(
                    title: 'Área IT',
                    value: '$sistemas',
                    icon: Icons.computer,
                    color: Colors.blue,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
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
                  child: Text(
                    'No se encontraron usuarios que coincidan con los filtros.',
                  ),
                ),
              ),
            )
          else
            ...filteredUsers.map(
              (u) => _UserCard(
                data: u,
                initials: _initialsFrom(u['name'] as String),
                roleColor: roleColor,
                roleLabel: roleLabel,
                statusColor: statusColor,
                statusLabel: statusLabel,
                onOpen: () => widget.onOpenUserDetail?.call(u['id'] as String),
                onChangeRole: (newRole) =>
                    handleChangeUserRole(u['id'] as String, newRole),
                onToggleStatus: () => handleToggleUserStatus(u['id'] as String),
              ),
            ),
        ],
      ),
    );
  }
}

class _EnhancedSummaryCard extends StatelessWidget {
  const _EnhancedSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, backgroundColor.withOpacity(0.5)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
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
    final DateTime last =
        DateTime.tryParse(data['lastLogin']) ?? DateTime.now();
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
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              children: [
                                _Badge(
                                  label: roleLabel(role),
                                  color: roleColor(role),
                                ),
                                _Badge(
                                  label: statusLabel(status),
                                  color: statusColor(status),
                                ),
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
                          PopupMenuItem(
                            value: 'perfil',
                            child: Text('Ver Perfil'),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text('Activar/Desactivar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DefaultTextStyle(
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mail_outline, size: 14),
                            const SizedBox(width: 4),
                            Flexible(child: Text(email)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14),
                            const SizedBox(width: 4),
                            Text(phone),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.business, size: 14),
                            const SizedBox(width: 4),
                            Text(department),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.work, size: 14),
                            const SizedBox(width: 4),
                            Text(data['position'] ?? 'Sin cargo'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.cake, size: 14),
                            const SizedBox(width: 4),
                            Text(data['birthDate'] ?? 'N/A'),
                          ],
                        ),
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
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1C9985),
                                ),
                          ),
                          Text(
                            'Creados',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$resolved',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                          ),
                          Text(
                            'Resueltos',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey[600]),
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
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey[600]),
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
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                _Badge(
                                  label: roleLabel(role),
                                  color: roleColor(role),
                                ),
                                const SizedBox(width: 6),
                                _Badge(
                                  label: statusLabel(status),
                                  color: statusColor(status),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            DefaultTextStyle(
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: Colors.grey[600]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    children: [
                                      const Icon(Icons.mail_outline, size: 14),
                                      const SizedBox(width: 4),
                                      Text(email),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.phone, size: 14),
                                      const SizedBox(width: 4),
                                      Text(phone),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    children: [
                                      Text(department),
                                      const SizedBox(width: 8),
                                      const Text('•'),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.work, size: 14),
                                      const SizedBox(width: 4),
                                      Text(data['position'] ?? 'Sin cargo'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    children: [
                                      const Icon(Icons.cake, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Nacimiento: ${data['birthDate'] ?? 'N/A'}',
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Último acceso: $lastAccess'),
                                    ],
                                  ),
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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Creados',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$resolved',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Resueltos',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey[600]),
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
                        PopupMenuItem(
                          value: 'perfil',
                          child: Text('Ver Perfil'),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text('Activar/Desactivar'),
                        ),
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
