class User {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String? rol;
  final String? token;

  User({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.rol,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      rol: json['rol'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'token': token,
    };
  }
}
