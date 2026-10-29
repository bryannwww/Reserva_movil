import 'json_utils.dart';

class User {
  const User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.estado,
  });

  final int id;
  final String nombre;
  final String email;
  final String rol;
  final bool estado;

  String get firstName {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? nombre : parts.first;
  }

  bool get isAdmin => rol.toLowerCase() == 'admin';

  String get roleLabel => isAdmin ? 'Administrador' : 'Cliente';

  String get statusLabel => estado ? 'Cuenta activa' : 'Cuenta inactiva';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: asInt(json['id']),
      nombre: asString(json['nombre'], fallback: 'Comensal'),
      email: asString(json['email']),
      rol: asString(json['rol'], fallback: 'cliente'),
      estado: asBool(json['estado'], fallback: true),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'rol': rol,
    'estado': estado,
  };
}
