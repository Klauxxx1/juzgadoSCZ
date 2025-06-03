import 'package:flutter/material.dart';
import 'package:si2/models/AudienciaResponse_model.dart';
import 'package:si2/models/AudienciaUsuariosResponse_model.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/services/audiencia_service.dart';

class AudienciaProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  final AudienciaService _audienciaService = AudienciaService();

  List<AudienciaResponse> _audiencias = [];
  bool _isLoading = false;
  String? _error;
  AudienciaResponse? _audienciaSeleccionada;

  // Getters
  List<AudienciaResponse> get audiencias => _audiencias;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AudienciaResponse? get audienciaSeleccionada => _audienciaSeleccionada;

  AudienciaProvider(this._authProvider);

  // Cargar audiencias del usuario actual
  Future<void> cargarAudienciasUsuario() async {
    if (_authProvider?.user == null) {
      _error = "Usuario no autenticado";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authProvider!.user!.idUsuario;
      _audiencias = await _audienciaService.obtenerAudienciasPorUsuario(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AudienciaUsuariosResponse?> obtenerUsuariosAudiencia(
    int audienciaId,
  ) async {
    _isLoading = true;
    _error = null;
    try {
      final result = await _audienciaService.obtenerUsuariosPorAudiencia(
        audienciaId,
      );
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }
}
