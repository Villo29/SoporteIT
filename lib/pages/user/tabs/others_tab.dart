import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../login_page.dart';

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

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performLogout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    // Mostrar SnackBar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cerrando sesión...'),
        backgroundColor: Colors.blue,
      ),
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    });
  }
}