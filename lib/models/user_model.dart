class User {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String rol; // Cliente, Abogado, Juez, Asistente
  final String? token;

  User({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      rol: json['rol'] ?? 'Cliente', // Valor predeterminado
      token: json['token'],
    );
  }

  // Métodos de autorización
  bool get isCliente => rol == 'Cliente';
  bool get isAbogado => rol == 'Abogado';
  bool get isJuez => rol == 'Juez';
  bool get isAsistente => rol == 'Asistente';

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
