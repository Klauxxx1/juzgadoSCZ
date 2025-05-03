/*import 'package:flutter/material.dart';
import 'package:si2/models/user_model.dart';
import 'package:si2/models/expediente_model.dart';

class Audiencia {
  final int? id;
  final int expedienteId;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final TimeOfDay horaInicio;
  final TimeOfDay? horaFin;
  final String sala;
  final String estado; // "Programada", "En curso", "Finalizada", "Cancelada"
  final String? resolucion;
  final List<int>? participantesIds;
  final bool confirmada;

  // Relaciones
  final Expediente? expediente;
  final List<User>? participantes;
  final List<String>? observaciones;

  Audiencia({
    this.id,
    required this.expedienteId,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.horaInicio,
    this.horaFin,
    required this.sala,
    required this.estado,
    this.resolucion,
    this.participantesIds,
    this.confirmada = false,
    this.expediente,
    this.participantes,
    this.observaciones,
    required duracionEstimada,
  });

  factory Audiencia.fromJson(Map<String, dynamic> json) {
    return Audiencia(
      id: json['id'],
      expedienteId: json['expediente_id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fecha: DateTime.parse(json['fecha']),
      horaInicio: TimeOfDay(
        hour: int.parse(json['hora_inicio'].split(':')[0]),
        minute: int.parse(json['hora_inicio'].split(':')[1]),
      ),
      duracionEstimada: json['duracion_estimada'],
      sala: json['sala'],
      estado: json['estado'],
      confirmada: json['confirmada'] == 1 || json['confirmada'] == true,
      // Otros campos que pueda tener tu modelo
    );
  }

  // Convertir string "HH:MM" a TimeOfDay
  static TimeOfDay _timeFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Convertir TimeOfDay a string "HH:MM"
  static String _timeToString(TimeOfDay time) {
    String _addLeadingZero(int value) {
      return value < 10 ? '0$value' : '$value';
    }

    return '${_addLeadingZero(time.hour)}:${_addLeadingZero(time.minute)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expedienteId': expedienteId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'horaInicio': _timeToString(horaInicio),
      'horaFin': horaFin != null ? _timeToString(horaFin!) : null,
      'sala': sala,
      'estado': estado,
      'resolucion': resolucion,
      'participantesIds': participantesIds,
      'confirmada': confirmada,
      'observaciones': observaciones,
    };
  }

  // Verificar si la audiencia es hoy
  bool get esHoy {
    final now = DateTime.now();
    return fecha.year == now.year &&
        fecha.month == now.month &&
        fecha.day == now.day;
  }

  // Verificar si la audiencia ya pasó
  bool get yaPaso {
    final now = DateTime.now();
    return fecha.isBefore(now) ||
        (fecha.year == now.year &&
                fecha.month == now.month &&
                fecha.day == now.day &&
                horaInicio.hour < now.hour ||
            (horaInicio.hour == now.hour && horaInicio.minute < now.minute));
  }

  // Formatear fecha para mostrar
  String get fechaFormateada {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  // Formatear hora para mostrar
  String get horaFormateada {
    String _addLeadingZero(int value) {
      return value < 10 ? '0$value' : '$value';
    }

    return '${_addLeadingZero(horaInicio.hour)}:${_addLeadingZero(horaInicio.minute)}';
  }

  // Obtener color según estado
  Color getColorPorEstado() {
    switch (estado) {
      case 'Programada':
        return Colors.blue;
      case 'En curso':
        return Colors.green;
      case 'Finalizada':
        return Colors.grey;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}*/
