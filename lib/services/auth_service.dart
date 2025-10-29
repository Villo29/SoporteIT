import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String _tokenKey = 'access_token';
  static const String _roleKey = 'user_role';
  static const String _emailKey = 'user_email';
  static const String _sessionActiveKey = 'session_active';
  
  // Variables en memoria para acceso rápido
  static String? _currentToken;
  static String? _currentRole;
  static String? _currentEmail;
  
  // ═══════════════════════════════════════════════════════
  // LOGIN - Conectar con API
  // ═══════════════════════════════════════════════════════
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Debug: imprimir detalles de la petición
      print('🔧 [AuthService] Iniciando login...');
      print('📤 [AuthService] URL: $baseUrl/auth/login');
      print('📤 [AuthService] Email: $email');
      print('📤 [AuthService] Password length: ${password.length}');
      
      final requestBody = {
        'email': email,
        'password': password,
      };
      
      print('📤 [AuthService] Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('📥 [AuthService] Response status: ${response.statusCode}');
      print('📥 [AuthService] Response headers: ${response.headers}');
      print('📥 [AuthService] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ [AuthService] Login exitoso, parseando respuesta...');
        
        // Extraer token y role de la respuesta de tu API
        final accessToken = responseData['access_token'];
        final role = responseData['role'];
        
        print('🔑 [AuthService] Token recibido: ${accessToken?.substring(0, 20)}...');
        print('👤 [AuthService] Role recibido: $role');
        
        // Guardar en variables de memoria para acceso rápido
        _currentToken = accessToken;
        _currentRole = role;
        _currentEmail = email;
        
        // Guardar en SharedPreferences para persistencia
        await _saveUserSession(
          token: accessToken,
          role: role,
          email: email,
        );
        
        print('💾 [AuthService] Datos guardados correctamente');
        
        return {
          'success': true,
          'data': {
            'user': {
              'email': email,
              'role': role,
            },
            'access_token': accessToken,
          },
          'message': 'Login exitoso',
        };
      } else {
        print('❌ [AuthService] Login falló con código ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        print('❌ [AuthService] Error detail: $errorData');
        
        return {
          'success': false,
          'error': 'Credenciales incorrectas',
          'message': errorData['detail'] ?? 'Error de autenticación',
        };
      }
    } catch (e) {
      print('💥 [AuthService] Exception occurred: $e');
      print('💥 [AuthService] Exception type: ${e.runtimeType}');
      
      return {
        'success': false,
        'error': 'Error de conexión',
        'message': 'No se pudo conectar con el servidor. Verifica tu conexión.',
      };
    }
  }
  
  // ═══════════════════════════════════════════════════════
  // GUARDAR SESIÓN DEL USUARIO
  // ═══════════════════════════════════════════════════════
  
  static Future<void> _saveUserSession({
    required String token,
    required String role,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_emailKey, email);
    await prefs.setBool(_sessionActiveKey, true);
  }
  
  // ═══════════════════════════════════════════════════════
  // OBTENER TOKEN
  // ═══════════════════════════════════════════════════════
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // ═══════════════════════════════════════════════════════
  // OBTENER DATOS DEL USUARIO
  // ═══════════════════════════════════════════════════════
  
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    final role = prefs.getString(_roleKey);
    
    if (email != null && role != null) {
      return {
        'email': email,
        'role': role,
      };
    }
    return null;
  }
  
  // ═══════════════════════════════════════════════════════
  // VERIFICAR SI ESTÁ LOGUEADO
  // ═══════════════════════════════════════════════════════
  
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userData = await getUserData();
    
    return token != null && userData != null;
  }
  
  // ═══════════════════════════════════════════════════════
  // OBTENER ROL DEL USUARIO
  // ═══════════════════════════════════════════════════════
  
  static Future<String?> getUserRole() async {
    final userData = await getUserData();
    return userData?['role'];
  }
  
  // ═══════════════════════════════════════════════════════
  // LOGOUT - Limpiar datos y cerrar sesión
  // ═══════════════════════════════════════════════════════
  
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Limpiar SharedPreferences
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_emailKey);
    await prefs.setBool(_sessionActiveKey, false);
    
    // Limpiar variables de memoria
    _currentToken = null;
    _currentRole = null;
    _currentEmail = null;
  }
  
  // ═══════════════════════════════════════════════════════
  // OBTENER TOKEN ACTUAL (desde memoria o storage)
  // ═══════════════════════════════════════════════════════
  
  static Future<String?> getCurrentToken() async {
    if (_currentToken != null) {
      return _currentToken;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    _currentToken = token;
    return token;
  }
  
  // ═══════════════════════════════════════════════════════
  // OBTENER ROL ACTUAL (desde memoria o storage)
  // ═══════════════════════════════════════════════════════
  
  static Future<String?> getCurrentRole() async {
    if (_currentRole != null) {
      return _currentRole;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_roleKey);
    _currentRole = role;
    return role;
  }
  
  // ═══════════════════════════════════════════════════════
  // OBTENER EMAIL ACTUAL (desde memoria o storage)
  // ═══════════════════════════════════════════════════════
  
  static Future<String?> getCurrentEmail() async {
    if (_currentEmail != null) {
      return _currentEmail;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    _currentEmail = email;
    return email;
  }
  
  // ═══════════════════════════════════════════════════════
  // CREAR HEADERS CON AUTORIZACIÓN PARA REQUESTS
  // ═══════════════════════════════════════════════════════
  
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getCurrentToken();
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // ═══════════════════════════════════════════════════════
  // INICIALIZAR SESIÓN (cargar desde storage al iniciar app)
  // ═══════════════════════════════════════════════════════
  
  static Future<void> initializeSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    _currentToken = prefs.getString(_tokenKey);
    _currentRole = prefs.getString(_roleKey);
    _currentEmail = prefs.getString(_emailKey);
  }
  
  // ═══════════════════════════════════════════════════════
  // VERIFICAR TOKEN - Validar si sigue siendo válido
  // ═══════════════════════════════════════════════════════
  
  static Future<bool> validateToken() async {
    try {
      final token = await getToken();
      
      if (token == null) return false;
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'), // Endpoint para verificar token
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // ═══════════════════════════════════════════════════════
  // REGISTER - Para futuros usuarios
  // ═══════════════════════════════════════════════════════
  
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Usuario registrado exitosamente',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': 'Error al registrar',
          'message': errorData['detail'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión',
        'message': 'No se pudo conectar con el servidor',
      };
    }
  }
}