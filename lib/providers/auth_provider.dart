import 'package:flutter/material.dart';
import 'package:si2/services/api_service.dart';
import 'package:si2/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userData;
  User? _user;
  User? get user => _user;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;

  // Verificar estado de autenticación al iniciar
  AuthProvider() {
    checkAuthStatus();
  }

  // Verificar si el usuario está autenticado
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _apiService.isAuthenticated();

      if (_isAuthenticated) {
        final userData = await _apiService.getUserInfo();
        if (userData != null) {
          _userData = userData;
          _user = User.fromJson(userData);
        }
      } else {
        _userData = null;
        _user = null;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _userData = null;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Iniciar sesión
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.signIn(email, password);

      if (success) {
        _isAuthenticated = true;
        _userData = await _apiService.getUserInfo();
        if (_userData != null) {
          _user = User.fromJson(_userData!);
        }
      } else {
        _isAuthenticated = false;
        _error = 'Credenciales inválidas';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isAuthenticated = false;
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registrar nuevo usuario
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.register(email, password);

      if (success) {
        _isAuthenticated = true;
        _userData = await _apiService.getUserInfo();
      } else {
        _error = 'Error al registrar el usuario';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Crear un cliente
  Future<bool> createClient(
    String email,
    String password,
    String nombre,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.createClient(email, password, nombre);

      _isLoading = false;
      if (!success) {
        _error = 'Error al crear el cliente';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.signOut();
      _isAuthenticated = false;
      _userData = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
