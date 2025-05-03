import 'package:flutter/material.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/models/user_model.dart';

class Seguimiento {
  final int? id;
  final int expedienteId;
  final int creadorId;
  final String tipo; // "Nota", "Tarea", "Observación judicial"
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime? fechaLimite; // Para tareas
  final bool completado;
  final int? asignadoId; // Para tareas asignadas
  final String? resultado;
  final int? prioridad; // 1: baja, 2: media, 3: alta

  // Relaciones
  final Expediente? expediente;
  final User? creador;
  final User? asignado;

  Seguimiento({
    this.id,
    required this.expedienteId,
    required this.creadorId,
    required this.tipo,
    required this.descripcion,
    required this.fechaCreacion,
    this.fechaLimite,
    this.completado = false,
    this.asignadoId,
    this.resultado,
    this.prioridad,
    this.expediente,
    this.creador,
    this.asignado,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> json) {
    return Seguimiento(
      id: json['id'],
      expedienteId: json['expedienteId'],
      creadorId: json['creadorId'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaLimite:
          json['fechaLimite'] != null
              ? DateTime.parse(json['fechaLimite'])
              : null,
      completado: json['completado'] ?? false,
      asignadoId: json['asignadoId'],
      resultado: json['resultado'],
      prioridad: json['prioridad'],
      expediente:
          json['expediente'] != null
              ? Expediente.fromJson(json['expediente'])
              : null,
      creador: json['creador'] != null ? User.fromJson(json['creador']) : null,
      asignado:
          json['asignado'] != null ? User.fromJson(json['asignado']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expedienteId': expedienteId,
      'creadorId': creadorId,
      'tipo': tipo,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaLimite': fechaLimite?.toIso8601String(),
      'completado': completado,
      'asignadoId': asignadoId,
      'resultado': resultado,
      'prioridad': prioridad,
    };
  }

  // Verificar si es una tarea
  bool get esTarea => tipo == "Tarea";

  // Verificar si es una nota
  bool get esNota => tipo == "Nota";

  // Verificar si es una observación judicial
  bool get esObservacionJudicial => tipo == "Observación judicial";

  // Verificar si está atrasada (para tareas)
  bool get estaAtrasada {
    if (fechaLimite == null || completado) return false;
    return fechaLimite!.isBefore(DateTime.now());
  }

  // Formatear fecha para mostrar
  String get fechaLimiteFormateada {
    if (fechaLimite == null) return 'Sin fecha límite';
    return '${fechaLimite!.day}/${fechaLimite!.month}/${fechaLimite!.year}';
  }

  // Obtener texto de prioridad
  String get textoPrioridad {
    switch (prioridad) {
      case 1:
        return 'Baja';
      case 2:
        return 'Media';
      case 3:
        return 'Alta';
      default:
        return 'Normal';
    }
  }

  // Obtener color de prioridad
  Color getColorPrioridad() {
    switch (prioridad) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
