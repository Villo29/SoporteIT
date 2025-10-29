import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../login_page.dart';

class AdminSettingsTab extends StatefulWidget {
  @override
  _AdminSettingsTabState createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _autoAssignment = true;
  String _defaultPriority = 'Medio';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración del Sistema',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            
            // System settings
            _buildSettingsSection(
              'Sistema',
              [
                _buildSwitchTile(
                  'Auto-asignación de tickets',
                  'Asignar tickets automáticamente a técnicos disponibles',
                  _autoAssignment,
                  (value) {
                    setState(() {
                      _autoAssignment = value;
                    });
                  },
                ),
                _buildDropdownTile(
                  'Prioridad por defecto',
                  'Prioridad asignada a nuevos tickets',
                  _defaultPriority,
                  ['Bajo', 'Medio', 'Alto', 'Crítico'],
                  (value) {
                    setState(() {
                      _defaultPriority = value!;
                    });
                  },
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Notifications
            _buildSettingsSection(
              'Notificaciones',
              [
                _buildSwitchTile(
                  'Notificaciones por email',
                  'Recibir notificaciones de tickets por correo',
                  _emailNotifications,
                  (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  'Notificaciones push',
                  'Recibir notificaciones en tiempo real',
                  _pushNotifications,
                  (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Management options
            _buildSettingsSection(
              'Gestión',
              [
                _buildActionTile(
                  'Exportar datos',
                  'Descargar reportes y estadísticas',
                  Icons.download,
                  () {
                    _showExportDialog(context);
                  },
                ),
                _buildActionTile(
                  'Respaldo del sistema',
                  'Crear copia de seguridad de datos',
                  Icons.backup,
                  () {
                    _showBackupDialog(context);
                  },
                ),
                _buildActionTile(
                  'Limpiar cache',
                  'Limpiar archivos temporales del sistema',
                  Icons.cleaning_services,
                  () {
                    _showCleanCacheDialog(context);
                  },
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Danger zone
            _buildSettingsSection(
              'Zona de peligro',
              [
                _buildActionTile(
                  'Restablecer configuración',
                  'Volver a la configuración por defecto',
                  Icons.restore,
                  () {
                    _showResetDialog(context);
                  },
                  isDestructive: true,
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Account section
            _buildSettingsSection(
              'Cuenta',
              [
                _buildActionTile(
                  'Cerrar Sesión',
                  'Salir de la aplicación',
                  Icons.logout,
                  () {
                    _showLogoutDialog(context);
                  },
                  isDestructive: true,
                ),
              ],
            ),
            
            SizedBox(height: 40),
            
            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _saveSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C9985),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Guardar Configuración',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1C9985),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuración guardada correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exportar Datos'),
        content: Text('¿Qué datos deseas exportar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar exportación
            },
            child: Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Crear Respaldo'),
        content: Text('¿Crear una copia de seguridad completa del sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar backup
            },
            child: Text('Crear Respaldo'),
          ),
        ],
      ),
    );
  }

  void _showCleanCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpiar Cache'),
        content: Text('Esto eliminará archivos temporales. ¿Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar limpieza
            },
            child: Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restablecer Configuración'),
        content: Text(
          'Esto restablecerá toda la configuración a valores por defecto. '
          '¿Estás seguro?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _emailNotifications = true;
      _pushNotifications = false;
      _autoAssignment = true;
      _defaultPriority = 'Medio';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuración restablecida'),
        backgroundColor: const Color(0xFF1C9985),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Cerrar Sesión'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await AuthService.logout();
                
                // Navegar al login
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cerrar sesión: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}