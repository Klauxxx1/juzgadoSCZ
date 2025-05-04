import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:si2/models/ExpedienteResponse.dart/ExpedienteGetResponse.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/models/user_model.dart';

class ExpedienteService {
  final String baseUrl =
      'https://juzgado-backend-production.up.railway.app/api';
  final storage = const FlutterSecureStorage();

  // ==================== MÉTODOS DE EXPEDIENTE ====================

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
  // Obtener un expediente por su número

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

  // Método auxiliar para obtener un expediente de prueba por ID
  Expediente _getDatosDePruebaById(int expedienteId) {
    final expedientes = _getDatosDePrueba();
    final expediente = expedientes.firstWhere(
      (exp) => exp.id == expedienteId,
      orElse: () => expedientes[0], // Devolver el primero si no encuentra
    );
    return expediente;
  }

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
}
