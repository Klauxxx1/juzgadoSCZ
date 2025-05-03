import 'package:flutter/material.dart';
import 'package:si2/models/notificacion_model.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/services/api_service.dart';

class NotificacionProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  final ApiService _apiService = ApiService();

  List<Notificacion> _notificaciones = [];
  bool _isLoading = false;
  String? _error;
  int _noLeidas = 0;

  // Getters
  List<Notificacion> get notificaciones => _notificaciones;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get noLeidas => _noLeidas;

  NotificacionProvider(this._authProvider) {
    if (_authProvider != null && _authProvider.user != null) {
      cargarNotificaciones();
    }
  }

  // Cargar notificaciones del usuario actual
  Future<void> cargarNotificaciones() async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.obtenerNotificaciones();

      if (data != null) {
        _notificaciones =
            data.map((json) => Notificacion.fromJson(json)).toList();
        _noLeidas = _notificaciones.where((n) => !n.leida).length;
      } else {
        _notificaciones = [];
        _noLeidas = 0;
      }
    } catch (e) {
      _error = e.toString();
      _notificaciones = [];
      _noLeidas = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Marcar una notificación como leída
  Future<bool> marcarComoLeida(int id) async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.marcarNotificacionLeida(id);
      if (success) {
        // Actualizar localmente
        final index = _notificaciones.indexWhere((n) => n.id == id);
        if (index != -1) {
          final notificacion = _notificaciones[index];
          final notificacionActualizada = Notificacion(
            id: notificacion.id,
            destinatarioId: notificacion.destinatarioId,
            emisorId: notificacion.emisorId,
            titulo: notificacion.titulo,
            mensaje: notificacion.mensaje,
            tipo: notificacion.tipo,
            referenciaId: notificacion.referenciaId,
            referenciaTipo: notificacion.referenciaTipo,
            fechaCreacion: notificacion.fechaCreacion,
            leida: true,
            destinatario: notificacion.destinatario,
            emisor: notificacion.emisor,
          );

          _notificaciones[index] = notificacionActualizada;
          _noLeidas = _notificaciones.where((n) => !n.leida).length;
          notifyListeners();
        }
        return true;
      } else {
        _error = "Error al marcar la notificación como leída";
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

  // Marcar todas las notificaciones como leídas
  Future<bool> marcarTodasComoLeidas() async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return false;
    }

    if (_notificaciones.isEmpty || _noLeidas == 0) {
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.marcarTodasNotificacionesLeidas();
      if (success) {
        // Actualizar localmente todas las notificaciones
        _notificaciones =
            _notificaciones
                .map(
                  (n) => Notificacion(
                    id: n.id,
                    destinatarioId: n.destinatarioId,
                    emisorId: n.emisorId,
                    titulo: n.titulo,
                    mensaje: n.mensaje,
                    tipo: n.tipo,
                    referenciaId: n.referenciaId,
                    referenciaTipo: n.referenciaTipo,
                    fechaCreacion: n.fechaCreacion,
                    leida: true,
                    destinatario: n.destinatario,
                    emisor: n.emisor,
                  ),
                )
                .toList();

        _noLeidas = 0;
        return true;
      } else {
        _error = "Error al marcar las notificaciones como leídas";
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

  // Enviar una notificación (solo juez o administrador)
  Future<bool> enviarNotificacion(Map<String, dynamic> notificacionData) async {
    if (_authProvider?.user == null ||
        (!_authProvider!.user!.isAdministrador &&
            !_authProvider.user!.isJuez)) {
      _error = "No tienes permisos para enviar notificaciones oficiales";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.enviarNotificacion(notificacionData);
      if (success) {
        // No necesitamos recargar las notificaciones enviadas a otros usuarios
        return true;
      } else {
        _error = "Error al enviar la notificación";
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

  // Eliminar una notificación
  Future<bool> eliminarNotificacion(int id) async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.eliminarNotificacion(id);
      if (success) {
        // Actualizar localmente
        final notificacion = _notificaciones.firstWhere((n) => n.id == id);
        _notificaciones.removeWhere((n) => n.id == id);
        if (!notificacion.leida) {
          _noLeidas--;
        }
        notifyListeners();
        return true;
      } else {
        _error = "Error al eliminar la notificación";
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

  // Obtener notificaciones no leídas
  List<Notificacion> get notificacionesNoLeidas {
    return _notificaciones.where((n) => !n.leida).toList();
  }

  // Filtrar por tipo
  List<Notificacion> filtrarPorTipo(String tipo) {
    return _notificaciones.where((n) => n.tipo == tipo).toList();
  }

  // Verificar si hay notificaciones nuevas (para polling o refrescar)
  Future<bool> verificarNuevasNotificaciones() async {
    if (_authProvider?.user == null) {
      return false;
    }

    try {
      final contadorActual = await _apiService.obtenerContadorNotificaciones();
      if (contadorActual != null && contadorActual > _noLeidas) {
        await cargarNotificaciones();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
