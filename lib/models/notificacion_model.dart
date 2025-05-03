import 'package:flutter/material.dart';
import 'package:si2/models/user_model.dart';

class Notificacion {
  final int? id;
  final int destinatarioId;
  final int? emisorId;
  final String titulo;
  final String mensaje;
  final String tipo; // "Sistema", "Audiencia", "Expediente", "Tarea", etc.
  final int?
  referenciaId; // ID del objeto relacionado (expediente, audiencia, etc.)
  final String? referenciaTipo; // Tipo de objeto relacionado
  final DateTime fechaCreacion;
  final bool leida;

  // Relaciones
  final User? destinatario;
  final User? emisor;

  Notificacion({
    this.id,
    required this.destinatarioId,
    this.emisorId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.referenciaId,
    this.referenciaTipo,
    required this.fechaCreacion,
    this.leida = false,
    this.destinatario,
    this.emisor,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      destinatarioId: json['destinatarioId'],
      emisorId: json['emisorId'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      tipo: json['tipo'],
      referenciaId: json['referenciaId'],
      referenciaTipo: json['referenciaTipo'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      leida: json['leida'] ?? false,
      destinatario:
          json['destinatario'] != null
              ? User.fromJson(json['destinatario'])
              : null,
      emisor: json['emisor'] != null ? User.fromJson(json['emisor']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinatarioId': destinatarioId,
      'emisorId': emisorId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'referenciaId': referenciaId,
      'referenciaTipo': referenciaTipo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'leida': leida,
    };
  }

  // Tiempo relativo desde la creación (ej: "hace 5 minutos")
  String get tiempoRelativo {
    final now = DateTime.now();
    final difference = now.difference(fechaCreacion);

    if (difference.inSeconds < 60) {
      return 'hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} h';
    } else if (difference.inDays < 30) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'hace $months meses';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'hace $years años';
    }
  }

  // Obtener icono según tipo de notificación
  IconData getIcono() {
    switch (tipo) {
      case 'Audiencia':
        return Icons.event;
      case 'Expediente':
        return Icons.folder;
      case 'Tarea':
        return Icons.assignment;
      case 'Sistema':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  // Obtener color según tipo de notificación
  Color getColor() {
    switch (tipo) {
      case 'Audiencia':
        return Colors.blue;
      case 'Expediente':
        return Colors.orange;
      case 'Tarea':
        return Colors.green;
      case 'Sistema':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Obtener ruta a la que debe navegar al hacer clic en la notificación
  String getRoute() {
    if (referenciaId == null) return '/notificaciones';

    switch (referenciaTipo) {
      case 'Expediente':
        return '/expedientes/detalle';
      case 'Audiencia':
        return '/audiencias/detalle';
      case 'Tarea':
        return '/seguimientos/tareas';
      default:
        return '/notificaciones';
    }
  }

  // Obtener argumentos para la navegación
  Map<String, dynamic>? getArguments() {
    if (referenciaId == null) return null;

    return {'id': referenciaId};
  }
}
