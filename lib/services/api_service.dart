import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/models/user_model.dart';
// Para TimeOfDay
import 'package:flutter/foundation.dart'; // Para kDebugMode

class ApiService {
  // URL del backend
  final String baseUrl =
      'https://juzgado-backend-production.up.railway.app/api';
  final storage = const FlutterSecureStorage();

  // ==================== MÉTODOS DE AUTENTICACIÓN ====================

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

  // Crear un usuario (ya existente)
  Future<bool> crearUsuario(Map<String, dynamic> userData) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/admin/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

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

  // ==================== MÉTODOS DE EXPEDIENTE ====================

  // Obtener todos los expedientes (para administradores)
  Future<List<Expediente>> getExpedientes() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('$baseUrl/expedientes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Expediente.fromJson(json)).toList();
      } else {
        // Datos de ejemplo si la API falla
        return _getDatosDePrueba();
      }
    } catch (e) {
      // Usar datos de ejemplo en caso de error
      return _getDatosDePrueba();
    }
  }

  // Obtener expedientes asignados al juez actual
  Future<List<Map<String, dynamic>>?> obtenerExpedientesPorJuez() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/expedientes/juez'),
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
        print('Error al obtener expedientes del juez: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener expedientes asignados al abogado actual
  Future<List<Map<String, dynamic>>?> obtenerExpedientesPorAbogado() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/expedientes/abogado'),
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
        print('Error al obtener expedientes del abogado: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener expedientes asignados al asistente actual
  Future<List<Map<String, dynamic>>?> obtenerExpedientesPorAsistente() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/expedientes/asistente'),
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
        print('Error al obtener expedientes del asistente: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener expedientes de un cliente
  Future<List<Map<String, dynamic>>?> obtenerExpedientesPorCliente() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/expedientes/cliente'),
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
        print('Error al obtener expedientes del cliente: ${e.toString()}');
      }
      return null;
    }
  }

  // Crear un nuevo expediente
  Future<bool> crearExpediente(Map<String, dynamic> expedienteData) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/expedientes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(expedienteData),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear expediente: ${e.toString()}');
      }
      return false;
    }
  }

  // Actualizar un expediente existente
  Future<bool> actualizarExpediente(
    int id,
    Map<String, dynamic> expedienteData,
  ) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/expedientes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(expedienteData),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar expediente: ${e.toString()}');
      }
      return false;
    }
  }

  // Cambiar el estado de un expediente
  Future<bool> cambiarEstadoExpediente(int id, String nuevoEstado) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/expedientes/$id/estado'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'estado': nuevoEstado}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al cambiar estado del expediente: ${e.toString()}');
      }
      return false;
    }
  }

  // Eliminar un expediente
  Future<bool> eliminarExpediente(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/expedientes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar expediente: ${e.toString()}');
      }
      return false;
    }
  }

  // Obtener detalles de un expediente específico
  Future<Map<String, dynamic>?> obtenerExpediente(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/expedientes/$id'),
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
        print('Error al obtener expediente: ${e.toString()}');
      }
      return null;
    }
  }

  // ==================== MÉTODOS DE AUDIENCIA ====================

  // Obtener todas las audiencias (para administradores)
  Future<List<Map<String, dynamic>>?> obtenerTodasAudiencias() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/audiencias'),
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
        print('Error al obtener audiencias: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener audiencias del juez actual
  Future<List<Map<String, dynamic>>?> obtenerAudienciasPorJuez() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/audiencias/juez'),
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
        print('Error al obtener audiencias del juez: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener audiencias del abogado actual
  Future<List<Map<String, dynamic>>?> obtenerAudienciasPorAbogado() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/audiencias/abogado'),
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
        print('Error al obtener audiencias del abogado: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener audiencias del asistente actual
  Future<List<Map<String, dynamic>>?> obtenerAudienciasPorAsistente() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/audiencias/asistente'),
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
        print('Error al obtener audiencias del asistente: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener audiencias del cliente actual
  Future<List<Map<String, dynamic>>?> obtenerAudienciasPorCliente() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/audiencias/cliente'),
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
        print('Error al obtener audiencias del cliente: ${e.toString()}');
      }
      return null;
    }
  }

  // Crear una nueva audiencia
  Future<bool> crearAudiencia(Map<String, dynamic> audienciaData) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/audiencias'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(audienciaData),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear audiencia: ${e.toString()}');
      }
      return false;
    }
  }

  // Actualizar una audiencia existente
  Future<bool> actualizarAudiencia(
    int id,
    Map<String, dynamic> audienciaData,
  ) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/audiencias/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(audienciaData),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar audiencia: ${e.toString()}');
      }
      return false;
    }
  }

  // Cancelar una audiencia
  Future<bool> cancelarAudiencia(int id, String motivo) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/audiencias/$id/cancelar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'motivo': motivo}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al cancelar audiencia: ${e.toString()}');
      }
      return false;
    }
  }

  // Confirmar asistencia a una audiencia
  Future<bool> confirmarAsistenciaAudiencia(
    int id,
    List<int> asistentes,
  ) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/audiencias/$id/asistencia'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'asistentes': asistentes}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al confirmar asistencia: ${e.toString()}');
      }
      return false;
    }
  }

  // Registrar observaciones post-audiencia
  Future<bool> registrarObservacionesAudiencia(
    int id,
    String observaciones,
  ) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/audiencias/$id/observaciones'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'observaciones': observaciones}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al registrar observaciones: ${e.toString()}');
      }
      return false;
    }
  }

  // Registrar resolución de una audiencia
  Future<bool> registrarResolucion(int id, String resolucion) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/audiencias/$id/resolucion'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'resolucion': resolucion}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al registrar resolución: ${e.toString()}');
      }
      return false;
    }
  }

  // Obtener detalles de una audiencia específica
  Future<Map<String, dynamic>?> obtenerAudiencia(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/audiencias/$id'),
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
        print('Error al obtener audiencia: ${e.toString()}');
      }
      return null;
    }
  }

  // ==================== MÉTODOS DE SEGUIMIENTO ====================

  // Obtener todos los seguimientos (para administradores)
  Future<List<Map<String, dynamic>>?> obtenerTodosSeguimientos() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/seguimientos'),
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
        print('Error al obtener seguimientos: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener seguimientos asignados al juez actual
  Future<List<Map<String, dynamic>>?> obtenerSeguimientosPorJuez() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/seguimientos/juez'),
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
        print('Error al obtener seguimientos del juez: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener seguimientos asignados al abogado actual
  Future<List<Map<String, dynamic>>?> obtenerSeguimientosPorAbogado() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/seguimientos/abogado'),
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
        print('Error al obtener seguimientos del abogado: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener seguimientos asignados al asistente actual
  Future<List<Map<String, dynamic>>?> obtenerSeguimientosPorAsistente() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/seguimientos/asistente'),
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
        print('Error al obtener seguimientos del asistente: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener seguimientos de un cliente
  Future<List<Map<String, dynamic>>?> obtenerSeguimientosPorCliente() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/seguimientos/cliente'),
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
        print('Error al obtener seguimientos del cliente: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener seguimientos por expediente
  Future<List<Map<String, dynamic>>?> obtenerSeguimientosPorExpediente(
    int expedienteId,
  ) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/seguimientos/expediente/$expedienteId'),
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
        print('Error al obtener seguimientos por expediente: ${e.toString()}');
      }
      return null;
    }
  }

  // Crear un nuevo seguimiento
  Future<bool> crearSeguimiento(Map<String, dynamic> seguimientoData) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/seguimientos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(seguimientoData),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear seguimiento: ${e.toString()}');
      }
      return false;
    }
  }

  // Actualizar un seguimiento existente
  Future<bool> actualizarSeguimiento(
    int id,
    Map<String, dynamic> seguimientoData,
  ) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/seguimientos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(seguimientoData),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar seguimiento: ${e.toString()}');
      }
      return false;
    }
  }

  // Marcar tarea como completada
  Future<bool> marcarTareaCompletada(int id, String resultado) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/seguimientos/$id/completar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'resultado': resultado}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al marcar tarea como completada: ${e.toString()}');
      }
      return false;
    }
  }

  // Eliminar un seguimiento
  Future<bool> eliminarSeguimiento(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/seguimientos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar seguimiento: ${e.toString()}');
      }
      return false;
    }
  }

  // Obtener detalles de un seguimiento específico
  Future<Map<String, dynamic>?> obtenerSeguimiento(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/seguimientos/$id'),
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
        print('Error al obtener seguimiento: ${e.toString()}');
      }
      return null;
    }
  }

  // ==================== MÉTODOS DE NOTIFICACIÓN ====================

  // Obtener notificaciones del usuario actual
  Future<List<Map<String, dynamic>>?> obtenerNotificaciones() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/notificaciones'),
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
        print('Error al obtener notificaciones: ${e.toString()}');
      }
      return null;
    }
  }

  // Marcar notificación como leída
  Future<bool> marcarNotificacionLeida(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/notificaciones/$id/leida'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al marcar notificación como leída: ${e.toString()}');
      }
      return false;
    }
  }

  // Marcar todas las notificaciones como leídas
  Future<bool> marcarTodasNotificacionesLeidas() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/notificaciones/marcar-todas-leidas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print(
          'Error al marcar todas las notificaciones como leídas: ${e.toString()}',
        );
      }
      return false;
    }
  }

  // Enviar una notificación (solo juez o administrador)
  Future<bool> enviarNotificacion(Map<String, dynamic> notificacionData) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/notificaciones'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(notificacionData),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al enviar notificación: ${e.toString()}');
      }
      return false;
    }
  }

  // Eliminar una notificación
  Future<bool> eliminarNotificacion(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/notificaciones/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar notificación: ${e.toString()}');
      }
      return false;
    }
  }

  // Obtener contador de notificaciones no leídas
  Future<int?> obtenerContadorNotificaciones() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/notificaciones/contador'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['contador'] as int;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener contador de notificaciones: ${e.toString()}');
      }
      return null;
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

  Future<Expediente> getExpedienteById(int expedienteId) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('$baseUrl/expedientes/$expedienteId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Expediente.fromJson(data);
      } else {
        // Si la API falla, buscar en datos de prueba
        return _getDatosDePruebaById(expedienteId);
      }
    } catch (e) {
      // Usar datos de ejemplo en caso de error
      return _getDatosDePruebaById(expedienteId);
    }
  }

  // Método auxiliar para obtener un expediente de prueba por ID
  Expediente _getDatosDePruebaById(int expedienteId) {
    final expedientes = _getDatosDePrueba();
    final expediente = expedientes.firstWhere(
      (exp) => exp.id == expedienteId,
      orElse: () => expedientes[0], // Devolver el primero si no encuentra
    );
    return expediente;
  }

  // Método auxiliar para datos de prueba
  List<Expediente> _getDatosDePrueba() {
    final now = DateTime.now();

    return [
      Expediente(
        id: 1,
        numero: 'EXP-2025-001',
        titulo: 'Caso de Divorcio',
        descripcion: 'Proceso de divorcio por mutuo acuerdo entre las partes',
        fechaApertura: now.subtract(Duration(days: 30)),
        estado: 'Abierto',
        tipo: 'Civil',
        cliente: User(
          id: 101,
          nombre: 'Juan',
          apellido: 'Pérez',
          email: 'juan.perez@example.com',
          rol: 'Cliente',
        ),
        juez: User(
          id: 102,
          nombre: 'María',
          apellido: 'Gómez',
          email: 'maria.gomez@example.com',
          rol: 'Juez',
        ),
        abogado: User(
          id: 103,
          nombre: 'Carlos',
          apellido: 'Rodríguez',
          email: 'carlos.rodriguez@example.com',
          rol: 'Abogado',
        ),
      ),
      Expediente(
        id: 2,
        numero: 'EXP-2025-002',
        titulo: 'Demanda Laboral',
        descripcion:
            'Demanda por despido injustificado y cobro de prestaciones',
        fechaApertura: now.subtract(Duration(days: 60)),
        estado: 'En resolución',
        tipo: 'Laboral',
        cliente: User(
          id: 104,
          nombre: 'Ana',
          apellido: 'Martínez',
          email: 'ana.martinez@example.com',
          rol: 'Cliente',
        ),
        juez: User(
          id: 105,
          nombre: 'Roberto',
          apellido: 'Díaz',
          email: 'roberto.diaz@example.com',
          rol: 'Juez',
        ),
        abogado: User(
          id: 103,
          nombre: 'Carlos',
          apellido: 'Rodríguez',
          email: 'carlos.rodriguez@example.com',
          rol: 'Abogado',
        ),
      ),
      Expediente(
        id: 3,
        numero: 'EXP-2025-003',
        titulo: 'Sucesión Testamentaria',
        descripcion: 'Trámite de sucesión testamentaria de bienes inmuebles',
        fechaApertura: now.subtract(Duration(days: 90)),
        estado: 'Cerrado',
        fechaCierre: now.subtract(Duration(days: 10)),
        tipo: 'Civil',
        cliente: User(
          id: 106,
          nombre: 'Laura',
          apellido: 'Sánchez',
          email: 'laura.sanchez@example.com',
          rol: 'Cliente',
        ),
        juez: User(
          id: 102,
          nombre: 'María',
          apellido: 'Gómez',
          email: 'maria.gomez@example.com',
          rol: 'Juez',
        ),
        abogado: User(
          id: 103,
          nombre: 'Carlos',
          apellido: 'Rodríguez',
          email: 'carlos.rodriguez@example.com',
          rol: 'Abogado',
        ),
      ),
    ];
  }
}
