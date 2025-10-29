import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../login_page.dart';
import '../../../services/auth_service.dart';

class OthersTab extends StatelessWidget {
  const OthersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.phone,
        'title': "Contacto Telefónico",
        'description': "Llamar al soporte",
        'action': () => _makePhoneCall(),
        'color': Colors.blue,
      },
      {
        'icon': Icons.email,
        'title': "Enviar Email",
        'description': "Contacto por correo",
        'action': () => _sendEmail(),
        'color': Colors.green,
      },
      {
        'icon': Icons.download,
        'title': "Descargas",
        'description': "Herramientas y software",
        'action': () => _openDownloads(),
        'color': Colors.orange,
      },
      {
        'icon': Icons.chat,
        'title': "Chat en Vivo",
        'description': "Soporte inmediato",
        'action': () => _openLiveChat(),
        'color': Colors.purple,
      },
      {
        'icon': Icons.security,
        'title': "Términos y Privacidad",
        'description': "Políticas legales",
        'action': () => _openTerms(),
        'color': Colors.grey,
      },
      {
        'icon': Icons.logout,
        'title': "Cerrar Sesión",
        'description': "Salir de la aplicación",
        'action': () => _logout(context),
        'color': Colors.red,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Otros',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Herramientas y recursos adicionales',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return _buildMenuCard(item, context);
                  },
                ),
                SizedBox(height: 24),
                _buildAppInfoCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> item, BuildContext context) {
    final isLogout = item['title'] == "Cerrar Sesión";
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => item['action'](),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isLogout ? Border.all(color: Colors.red, width: 1) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLogout ? Colors.red.withOpacity(0.1) : item['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'],
                  color: isLogout ? Colors.red : item['color'],
                  size: 18,
                ),
              ),
              SizedBox(height: 6),
              Text(
                item['title'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                item['description'],
                style: TextStyle(
                  fontSize: 10,
                  color: isLogout ? Colors.red.withOpacity(0.8) : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de la App',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Versión:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Última actualización:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '21 Sep 2025',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'VilloMAX',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Funciones para las acciones
  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+1234567890');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'No se puede realizar la llamada al número +1234567890';
      }
    } catch (e) {
      print('Error al realizar la llamada: $e');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'soporte@aditech.com',
      query: 'subject=Soporte Técnico - SoporteIT App&body=Hola, necesito ayuda con...',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'No se puede abrir la aplicación de email';
      }
    } catch (e) {
      print('Error al abrir email: $e');
    }
  }

  void _openDownloads() {
    // En una implementación real, aquí podrías abrir una URL de descargas
    print('Abriendo página de descargas...');
    // Ejemplo: launchUrl(Uri.parse('https://empresa.com/descargas'));
  }

  void _openLiveChat() {
    // En una implementación real, podrías abrir un chat web o navegador
    print('Iniciando chat en vivo...');
    // Ejemplo: launchUrl(Uri.parse('https://empresa.com/chat'));
  }

  void _openTerms() {

    print('Abriendo términos y condiciones...');
  }

  Future<void> _logout(BuildContext context) async {
    // Mostrar dialog de confirmación
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFF1C9985)),
              SizedBox(width: 8),
              Text('Cerrar Sesión'),
            ],
          ),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _performLogout(context);
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Mostrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Cerrando sesión...'),
            ],
          ),
          backgroundColor: Color(0xFF1C9985),
          duration: Duration(seconds: 1),
        ),
      );

      // Limpiar sesión con AuthService
      await AuthService.logout();

      // Esperar un momento
      await Future.delayed(const Duration(milliseconds: 800));

      if (context.mounted) {
        // Navegar al login eliminando todo el stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}