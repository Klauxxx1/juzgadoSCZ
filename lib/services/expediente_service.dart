import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:si2/models/ExpedienteResponse.dart/ExpedienteGetResponse.dart';

class ExpedienteService {
  final String baseUrl =
      'https://juzgado-backend-production.up.railway.app/api';
  final storage = const FlutterSecureStorage();

  // ==================== MÉTODOS DE EXPEDIENTE ====================

  _getDatosDePrueba() {
    return [
      ExpedienteGetResponse(
        numeroExpediente: 1,
        demandanteCarnet: '12345678',
        demandadoCarnet: '87654321',
        abogadoDemandanteCarnet: 'AB123456',
        abogadoDemandadoCarnet: 'AB876543',
        juezCarnet: 'JU123456',
        contenido: 'Contenido del expediente 1',
      ),
      ExpedienteGetResponse(
        numeroExpediente: 2,
        demandanteCarnet: '23456789',
        demandadoCarnet: '98765432',
        abogadoDemandanteCarnet: 'AB234567',
        abogadoDemandadoCarnet: 'AB987654',
        juezCarnet: 'JU234567',
        contenido: 'Contenido del expediente 2',
      ),
    ];
  }
  // Obtener un expediente por su número

  // Obtener todos los expedientes (para administradores)
  Future<List<ExpedienteGetResponse>> getExpedientes() async {
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
        return expedienteGetResponseFromJson(response.body);
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
}
