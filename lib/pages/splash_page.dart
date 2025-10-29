import 'package:flutter/material.dart';
import 'login_page.dart';
import 'user/user_home_page.dart';
import 'admin/admin_home_page.dart';
import '../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // Duración del splash

    // Verificar si hay una sesión activa
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // Si hay sesión activa, verificar el rol
      final userRole = await AuthService.getCurrentRole();

      if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
      }
    } else {
      // Si no hay sesión, ir al login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/ADITECH.png',
                width: 300,
                height: 300,
              ),
            ),

            const SizedBox(height: 40),

            // Título
            Text(
              'SoporteIT',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1C9985),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Sistema de Gestión de Soporte',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),

            const SizedBox(height: 40),

            // Loading indicator
            const CircularProgressIndicator(
              color: Color(0xFF1C9985),
              strokeWidth: 3,
            ),

            const SizedBox(height: 16),

            Text(
              'Verificando sesión...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
