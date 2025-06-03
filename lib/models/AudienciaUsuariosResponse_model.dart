// To parse this JSON data, do
//
//     final audienciaUsuariosResponse = audienciaUsuariosResponseFromJson(jsonString);

import 'dart:convert';

AudienciaUsuariosResponse audienciaUsuariosResponseFromJson(String str) =>
    AudienciaUsuariosResponse.fromJson(json.decode(str));

String audienciaUsuariosResponseToJson(AudienciaUsuariosResponse data) =>
    json.encode(data.toJson());

class AudienciaUsuariosResponse {
  int idAudiencia;
  int cantidadUsuarios;
  List<Usuario> usuarios;

  AudienciaUsuariosResponse({
    required this.idAudiencia,
    required this.cantidadUsuarios,
    required this.usuarios,
  });

  factory AudienciaUsuariosResponse.fromJson(Map<String, dynamic> json) =>
      AudienciaUsuariosResponse(
        idAudiencia: json["id_audiencia"],
        cantidadUsuarios: json["cantidad_usuarios"],
        usuarios: List<Usuario>.from(
          json["usuarios"].map((x) => Usuario.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "id_audiencia": idAudiencia,
    "cantidad_usuarios": cantidadUsuarios,
    "usuarios": List<dynamic>.from(usuarios.map((x) => x.toJson())),
  };
}

class Usuario {
  int idUsuario;
  String nombre;
  String apellido;
  String correo;
  String rol;
  String cargoEnAudiencia;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rol,
    required this.cargoEnAudiencia,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    idUsuario: json["id_usuario"],
    nombre: json["nombre"],
    apellido: json["apellido"],
    correo: json["correo"],
    rol: json["rol"],
    cargoEnAudiencia: json["cargo_en_audiencia"],
  );

  Map<String, dynamic> toJson() => {
    "id_usuario": idUsuario,
    "nombre": nombre,
    "apellido": apellido,
    "correo": correo,
    "rol": rol,
    "cargo_en_audiencia": cargoEnAudiencia,
  };
}
