import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tabs/admin_tickets_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_analytics_tab.dart';
import 'tabs/admin_settings_tab.dart';
import '../../services/auth_service.dart';
enum TabType { dashboard, tickets, users, noticias, settings }
enum ScreenType { main, ticketDetail, userDetail }

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  TabType activeTab = TabType.dashboard;
  ScreenType currentScreen = ScreenType.main;

  String selectedTicketId = '';
  String selectedUserId = '';
  void handleOpenTicketDetail(String ticketId) {
    setState(() {
      selectedTicketId = ticketId;
      currentScreen = ScreenType.ticketDetail;
    });
  }

  void handleOpenUserDetail(String userId) {
    setState(() {
      selectedUserId = userId;
      currentScreen = ScreenType.userDetail;
    });
  }

  void handleBackToMain() {
    setState(() {
      currentScreen = ScreenType.main;
      selectedTicketId = '';
      selectedUserId = '';
    });
  }

  Widget _renderContent() {
    switch (activeTab) {
      case TabType.dashboard:
        return AdminDashboardTab(onNavigateToTab: (tab) {
          setState(() => activeTab = tab);
        });
      case TabType.tickets:
        return AdminTicketsTab(onOpenTicketDetail: handleOpenTicketDetail);
      case TabType.users:
        return AdminUsersTab(onOpenUserDetail: handleOpenUserDetail);
      case TabType.noticias:
        return const AdminNoticiasTab();
      case TabType.settings:
        return AdminSettingsTabWrapper();
    }
  }

  Widget _renderScreen() {
    switch (currentScreen) {
      case ScreenType.ticketDetail:
        return TicketDetailScreen(
          ticketId: selectedTicketId,
          onBack: handleBackToMain,
        );
      case ScreenType.userDetail:
        return UserDetailScreen(
          userId: selectedUserId,
          onBack: handleBackToMain,
        );
      case ScreenType.main:
        return _MainScaffold(
          content: _renderContent(),
          bottomNav: _BottomNav(
            activeTab: activeTab,
            onChanged: (tab) => setState(() => activeTab = tab),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _renderScreen();
  }
}

class _MainScaffold extends StatelessWidget {
  const _MainScaffold({
    required this.content,
    required this.bottomNav,
  });

  final Widget content;
  final Widget bottomNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.white),
          child: content,
        ),
      ),
      bottomNavigationBar: bottomNav,
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.activeTab,
    required this.onChanged,
  });

  final TabType activeTab;
  final ValueChanged<TabType> onChanged;

  int get _currentIndex => TabType.values.indexOf(activeTab);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => onChanged(TabType.values[i]),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1C9985),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined, size: 24),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number_outlined, size: 24),
          label: 'Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined, size: 24),
          label: 'Usuarios',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined, size: 24),
          label: 'Noticias',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined, size: 24),
          label: 'Config',
        ),
      ],
    );
  }
}

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key, this.onNavigateToTab});
  
  final void Function(TabType)? onNavigateToTab;

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  List<Map<String, dynamic>> tickets = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  // Estadísticas calculadas
  int get totalTickets => tickets.length;
  int get activeTickets => tickets.where((t) => t['estado'] != 'resuelto').length;
  int get resolvedToday => tickets.where((t) => 
    t['estado'] == 'resuelto' && _isToday(t['fecha_creacion'])).length;
  
  // Tickets recientes (primeros 3)
  List<Map<String, dynamic>> get recentTickets => 
    tickets.take(3).toList();

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  bool _isToday(String? dateString) {
    if (dateString == null) return false;
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      return date.year == now.year &&
             date.month == now.month &&
             date.day == now.day;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadTickets() async {
    if (!mounted) return;
    
    try {
      print('🔄 [AdminDashboard] Cargando tickets...');
      
      final headers = await AuthService.getAuthHeaders();
      print('📤 [AdminDashboard] Headers: $headers');
      
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/tickets'),
        headers: headers,
      );
      
      print('📥 [AdminDashboard] Status: ${response.statusCode}');
      print('📥 [AdminDashboard] Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        
        if (mounted) {
          setState(() {
            tickets = data.map((ticket) => ticket as Map<String, dynamic>).toList();
            isLoading = false;
            hasError = false;
          });
        }
        
        print('✅ [AdminDashboard] Tickets cargados: ${tickets.length}');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ [AdminDashboard] Error: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  String _getPriorityLabel(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critica':
        return 'Crítica';
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return priority ?? 'N/A';
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'abierto':
        return 'Abierto';
      case 'en_proceso':
        return 'En Proceso';
      case 'pendiente':
        return 'Pendiente';
      case 'resuelto':
        return 'Resuelto';
      case 'cerrado':
        return 'Cerrado';
      default:
        return status ?? 'N/A';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Valores por defecto para métricas
    const totalUsers = 89;
    const avgResolutionTime = '2.4h';
    const satisfactionRate = 94;

    Color priorityColor(String? p) {
      switch (p?.toLowerCase()) {
        case 'critica':
          return Colors.red;
        case 'alta':
          return const Color(0xFFFF6B6B);
        case 'media':
          return Colors.orange;
        case 'baja':
          return const Color(0xFF1C9985);
        default:
          return Colors.grey;
      }
    }

    Color statusColor(String? s) {
      switch (s?.toLowerCase()) {
        case 'abierto':
          return const Color(0xFF1C9985);
        case 'en_proceso':
          return Colors.orange;
        case 'pendiente':
          return Colors.amber;
        case 'resuelto':
          return Colors.green;
        case 'cerrado':
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      color: const Color(0xFF1C9985),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
        // Greeting
        Text('¡Buen día, Administrador!',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Aquí tienes un resumen de la actividad del sistema',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 16),

        // Key Metrics - Responsive design
        LayoutBuilder(
          builder: (context, constraints) {
            // Determine if we're on mobile
            bool isMobile = constraints.maxWidth < 600;
            
            if (isMobile) {
              // Mobile: Simple grid with 2 columns, no trend data
              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                children: [
                  _SimpleStatCard(
                    title: 'Tickets Totales',
                    value: isLoading ? '...' : '$totalTickets',
                    iconColor: Color(0xFF1C9985),
                    icon: Icons.confirmation_number_outlined,
                  ),
                  _SimpleStatCard(
                    title: 'Activos',
                    value: isLoading ? '...' : '$activeTickets',
                    iconColor: Colors.orange,
                    icon: Icons.warning_amber_outlined,
                  ),
                  _SimpleStatCard(
                    title: 'Resueltos Hoy',
                    value: isLoading ? '...' : '$resolvedToday',
                    iconColor: Colors.green,
                    icon: Icons.check_circle_outline,
                  ),
                  _SimpleStatCard(
                    title: 'Usuarios',
                    value: '$totalUsers',
                    iconColor: Color(0xFF1C9985),
                    icon: Icons.group_outlined,
                  ),
                ],
              );
            } else {
              // Desktop: Full cards with trends
              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                children: [
                  _StatCard(
                    title: 'Tickets Totales',
                    value: isLoading ? '...' : '$totalTickets',
                    iconBg: Color(0xFF1C9985).withOpacity(0.1),
                    icon: const Icon(Icons.confirmation_number_outlined),
                    iconColor: Color(0xFF1C9985),
                    trendIcon: const Icon(Icons.trending_up, size: 16, color: Colors.green),
                    trendText: const Text('Datos en tiempo real',
                        style: TextStyle(fontSize: 12, color: Colors.green)),
                  ),
                  _StatCard(
                    title: 'Tickets Activos',
                    value: isLoading ? '...' : '$activeTickets',
                    iconBg: Colors.orange.withOpacity(0.1),
                    icon: const Icon(Icons.warning_amber_outlined),
                    iconColor: Colors.orange,
                    trendIcon: const Icon(Icons.priority_high, size: 16, color: Colors.orange),
                    trendText: const Text('Requieren atención',
                        style: TextStyle(fontSize: 12, color: Colors.orange)),
                  ),
                  _StatCard(
                    title: 'Resueltos Hoy',
                    value: isLoading ? '...' : '$resolvedToday',
                    iconBg: Colors.green.withOpacity(0.15),
                    icon: const Icon(Icons.check_circle_outline),
                    iconColor: Colors.green,
                    trendIcon: const Icon(Icons.today, size: 16, color: Colors.green),
                    trendText: const Text('Actualizados hoy',
                        style: TextStyle(fontSize: 12, color: Colors.green)),
                  ),
                  _StatCard(
                    title: 'Usuarios Totales',
                    value: '$totalUsers',
                    iconBg: Color(0xFF1C9985).withOpacity(0.15),
                    icon: const Icon(Icons.group_outlined),
                    iconColor: Color(0xFF1C9985),
                    trendIcon: const Icon(Icons.trending_up, size: 16, color: Colors.green),
                    trendText: const Text('+3 nuevos',
                        style: TextStyle(fontSize: 12, color: Colors.green)),
                  ),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 12),

        // Performance Metrics - Responsive
        LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            
            if (isMobile) {
              // Mobile: Hide performance metrics to save space
              return const SizedBox.shrink();
            } else {
              // Desktop: Show performance metrics
              return Column(
                children: [
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.8,
                    ),
          children: [
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Color(0xFF1C9985)),
                        const SizedBox(width: 8),
                        const Text('Tiempo Promedio de Resolución'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(avgResolutionTime,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Meta: < 4h',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: Color(0xFF1C9985)),
                        const SizedBox(width: 8),
                        const Text('Satisfacción del Usuario'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$satisfactionRate%',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Meta: > 90%',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }
          },
        ),

        LayoutBuilder(
          builder: (context, constraints) {
            return Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[300]!),
              ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tickets Recientes',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    OutlinedButton(
                      onPressed: () {
                        widget.onNavigateToTab?.call(TabType.tickets);
                      },
                      child: const Text('Ver Todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Mostrar loading, error o datos
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF1C9985),
                      ),
                    ),
                  )
                else if (hasError)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[600]),
                            const SizedBox(width: 8),
                            Text('Error al cargar tickets',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'No se pudieron cargar los datos del servidor',
                                style: TextStyle(color: Colors.red[600]),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadTickets,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else if (recentTickets.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.inbox_outlined, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('No hay tickets recientes'),
                      ],
                    ),
                  )
                else
                  ...recentTickets.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('#${t['id']?.toString() ?? 'N/A'}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 8),
                                      _Badge(
                                        label: _getPriorityLabel(t['prioridad']),
                                        color: priorityColor(t['prioridad']),
                                      ),
                                      const SizedBox(width: 6),
                                      _Badge(
                                        label: _getStatusLabel(t['estado']),
                                        color: statusColor(t['estado']),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(t['titulo'] ?? 'Sin título'),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${t['usuario']?['nombre'] ?? 'Usuario'} • ${_formatDate(t['fecha_creacion'])}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
            );
          },
        ),
      ],
      ),
    );
  }
}

class AdminNoticiasTab extends StatelessWidget {
  const AdminNoticiasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminNewsSettings();
  }
}

class AdminSettingsTabWrapper extends StatelessWidget {
  const AdminSettingsTabWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminSettingsTab();
  }
}
class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.onBack,
  });

  final String ticketId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket $ticketId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        backgroundColor: Color(0xFF1C9985),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionCard(
            title: 'Detalle',
            child: Text(
              'Información del ticket, estado, historial y acciones (asignar, cerrar, etc.).',
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({
    super.key,
    required this.userId,
    required this.onBack,
  });

  final String userId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuario $userId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        backgroundColor: Color(0xFF1C9985),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionCard(
            title: 'Detalle de usuario',
            child: Text('Perfil, roles, tickets asociados, métricas.'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
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

// Tarjeta simple para móvil
class _SimpleStatCard extends StatelessWidget {
  const _SimpleStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Tarjeta para KPIs con icono y tendencia
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.trendIcon,
    this.trendText,
  });

  final String title;
  final String value;
  final Widget icon;
  final Color iconBg;
  final Color iconColor;
  final Widget? trendIcon;
  final Widget? trendText;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(value,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(color: iconColor, size: 24),
                    child: icon,
                  ),
                ),
              ],
            ),
            if (trendIcon != null && trendText != null) ...[
              const SizedBox(height: 8),
              Row(children: [trendIcon!, const SizedBox(width: 6), trendText!]),
            ],
          ],
        ),
      ),
    );
  }
}