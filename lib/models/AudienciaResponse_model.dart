// To parse this JSON data, do
//
//     final audienciaResponse = audienciaResponseFromJson(jsonString);

import 'dart:convert';

List<AudienciaResponse> audienciaResponseFromJson(String str) =>
    List<AudienciaResponse>.from(
      json.decode(str).map((x) => AudienciaResponse.fromJson(x)),
    );

String audienciaResponseToJson(List<AudienciaResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AudienciaResponse {
  int idAudiencia;
  int idExpediente;
  DateTime fecha;
  Duracion? duracion;
  String ubicacion;
  String estado;
  String observacion;

  AudienciaResponse({
    required this.idAudiencia,
    required this.idExpediente,
    required this.fecha,
    required this.duracion,
    required this.ubicacion,
    required this.estado,
    required this.observacion,
  });

  factory AudienciaResponse.fromJson(Map<String, dynamic> json) =>
      AudienciaResponse(
        idAudiencia: json["id_audiencia"],
        idExpediente: json["id_expediente"],
        fecha: DateTime.parse(json["fecha"]),
        duracion:
            json["duracion"] == null
                ? null
                : Duracion.fromJson(json["duracion"]),
        ubicacion: json["ubicacion"],
        estado: json["estado"],
        observacion: json["observacion"],
      );

  Map<String, dynamic> toJson() => {
    "id_audiencia": idAudiencia,
    "id_expediente": idExpediente,
    "fecha": fecha.toIso8601String(),
    "duracion": duracion?.toJson(),
    "ubicacion": ubicacion,
    "estado": estado,
    "observacion": observacion,
  };
}

class Duracion {
  int hours;

  Duracion({required this.hours});

  factory Duracion.fromJson(Map<String, dynamic> json) =>
      Duracion(hours: json["hours"]);

  Map<String, dynamic> toJson() => {"hours": hours};
}
