import 'package:flutter/material.dart';
import 'tabs/admin_tickets_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_analytics_tab.dart';
import 'tabs/admin_settings_tab.dart';
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
        return const AdminDashboardTab();
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

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    const totalTickets = 147;
    const activeTickets = 23;
    const resolvedToday = 12;
    const totalUsers = 89;
    const avgResolutionTime = '2.4h';
    const satisfactionRate = 94;

    final recentTickets = [
      (
        id: 'TK-001',
        title: 'Problema con impresora HP',
        user: 'Juan Pérez',
        priority: 'high',
        status: 'abierto',
        createdAt: '10:30 AM',
      ),
      (
        id: 'TK-002',
        title: 'Error en sistema de facturación',
        user: 'María García',
        priority: 'critical',
        status: 'en proceso',
        createdAt: '09:15 AM',
      ),
      (
        id: 'TK-003',
        title: 'Solicitud de acceso a carpeta compartida',
        user: 'Carlos López',
        priority: 'medium',
        status: 'pendiente',
        createdAt: '08:45 AM',
      ),
    ];

    Color priorityColor(String p) {
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

    Color statusColor(String s) {
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

    return ListView(
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
                    value: '$totalTickets',
                    iconColor: Color(0xFF1C9985),
                    icon: Icons.confirmation_number_outlined,
                  ),
                  _SimpleStatCard(
                    title: 'Activos',
                    value: '$activeTickets',
                    iconColor: Colors.orange,
                    icon: Icons.warning_amber_outlined,
                  ),
                  _SimpleStatCard(
                    title: 'Resueltos Hoy',
                    value: '$resolvedToday',
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
                    value: '$totalTickets',
                    iconBg: Color(0xFF1C9985).withOpacity(0.1),
                    icon: const Icon(Icons.confirmation_number_outlined),
                    iconColor: Color(0xFF1C9985),
                    trendIcon: const Icon(Icons.trending_up, size: 16, color: Colors.green),
                    trendText: const Text('+12% vs ayer',
                        style: TextStyle(fontSize: 12, color: Colors.green)),
                  ),
                  _StatCard(
                    title: 'Tickets Activos',
                    value: '$activeTickets',
                    iconBg: Colors.orange.withOpacity(0.1),
                    icon: const Icon(Icons.warning_amber_outlined),
                    iconColor: Colors.orange,
                    trendIcon: const Icon(Icons.trending_down, size: 16, color: Colors.red),
                    trendText: const Text('-5% vs ayer',
                        style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                  _StatCard(
                    title: 'Resueltos Hoy',
                    value: '$resolvedToday',
                    iconBg: Colors.green.withOpacity(0.15),
                    icon: const Icon(Icons.check_circle_outline),
                    iconColor: Colors.green,
                    trendIcon: const Icon(Icons.trending_up, size: 16, color: Colors.green),
                    trendText: const Text('+8% vs ayer',
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

        // Recent Tickets - Responsive
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
                      onPressed: () {},
                      child: const Text('Ver Todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                                    Text(t.id,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    _Badge(label: t.priority, color: priorityColor(t.priority)),
                                    const SizedBox(width: 6),
                                    _Badge(label: t.status, color: statusColor(t.status)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(t.title),
                                const SizedBox(height: 2),
                                Text('${t.user} • ${t.createdAt}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey[600])),
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