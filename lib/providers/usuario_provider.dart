import 'package:flutter/material.dart';
import 'package:si2/models/AuthResponse_model.dart';

import 'package:si2/providers/auth_provider.dart';
import 'package:si2/services/api_service.dart';
import 'package:si2/services/user_service.dart';

class UsuarioProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  final ApiService _apiService = ApiService();

  List<User> _usuarios = [];
  bool _isLoading = false;
  String? _error;
  User? _usuarioSeleccionado;

  final UserService _userService = UserService();

  // Getters
  List<User> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get usuarioSeleccionado => _usuarioSeleccionado;

  UsuarioProvider(this._authProvider) {
    if (_authProvider != null && _authProvider.user?.isAdministrador == true) {
      cargarUsuarios();
    }
  }

  // Cargar todos los usuarios (solo administrador)
  Future<void> cargarUsuarios() async {
    if (_authProvider?.user?.isAdministrador != true) {
      _error = "No tienes permisos para esta acción";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.obtenerTodosLosUsuarios();
      if (data != null) {
        _usuarios = data.map((userData) => User.fromJson(userData)).toList();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _usuarios = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cargar usuarios por rol
  Future<void> cargarUsuariosPorRol(String rol) async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return;
    }

    // Solo administrador puede ver todos los roles
    // Jueces y asistentes pueden ver clientes y abogados
    final user = _authProvider!.user!;
    if (!user.isAdministrador &&
        !(user.isJuez || user.isAsistente) &&
        (rol != 'Cliente' && rol != 'Abogado')) {
      _error = "No tienes permisos para ver usuarios de este rol";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.obtenerUsuariosPorRol(rol);
      if (data != null) {
        _usuarios = data.map((userData) => User.fromJson(userData)).toList();
      } else {
        _usuarios = [];
      }
    } catch (e) {
      _error = e.toString();
      _usuarios = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Crear un nuevo usuario (solo administrador)
  Future<bool> crearUsuario(Map<String, dynamic> userData) async {
    if (_authProvider?.user?.isAdministrador != true) {
      _error = "No tienes permisos para esta acción";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.crearUsuario(userData);
      if (success) {
        await cargarUsuarios();
        return true;
      }
      _error = "Error al crear el usuario";
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar un usuario existente
  Future<bool> actualizarUsuario(int id, Map<String, dynamic> userData) async {
    // Verificar si el usuario actual puede editar al usuario objetivo
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return false;
    }

    final user = _authProvider!.user!;

    // El administrador puede editar a cualquiera
    // Un usuario normal solo puede editarse a sí mismo
    if (!user.isAdministrador && user.idUsuario != id) {
      _error = "No tienes permisos para editar este usuario";
      notifyListeners();
      return false;
    }

    // Si no es administrador, no puede cambiar el rol
    if (!user.isAdministrador && userData.containsKey('rol')) {
      _error = "No puedes cambiar el rol de usuario";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.actualizarUsuario(id, userData);
      if (success) {
        // Si es el administrador, recargar lista de usuarios
        if (user.isAdministrador) {
          await cargarUsuarios();
        }
        // Si el usuario está editando su propio perfil, actualizar el AuthProvider
        else if (user.idUsuario == id) {
          await _authProvider.checkAuthStatus();
        }

        // Si estábamos viendo este usuario, actualizar detalles
        if (_usuarioSeleccionado?.idUsuario == id) {
          await obtenerDetallesUsuario(id);
        }

        return true;
      } else {
        _error = "Error al actualizar el usuario";
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

  // Eliminar un usuario (solo administrador)
  Future<bool> eliminarUsuario(int id) async {
    if (_authProvider?.user?.isAdministrador != true) {
      _error = "No tienes permisos para esta acción";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.eliminarUsuario(id);
      if (success) {
        _usuarios.removeWhere((user) => user.idUsuario == id);

        if (_usuarioSeleccionado?.idUsuario == id) {
          _usuarioSeleccionado = null;
        }

        notifyListeners();
        return true;
      } else {
        _error = "Error al eliminar el usuario";
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

  // Obtener detalles de un usuario específico
  Future<void> obtenerDetallesUsuario(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final detalles = await _apiService.obtenerUsuario(id);
      if (detalles != null) {
        _usuarioSeleccionado = User.fromJson(detalles);
      } else {
        _usuarioSeleccionado = null;
        _error = "No se encontró el usuario";
      }
    } catch (e) {
      _error = e.toString();
      _usuarioSeleccionado = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cambiar contraseña del usuario
  Future<bool> cambiarContrasena(
    int id,
    String contrasenaActual,
    String nuevaContrasena,
  ) async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return false;
    }

    final user = _authProvider!.user!;

    // Solo el propio usuario o el administrador pueden cambiar la contraseña
    if (!user.isAdministrador && user.idUsuario != id) {
      _error = "No tienes permisos para cambiar esta contraseña";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.cambiarContrasena(
        id,
        contrasenaActual,
        nuevaContrasena,
      );

      if (success) {
        return true;
      } else {
        _error =
            "Error al cambiar la contraseña. Verifica la contraseña actual.";
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

  // Filtrar usuarios por rol
  List<User> filtrarPorRol(String rol) {
    return _usuarios.where((user) => user.idRol == rol).toList();
  }

  // Buscar usuarios
  List<User> buscarUsuarios(String query) {
    query = query.toLowerCase();
    return _usuarios
        .where(
          (user) =>
              user.nombre.toLowerCase().contains(query) ||
              user.apellido.toLowerCase().contains(query) ||
              user.correo.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<bool> editarPerfil(Map<String, dynamic> userData) async {
    // Verificar si hay un usuario autenticado
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return false;
    }

    final usuario = _authProvider!.user!;
    final int userId = usuario.idUsuario;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Usar el servicio de usuario para actualizar el perfil
      final success = await _userService.actualizarUsuario(userId, userData);

      if (success) {
        // Actualizar localmente sin hacer otra llamada al backend
        _authProvider!.actualizarUsuarioLocal(userData);

        // Si estábamos viendo este usuario, actualizar sus detalles localmente
        if (_usuarioSeleccionado?.idUsuario == userId) {
          // Actualiza _usuarioSeleccionado con los nuevos datos
          if (_usuarioSeleccionado != null) {
            _usuarioSeleccionado = User(
              idUsuario: _usuarioSeleccionado!.idUsuario,
              nombre: userData['nombre'] ?? _usuarioSeleccionado!.nombre,
              apellido: userData['apellido'] ?? _usuarioSeleccionado!.apellido,
              correo: userData['correo'] ?? _usuarioSeleccionado!.correo,
              telefono: userData['telefono'] ?? _usuarioSeleccionado!.telefono,
              calle: userData['calle'] ?? _usuarioSeleccionado!.calle,
              ciudad: userData['ciudad'] ?? _usuarioSeleccionado!.ciudad,
              codigoPostal:
                  userData['codigo_postal'] ??
                  _usuarioSeleccionado!.codigoPostal,
              estadoUsuario: _usuarioSeleccionado!.estadoUsuario,
              fechaRegistro: _usuarioSeleccionado!.fechaRegistro,
              idRol: _usuarioSeleccionado!.idRol,
            );
          }
        }

        return true;
      } else {
        _error = "No se pudo actualizar el perfil";
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
}
