import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode

class ClienteService {
  // URL del backend
  final String baseUrl = 'http://192.168.100.104:3000/api';
  final storage = const FlutterSecureStorage();

  // Actualizar datos de un cliente
  Future<bool> actualizarCliente(
    String idCliente, {
    String? nombre,
    String? apellido,
    String? carnetIdentidad,
    String? email,
    String? password,
  }) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      // Crear el mapa de datos para actualizar, solo incluyendo campos no nulos
      Map<String, dynamic> clienteData = {};

      if (nombre != null) clienteData['nombre'] = nombre;
      if (apellido != null) clienteData['apellido'] = apellido;
      if (carnetIdentidad != null)
        clienteData['carnet_identidad'] = carnetIdentidad;
      if (email != null) clienteData['email'] = email;
      if (password != null) clienteData['password'] = password;

      if (kDebugMode) {
        print('Actualizando cliente ID: $idCliente');
        print('Datos: ${jsonEncode(clienteData)}');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/clientes/update/$idCliente'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(clienteData),
      );

      if (kDebugMode) {
        print('Respuesta: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar cliente: ${e.toString()}');
      }
      return false;
    }
  }

  // Método sobrecargado que acepta un mapa completo de datos
  Future<bool> actualizarClienteConMapa(
    String idCliente,
    Map<String, dynamic> clienteData,
  ) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      if (kDebugMode) {
        print('Actualizando cliente ID: $idCliente');
        print('Datos: ${jsonEncode(clienteData)}');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/clientes/update/$idCliente'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(clienteData),
      );

      if (kDebugMode) {
        print('Respuesta: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar cliente: ${e.toString()}');
      }
      return false;
    }
  }

  // Obtener datos de un cliente específico
  Future<Map<String, dynamic>?> obtenerCliente(String idCliente) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/clientes/$idCliente'),
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
        print('Error al obtener cliente: ${e.toString()}');
      }
      return null;
    }
  }

  // Obtener todos los clientes
  Future<List<Map<String, dynamic>>?> obtenerTodosLosClientes() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/clientes'),
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
        print('Error al obtener todos los clientes: ${e.toString()}');
      }
      return null;
    }
  }

  // Crear un nuevo cliente
  Future<bool> crearCliente(Map<String, dynamic> clienteData) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      if (kDebugMode) {
        print('Creando nuevo cliente');
        print('Datos: ${jsonEncode(clienteData)}');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/clientes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(clienteData),
      );

      if (kDebugMode) {
        print('Respuesta: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response.body}');
      }

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al crear cliente: ${e.toString()}');
      }
      return false;
    }
  }

  // Eliminar un cliente
  Future<bool> eliminarCliente(String idCliente) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/clientes/$idCliente'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar cliente: ${e.toString()}');
      }
      return false;
    }
  }
}
