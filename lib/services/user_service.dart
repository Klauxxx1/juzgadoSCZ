import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  // URL base fija en lugar de usar dotenv
  final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://192.168.100.104:3000/api';
  final storage = const FlutterSecureStorage();

  // Método PUT para actualizar usuario
  Future<bool> actualizarUsuario(int id, Map<String, dynamic> userData) async {
    try {
      // Obtener token de autenticación
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      if (kDebugMode) {
        print('Actualizando usuario $id con datos: ${jsonEncode(userData)}');
      }

      // Petición PUT
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      if (kDebugMode) {
        print(
          'Error en actualizar usuario: ${response.statusCode} - ${response.body}',
        );
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Excepción al actualizar usuario: $e');
      }
      return false;
    }
  }
}
