import 'package:flutter/material.dart';
import 'package:si2/models/AuthResponse_model.dart';
import 'package:si2/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

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
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLogged = await _apiService.isAuthenticated();

      if (isLogged) {
        final userData = await _apiService.getUserInfo();
        if (userData != null) {
          _user = User.fromJson(userData);
        }
        _error = null;
        notifyListeners();
        return true;
      } else {
        _user = null;
        _error = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _user = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para iniciar sesión
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _apiService.signIn(email, password);
      // if (success) {
      //   await checkAuthStatus(); // Cargar los datos del usuario después del login
      //   return true;
      // }
      // if(success.mensaje = )
      _user = User(
        idUsuario: success.user.idUsuario,
        nombre: success.user.nombre,
        apellido: success.user.apellido,
        correo: email,
        telefono: success.user.telefono,
        calle: success.user.calle,
        ciudad: success.user.ciudad,
        codigoPostal: success.user.codigoPostal,
        estadoUsuario: success.user.estadoUsuario,
        fechaRegistro: success.user.fechaRegistro,
        idRol: success.user.idRol,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.signOut();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar el perfil del usuario actual
  Future<bool> actualizarPerfil(Map<String, dynamic> userData) async {
    if (_user == null) {
      _error = "No hay usuario autenticado";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.actualizarUsuario(
        _user!.idUsuario!,
        userData,
      );
      switch (_user!.idRol) {
        case 'cliente':
          userData['rol'] = 'cliente';
          break;
        case 'abogado':
          userData['rol'] = 'abogado';
          break;
        case 'juez':
          userData['rol'] = 'juez';
          break;
        case 'asistente':
          userData['rol'] = 'asistente';
          break;
        case 'administrador':
          userData['rol'] = 'administrador';
          break;
        default:
          _error = "Rol de usuario no válido";
          return false;
      }
      if (success) {
        await checkAuthStatus(); // Recargar datos del usuario
        return true;
      } else {
        _error = "Error al actualizar perfil";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cambiar contraseña del usuario actual
  Future<bool> cambiarContrasena(
    String contrasenaActual,
    String nuevaContrasena,
  ) async {
    if (_user == null) {
      _error = "No hay usuario autenticado";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.cambiarContrasena(
        _user!.idUsuario!,
        contrasenaActual,
        nuevaContrasena,
      );

      if (success) {
        return true;
      } else {
        _error = "Error al cambiar la contraseña";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para solicitar reseteo de contraseña
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.resetPassword(email);

      if (success) {
        return true;
      } else {
        _error = "No se pudo enviar el correo de recuperación";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar este método al final de la clase AuthProvider

  // Método para testing y respaldo offline - solo usar en desarrollo
  void setUserForTesting(User user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  void actualizarUsuarioLocal(Map<String, dynamic> userData) {
    if (_user == null) return;

    // Crea un nuevo usuario con los datos actualizados
    _user = User(
      idUsuario: _user!.idUsuario,
      nombre: userData['nombre'] ?? _user!.nombre,
      apellido: userData['apellido'] ?? _user!.apellido,
      correo: userData['correo'] ?? _user!.correo,
      telefono: userData['telefono'] ?? _user!.telefono,
      calle: userData['calle'] ?? _user!.calle,
      ciudad: userData['ciudad'] ?? _user!.ciudad,
      codigoPostal: userData['codigo_postal'] ?? _user!.codigoPostal,
      estadoUsuario: _user!.estadoUsuario,
      fechaRegistro: _user!.fechaRegistro,
      idRol: _user!.idRol,
    );

    notifyListeners();
  }
}
