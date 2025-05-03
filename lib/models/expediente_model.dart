import 'package:flutter/material.dart';
import 'package:si2/models/user_model.dart';

class Expediente {
  final int? id;
  final String numero;
  final String titulo;
  final String descripcion;
  final String estado; // "Abierto", "En resolución", "Cerrado"
  final String tipo;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final int? clienteId;
  final int? abogadoId;
  final int? juezId;
  final int? asistenteId;

  // Relaciones
  final User? cliente;
  final User? abogado;
  final User? juez;
  final User? asistente;
  final List<String>? etiquetas;

  Expediente({
    this.id,
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.estado,
    required this.tipo,
    required this.fechaApertura,
    this.fechaCierre,
    this.clienteId,
    this.abogadoId,
    this.juezId,
    this.asistenteId,
    this.cliente,
    this.abogado,
    this.juez,
    this.asistente,
    this.etiquetas,
  });

  factory Expediente.fromJson(Map<String, dynamic> json) {
    return Expediente(
      id: json['id'],
      numero: json['numero'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      tipo: json['tipo'],
      fechaApertura: DateTime.parse(json['fechaApertura']),
      fechaCierre:
          json['fechaCierre'] != null
              ? DateTime.parse(json['fechaCierre'])
              : null,
      clienteId: json['clienteId'],
      abogadoId: json['abogadoId'],
      juezId: json['juezId'],
      asistenteId: json['asistenteId'],
      cliente: json['cliente'] != null ? User.fromJson(json['cliente']) : null,
      abogado: json['abogado'] != null ? User.fromJson(json['abogado']) : null,
      juez: json['juez'] != null ? User.fromJson(json['juez']) : null,
      asistente:
          json['asistente'] != null ? User.fromJson(json['asistente']) : null,
      etiquetas:
          json['etiquetas'] != null
              ? List<String>.from(json['etiquetas'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'titulo': titulo,
      'descripcion': descripcion,
      'estado': estado,
      'tipo': tipo,
      'fechaApertura': fechaApertura.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'clienteId': clienteId,
      'abogadoId': abogadoId,
      'juezId': juezId,
      'asistenteId': asistenteId,
      'etiquetas': etiquetas,
    };
  }

  // Para obtener un color según el estado
  Color getColorPorEstado() {
    switch (estado) {
      case 'Abierto':
        return Colors.green;
      case 'En resolución':
        return Colors.orange;
      case 'Cerrado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Para verificar si el expediente está en progreso
  bool get estaEnProceso => estado == 'En resolución';

  // Para verificar si el expediente está cerrado
  bool get estaCerrado => estado == 'Cerrado';
}
