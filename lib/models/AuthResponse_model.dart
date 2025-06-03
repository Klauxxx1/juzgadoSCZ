// To parse this JSON data, do
//
//     final authResponse = authResponseFromJson(jsonString);

import 'dart:convert';

AuthResponse authResponseFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
  String token;
  User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      AuthResponse(token: json["token"], user: User.fromJson(json["user"]));

  Map<String, dynamic> toJson() => {"token": token, "user": user.toJson()};
}

class User {
  int idUsuario;
  String nombre;
  String apellido;
  String correo;
  String? passwordHash;
  dynamic telefono;
  dynamic calle;
  dynamic ciudad;
  dynamic codigoPostal;
  String estadoUsuario;
  DateTime fechaRegistro;
  String idRol;

  User({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.passwordHash,
    required this.telefono,
    required this.calle,
    required this.ciudad,
    required this.codigoPostal,
    required this.estadoUsuario,
    required this.fechaRegistro,
    required this.idRol,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUsuario: json["id_usuario"],
    nombre: json["nombre"],
    apellido: json["apellido"],
    correo: json["correo"],
    passwordHash: json["password_hash"],
    telefono: json["telefono"],
    calle: json["calle"],
    ciudad: json["ciudad"],
    codigoPostal: json["codigo_postal"],
    estadoUsuario: json["estado_usuario"],
    fechaRegistro: DateTime.parse(json["fecha_registro"]),
    idRol: json["id_rol"],
  );

  // Métodos de autorización
  bool get isCliente => idRol == 'Cliente';
  bool get isAbogado => idRol == 'Abogado';
  bool get isJuez => idRol == 'Juez';
  bool get isAsistente => idRol == 'asistente';
  bool get isAdministrador => idRol == 'Administrador';

  Map<String, dynamic> toJson() => {
    "id_usuario": idUsuario,
    "nombre": nombre,
    "apellido": apellido,
    "correo": correo,
    "password_hash": passwordHash,
    "telefono": telefono,
    "calle": calle,
    "ciudad": ciudad,
    "codigo_postal": codigoPostal,
    "estado_usuario": estadoUsuario,
    "fecha_registro": fechaRegistro.toIso8601String(),
    "id_rol": idRol,
  };
}
