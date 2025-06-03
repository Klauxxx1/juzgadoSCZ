import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:si2/models/AudienciaResponse_model.dart';
import 'package:si2/models/AudienciaUsuariosResponse_model.dart';

class AudienciaService {
  // URL base desde archivo .env
  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
  final storage = const FlutterSecureStorage();

  // Obtener todas las audiencias de un usuario específico
  Future<List<AudienciaResponse>> obtenerAudienciasPorUsuario(
    int userId,
  ) async {
    try {
      // Obtener token de autenticación
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      if (kDebugMode) {
        print('Obteniendo audiencias para el usuario $userId');
      }

      // Realizar petición GET
      final response = await http.get(
        Uri.parse('$baseUrl/audiencias/$userId/usuario'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parsear la respuesta usando el modelo
        final List<dynamic> audienciasJson = json.decode(response.body);
        return audienciasJson
            .map((json) => AudienciaResponse.fromJson(json))
            .toList();
      } else {
        if (kDebugMode) {
          print(
            'Error al obtener audiencias: ${response.statusCode} - ${response.body}',
          );
        }
        throw Exception('Error al obtener audiencias: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción al obtener audiencias: $e');
      }
      throw Exception('Error al obtener audiencias: $e');
    }
  }

  Future<AudienciaUsuariosResponse> obtenerUsuariosPorAudiencia(
    int audienciaId,
  ) async {
    try {
      // Obtener token de autenticación
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      if (kDebugMode) {
        print('Obteniendo usuarios para la audiencia $audienciaId');
      }

      // Realizar petición GET
      final response = await http.get(
        Uri.parse('$baseUrl/audiencias/$audienciaId/audiencia'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parsear la respuesta usando el modelo
        final responseData = json.decode(response.body);
        return AudienciaUsuariosResponse.fromJson(responseData);
      } else {
        if (kDebugMode) {
          print(
            'Error al obtener usuarios de audiencia: ${response.statusCode} - ${response.body}',
          );
        }
        throw Exception(
          'Error al obtener usuarios de audiencia: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción al obtener usuarios de audiencia: $e');
      }
      throw Exception('Error al obtener usuarios de audiencia: $e');
    }
  }
}
