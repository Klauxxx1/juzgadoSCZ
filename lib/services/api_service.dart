import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // URL a la dirección del backend con mi IP por el emulador andorid
  final String baseUrl = 'http://192.168.100.104:3000/api';
  final storage = const FlutterSecureStorage();

  // Inicio de sesión
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Guarda el token en el almacenamiento seguro
        await storage.write(key: 'jwt_token', value: data['token']);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error en signIn: ${e.toString()}');
      }
      return false;
    }
  }

  // Obtener información del usuario autenticado
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/user/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener información del usuario: ${e.toString()}');
      }
      return null;
    }
  }

  // Cierre de sesión
  Future<void> signOut() async {
    await storage.delete(key: 'jwt_token');
  }

  // Verificar estado de autenticación
  Future<bool> isAuthenticated() async {
    final token = await storage.read(key: 'jwt_token');
    return token != null;
  }

  // Registro de usuario
  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Guarda el token en el almacenamiento seguro si tu API lo devuelve al registrar
        if (data['token'] != null) {
          await storage.write(key: 'jwt_token', value: data['token']);
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error en register: ${e.toString()}');
      }
      return false;
    }
  }

  // Crear un nuevo cliente
  Future<bool> createClient(
    String email,
    String password,
    String nombre,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nombre': nombre,
          'rol': 'cliente',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear cliente: ${e.toString()}');
      }
      return false;
    }
  }
}
