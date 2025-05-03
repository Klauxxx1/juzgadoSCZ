// To parse this JSON data, do
//
//     final expedienteGetResponse = expedienteGetResponseFromJson(jsonString);

import 'dart:convert';

List<ExpedienteGetResponse> expedienteGetResponseFromJson(String str) =>
    List<ExpedienteGetResponse>.from(
      json.decode(str).map((x) => ExpedienteGetResponse.fromJson(x)),
    );

String expedienteGetResponseToJson(List<ExpedienteGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExpedienteGetResponse {
  int numeroExpediente;
  String demandanteCarnet;
  String demandadoCarnet;
  String abogadoDemandanteCarnet;
  String abogadoDemandadoCarnet;
  String juezCarnet;
  String contenido;

  ExpedienteGetResponse({
    required this.numeroExpediente,
    required this.demandanteCarnet,
    required this.demandadoCarnet,
    required this.abogadoDemandanteCarnet,
    required this.abogadoDemandadoCarnet,
    required this.juezCarnet,
    required this.contenido,
  });

  factory ExpedienteGetResponse.fromJson(Map<String, dynamic> json) =>
      ExpedienteGetResponse(
        numeroExpediente: json["numero_expediente"],
        demandanteCarnet: json["demandante_carnet"],
        demandadoCarnet: json["demandado_carnet"],
        abogadoDemandanteCarnet: json["abogado_demandante_carnet"],
        abogadoDemandadoCarnet: json["abogado_demandado_carnet"],
        juezCarnet: json["juez_carnet"],
        contenido: json["contenido"],
      );

  Map<String, dynamic> toJson() => {
    "numero_expediente": numeroExpediente,
    "demandante_carnet": demandanteCarnet,
    "demandado_carnet": demandadoCarnet,
    "abogado_demandante_carnet": abogadoDemandanteCarnet,
    "abogado_demandado_carnet": abogadoDemandadoCarnet,
    "juez_carnet": juezCarnet,
    "contenido": contenido,
  };
}
