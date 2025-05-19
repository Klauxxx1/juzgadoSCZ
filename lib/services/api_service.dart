import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:si2/models/AuthResponse_model.dart';
// Para TimeOfDay
import 'package:flutter/foundation.dart'; // Para kDebugMode

class ApiService {
  // URL del backend
  final String baseUrl =
      'https://si2backendjuzgado-production.up.railway.app/'; //api nuevo backend de ANTHONY
  final storage = const FlutterSecureStorage();

  // ==================== MÉTODOS DE AUTENTICACIÓN ====================

  // Inicio de sesión
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = AuthResponse.fromJson(jsonDecode(response.body));
      if (response.statusCode == 200) {
        await storage.write(key: 'jwt_token', value: data.token);
        return data;
      }
      throw Exception('Error en la autenticación: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) {
        print('Error en signIn: ${e.toString()}');
      }
      throw Exception('Error en la autenticación: ${e.toString()}');
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
          'Content-Type': 'application/json', //Sos animal ermano
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

  // Método para solicitar reseteo de contraseña
  Future<bool> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error en resetPassword: ${e.toString()}');
      }
      return false;
    }
  }

  // ==================== MÉTODOS DE USUARIO ====================

  // Métodos de administración de usuarios (ya existentes)
  Future<List<Map<String, dynamic>>?> obtenerTodosLosUsuarios() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/admin/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener usuarios: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener usuarios por rol
  Future<List<Map<String, dynamic>>?> obtenerUsuariosPorRol(String rol) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/rol/$rol'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener usuarios por rol: ${e.toString()}');
      }
      return null;
    }
  }

  // Crear un usuario (modificado)
  Future<bool> crearUsuario(Map<String, dynamic> userData) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      // Obtener el rol para determinar qué endpoint usar
      final String rol = userData['rol'];
      String endpoint;

      // Seleccionar el endpoint adecuado según las imágenes de tu backend
      switch (rol) {
        case 'Administrador':
          endpoint = '$baseUrl/crearAdministrador';
          break;
        case 'Juez':
          endpoint = '$baseUrl/crearJuez';
          break;
        case 'Abogado':
          endpoint = '$baseUrl/crearAbogado';
          break;
        case 'Cliente':
          endpoint = '$baseUrl/crearCliente';
          break;
        default:
          throw Exception('Rol no válido');
      }

      if (kDebugMode) {
        print('Enviando datos a: $endpoint');
        print('Datos: ${jsonEncode(userData)}');
      }

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      if (kDebugMode) {
        print('Respuesta: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response.body}');
      }

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear usuario: ${e.toString()}');
      }
      return false;
    }
  }

  // Actualizar un usuario (ya existente)
  Future<bool> actualizarUsuario(int id, Map<String, dynamic> userData) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/admin/usuarios/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar usuario: ${e.toString()}');
      }
      return false;
    }
  }

  // Eliminar un usuario (ya existente)
  Future<bool> eliminarUsuario(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/usuarios/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar usuario: ${e.toString()}');
      }
      return false;
    }
  }

  // Obtener detalles de un usuario específico
  Future<Map<String, dynamic>?> obtenerUsuario(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$id'),
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
        print('Error al obtener usuario: ${e.toString()}');
      }
      return null;
    }
  }

  // Cambiar contraseña
  Future<bool> cambiarContrasena(
    int id,
    String contrasenaActual,
    String nuevaContrasena,
  ) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/$id/cambiar-contrasena'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'contrasenaActual': contrasenaActual,
          'nuevaContrasena': nuevaContrasena,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al cambiar contraseña: ${e.toString()}');
      }
      return false;
    }
  }
  // ==================== OTROS MÉTODOS ====================

  // Crear un nuevo cliente (servicio heredado)
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

  // Añadir este método al ApiService:

  // Método auxiliar para datos de prueba
}
