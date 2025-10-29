import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthService.initializeSession();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoporteIT',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF1C9985, {
          50: Color(0xFFE3F2F0),
          100: Color(0xFFB9E0DA),
          200: Color(0xFF8BCCC2),
          300: Color(0xFF5CB8AA),
          400: Color(0xFF3AA898),
          500: Color(0xFF1C9985),
          600: Color(0xFF19917D),
          700: Color(0xFF158672),
          800: Color(0xFF117C68),
          900: Color(0xFF0A6B55),
        }),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
