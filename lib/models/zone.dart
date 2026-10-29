import 'json_utils.dart';

class Zone {
  const Zone({required this.id, required this.nombre});

  final int id;
  final String nombre;

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: asInt(json['id']),
      nombre: asString(json['nombre'], fallback: 'Zona'),
    );
  }
}
