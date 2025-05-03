import 'package:flutter/material.dart';
import 'package:si2/models/seguimiento_model.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/services/api_service.dart';

class SeguimientoProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  final ApiService _apiService = ApiService();

  List<Seguimiento> _seguimientos = [];
  bool _isLoading = false;
  String? _error;
  Seguimiento? _seguimientoSeleccionado;

  // Getters
  List<Seguimiento> get seguimientos => _seguimientos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Seguimiento? get seguimientoSeleccionado => _seguimientoSeleccionado;

  SeguimientoProvider(this._authProvider) {
    if (_authProvider != null && _authProvider.user != null) {
      cargarSeguimientos();
    }
  }

  // Cargar seguimientos según el rol del usuario
  Future<void> cargarSeguimientos({int? expedienteId}) async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _authProvider!.user!;
      List<Map<String, dynamic>>? data;

      // Si se especifica un ID de expediente, cargar solo esos seguimientos
      if (expedienteId != null) {
        data = await _apiService.obtenerSeguimientosPorExpediente(expedienteId);
      } else {
        if (user.isAdministrador) {
          // Los administradores ven todos los seguimientos
          data = await _apiService.obtenerTodosSeguimientos();
        } else if (user.isJuez) {
          // Los jueces ven seguimientos de sus expedientes
          data = await _apiService.obtenerSeguimientosPorJuez();
        } else if (user.isAbogado) {
          // Los abogados ven sus seguimientos
          data = await _apiService.obtenerSeguimientosPorAbogado();
        } else if (user.isAsistente) {
          // Los asistentes ven los seguimientos que administran
          data = await _apiService.obtenerSeguimientosPorAsistente();
        } else if (user.isCliente) {
          // Los clientes ven seguimientos de sus expedientes
          data = await _apiService.obtenerSeguimientosPorCliente();
        }
      }

      if (data != null) {
        _seguimientos = data.map((json) => Seguimiento.fromJson(json)).toList();
      } else {
        _seguimientos = [];
      }
    } catch (e) {
      _error = e.toString();
      _seguimientos = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Crear un nuevo seguimiento (nota, tarea u observación)
  Future<bool> crearSeguimiento(Map<String, dynamic> seguimientoData) async {
    if (_authProvider?.user == null || (_authProvider!.user!.isCliente)) {
      _error = "No tienes permisos para esta acción";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.crearSeguimiento(seguimientoData);
      if (success) {
        // Si estamos viendo seguimientos de un expediente específico
        if (seguimientoData['expedienteId'] != null) {
          await cargarSeguimientos(
            expedienteId: seguimientoData['expedienteId'],
          );
        } else {
          await cargarSeguimientos();
        }
        return true;
      } else {
        _error = "Error al crear el seguimiento";
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

  // Actualizar un seguimiento
  Future<bool> actualizarSeguimiento(
    int id,
    Map<String, dynamic> seguimientoData,
  ) async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return false;
    }

    // Obtener el seguimiento actual para verificar permisos
    final seguimientoActual = _seguimientos.firstWhere(
      (s) => s.id == id,
      orElse:
          () => Seguimiento(
            expedienteId: 0,
            creadorId: 0,
            tipo: '',
            descripcion: '',
            fechaCreacion: DateTime.now(),
          ),
    );

    // Verificar permisos según el rol y la propiedad del seguimiento
    final user = _authProvider!.user!;
    final esCreador = seguimientoActual.creadorId == user.id;
    final esAsignado = seguimientoActual.asignadoId == user.id;

    if (!user.isAdministrador &&
        !esCreador &&
        !esAsignado &&
        !(user.isJuez && seguimientoActual.tipo == "Observación judicial")) {
      _error = "No tienes permisos para actualizar este seguimiento";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.actualizarSeguimiento(
        id,
        seguimientoData,
      );
      if (success) {
        await cargarSeguimientos(expedienteId: seguimientoActual.expedienteId);
        return true;
      } else {
        _error = "Error al actualizar el seguimiento";
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

  // Marcar tarea como completada
  Future<bool> marcarTareaCompletada(int id, String resultado) async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return false;
    }

    // Buscar la tarea actual
    final tarea = _seguimientos.firstWhere(
      (s) => s.id == id && s.tipo == "Tarea",
      orElse:
          () => Seguimiento(
            expedienteId: 0,
            creadorId: 0,
            tipo: '',
            descripcion: '',
            fechaCreacion: DateTime.now(),
          ),
    );

    // Verificar que sea una tarea y que el usuario tenga permisos
    if (tarea.id == null || tarea.tipo != "Tarea") {
      _error = "La tarea no existe";
      notifyListeners();
      return false;
    }

    final user = _authProvider!.user!;
    if (!user.isAdministrador &&
        tarea.asignadoId != user.id &&
        tarea.creadorId != user.id) {
      _error = "No tienes permisos para completar esta tarea";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.marcarTareaCompletada(id, resultado);
      if (success) {
        await cargarSeguimientos(expedienteId: tarea.expedienteId);
        return true;
      } else {
        _error = "Error al marcar la tarea como completada";
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

  // Eliminar un seguimiento (solo administrador o creador)
  Future<bool> eliminarSeguimiento(int id) async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return false;
    }

    // Buscar el seguimiento para verificar permisos
    final seguimiento = _seguimientos.firstWhere(
      (s) => s.id == id,
      orElse:
          () => Seguimiento(
            expedienteId: 0,
            creadorId: 0,
            tipo: '',
            descripcion: '',
            fechaCreacion: DateTime.now(),
          ),
    );

    // Verificar permisos
    final user = _authProvider!.user!;
    if (!user.isAdministrador && seguimiento.creadorId != user.id) {
      _error = "No tienes permisos para eliminar este seguimiento";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.eliminarSeguimiento(id);
      if (success) {
        _seguimientos.removeWhere((s) => s.id == id);
        if (_seguimientoSeleccionado?.id == id) {
          _seguimientoSeleccionado = null;
        }
        notifyListeners();
        return true;
      } else {
        _error = "Error al eliminar el seguimiento";
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

  // Obtener detalles de un seguimiento específico
  Future<void> obtenerDetallesSeguimiento(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final detalles = await _apiService.obtenerSeguimiento(id);
      if (detalles != null) {
        _seguimientoSeleccionado = Seguimiento.fromJson(detalles);
      } else {
        _seguimientoSeleccionado = null;
        _error = "No se encontró el seguimiento";
      }
    } catch (e) {
      _error = e.toString();
      _seguimientoSeleccionado = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filtrar por tipo de seguimiento
  List<Seguimiento> filtrarPorTipo(String tipo) {
    return _seguimientos
        .where((seguimiento) => seguimiento.tipo == tipo)
        .toList();
  }

  // Obtener tareas pendientes
  List<Seguimiento> get tareasPendientes {
    return _seguimientos
        .where((s) => s.tipo == "Tarea" && !s.completado)
        .toList();
  }

  // Obtener tareas completadas
  List<Seguimiento> get tareasCompletadas {
    return _seguimientos
        .where((s) => s.tipo == "Tarea" && s.completado)
        .toList();
  }

  // Obtener tareas atrasadas
  List<Seguimiento> get tareasAtrasadas {
    return _seguimientos
        .where((s) => s.tipo == "Tarea" && !s.completado && s.estaAtrasada)
        .toList();
  }

  // Filtrar por prioridad
  List<Seguimiento> filtrarPorPrioridad(int prioridad) {
    return _seguimientos.where((s) => s.prioridad == prioridad).toList();
  }
}
