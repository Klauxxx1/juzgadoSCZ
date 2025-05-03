class User {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String rol; // Cliente, Abogado, Juez, Asistente, Administrador
  final String? token;
  final String? telefono;
  final String? direccion;
  final String? especialidad; // Para abogados y jueces
  final int? numeroMatricula; // Para abogados
  final String? fotoPerfil;
  final DateTime? fechaRegistro;

  User({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.token,
    this.telefono,
    this.direccion,
    this.especialidad,
    this.numeroMatricula,
    this.fotoPerfil,
    this.fechaRegistro,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      rol: json['rol'] ?? 'Cliente',
      token: json['token'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      especialidad: json['especialidad'],
      numeroMatricula: json['numeroMatricula'],
      fotoPerfil: json['fotoPerfil'],
      fechaRegistro:
          json['fechaRegistro'] != null
              ? DateTime.parse(json['fechaRegistro'])
              : null,
    );
  }

  // Métodos de autorización
  bool get isCliente => rol == 'Cliente';
  bool get isAbogado => rol == 'Abogado';
  bool get isJuez => rol == 'Juez';
  bool get isAsistente => rol == 'Asistente';
  bool get isAdministrador => rol == 'Administrador';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'telefono': telefono,
      'direccion': direccion,
      'especialidad': especialidad,
      'numeroMatricula': numeroMatricula,
      'fotoPerfil': fotoPerfil,
      'fechaRegistro': fechaRegistro?.toIso8601String(),
    };
  }

  // Nombre completo para mostrar
  String get nombreCompleto => '$nombre $apellido';
}
