import 'package:flutter/material.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/services/api_service.dart';

class ExpedienteProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  final ApiService _apiService = ApiService();

  List<Expediente> _expedientes = [];
  bool _isLoading = false;
  String? _error;
  Expediente? _expedienteSeleccionado;

  // Getters
  List<Expediente> get expedientes => _expedientes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Expediente? get expedienteSeleccionado => _expedienteSeleccionado;

  ExpedienteProvider(this._authProvider) {
    if (_authProvider != null && _authProvider.user != null) {
      cargarExpedientes();
    }
  }

  // Cargar expedientes según el rol del usuario
  Future<void> cargarExpedientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<Expediente> expedientesList =
          await _apiService.getExpedientes();
      _expedientes = expedientesList;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear un nuevo expediente (solo administrador o asistente)
  Future<bool> crearExpediente(Map<String, dynamic> expedienteData) async {
    if (_authProvider?.user == null ||
        (!_authProvider!.user!.isAdministrador &&
            !_authProvider.user!.isAsistente)) {
      _error = "No tienes permisos para esta acción";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.crearExpediente(expedienteData);
      if (success) {
        await cargarExpedientes();
        return true;
      } else {
        _error = "Error al crear el expediente";
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

  // Actualizar un expediente (solo administrador, juez o asistente)
  Future<bool> actualizarExpediente(
    int id,
    Map<String, dynamic> expedienteData,
  ) async {
    if (_authProvider?.user == null ||
        (!_authProvider!.user!.isAdministrador &&
            !_authProvider.user!.isJuez &&
            !_authProvider.user!.isAsistente)) {
      _error = "No tienes permisos para esta acción";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.actualizarExpediente(
        id,
        expedienteData,
      );
      if (success) {
        await cargarExpedientes();
        return true;
      } else {
        _error = "Error al actualizar el expediente";
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

  // Cambiar el estado de un expediente (solo juez o administrador)
  Future<bool> cambiarEstadoExpediente(int id, String nuevoEstado) async {
    if (_authProvider?.user == null ||
        (!_authProvider!.user!.isAdministrador &&
            !_authProvider.user!.isJuez)) {
      _error = "No tienes permisos para esta acción";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.cambiarEstadoExpediente(
        id,
        nuevoEstado,
      );
      if (success) {
        // Actualizar localmente el expediente seleccionado si es el mismo
        if (_expedienteSeleccionado != null &&
            _expedienteSeleccionado!.id == id) {
          await obtenerDetallesExpediente(id);
        }
        // Recargar la lista de expedientes
        await cargarExpedientes();
        return true;
      } else {
        _error = "Error al cambiar el estado del expediente";
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

  // Eliminar un expediente (solo administrador)
  Future<bool> eliminarExpediente(int id) async {
    if (_authProvider?.user == null || !_authProvider!.user!.isAdministrador) {
      _error = "No tienes permisos para esta acción";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.eliminarExpediente(id);
      if (success) {
        _expedientes.removeWhere((expediente) => expediente.id == id);
        if (_expedienteSeleccionado?.id == id) {
          _expedienteSeleccionado = null;
        }
        notifyListeners();
        return true;
      } else {
        _error = "Error al eliminar el expediente";
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

  // Obtener detalles de un expediente específico
  Future<void> obtenerDetallesExpediente(int expedienteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Expediente expediente = await _apiService.getExpedienteById(
        expedienteId,
      );
      _expedienteSeleccionado = expediente;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtrar expedientes por estado
  List<Expediente> filtrarPorEstado(String estado) {
    return _expedientes
        .where((expediente) => expediente.estado == estado)
        .toList();
  }

  // Filtrar expedientes por tipo
  List<Expediente> filtrarPorTipo(String tipo) {
    return _expedientes.where((expediente) => expediente.tipo == tipo).toList();
  }

  // Buscar expedientes
  List<Expediente> buscarExpedientes(String query) {
    query = query.toLowerCase();
    return _expedientes
        .where(
          (expediente) =>
              expediente.numero.toLowerCase().contains(query) ||
              expediente.titulo.toLowerCase().contains(query) ||
              expediente.descripcion.toLowerCase().contains(query),
        )
        .toList();
  }
}
