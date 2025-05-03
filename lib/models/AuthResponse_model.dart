import 'dart:convert';

AuthResponse authResponseFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
  String mensaje;
  String token;
  Usuario usuario;

  AuthResponse({
    required this.mensaje,
    required this.token,
    required this.usuario,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    mensaje: json["mensaje"],
    token: json["token"],
    usuario: Usuario.fromJson(json["usuario"]),
  );

  Map<String, dynamic> toJson() => {
    "mensaje": mensaje,
    "token": token,
    "usuario": usuario.toJson(),
  };
}

class Usuario {
  int id;
  String nombre;
  String apellido;
  String rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json["id"],
    nombre: json["nombre"],
    apellido: json["apellido"],
    rol: json["rol"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "apellido": apellido,
    "rol": rol,
  };
}
