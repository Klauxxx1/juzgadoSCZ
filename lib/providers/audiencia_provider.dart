/*import 'package:flutter/foundation.dart';
import 'package:si2/models/audiencia_model.dart';
import 'package:si2/services/api_service.dart';

class AudienciaProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Audiencia> _audiencias = [];
  List<Audiencia> _audienciasPorExpediente = []; // Añadimos esta propiedad
  bool _isLoading = false;
  String? _error;

  AudienciaProvider(param0);

  // Getters
  List<Audiencia> get audiencias => _audiencias;
  List<Audiencia> get audienciasPorExpediente =>
      _audienciasPorExpediente; // Añadimos este getter
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Método para cargar audiencias por expediente
  Future<void> cargarAudienciasPorExpediente(int expedienteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final audiencias = await _apiService.getAudienciasByExpediente(
        expedienteId,
      );
      _audienciasPorExpediente =
          audiencias; // Almacenar las audiencias filtradas
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _audienciasPorExpediente =
          []; // En caso de error, establecer como lista vacía
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Otros métodos existentes...
}*/
