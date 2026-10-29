import 'json_utils.dart';

class RestaurantTable {
  const RestaurantTable({
    required this.id,
    required this.numero,
    required this.capacidad,
    required this.forma,
    required this.zonaId,
    required this.zonaNombre,
    required this.posicionX,
    required this.posicionY,
    this.disponible,
    this.motivoNoDisponible,
  });

  final int id;
  final int numero;
  final int capacidad;
  final String forma;
  final int? zonaId;
  final String? zonaNombre;
  final int posicionX;
  final int posicionY;
  final bool? disponible;
  final String? motivoNoDisponible;

  String get displayName => 'Mesa $numero';

  String get formaLabel {
    switch (forma) {
      case 'redonda':
        return 'Redonda';
      case 'cuadrada':
        return 'Cuadrada';
      case 'rectangular':
        return 'Rectangular';
      default:
        return forma;
    }
  }

  String? get motivoLabel {
    switch (motivoNoDisponible) {
      case 'reservada':
        return 'Reservada en este horario';
      case 'en_consumo':
        return 'Con consumo activo';
      case 'capacidad':
        return 'Capacidad insuficiente';
      default:
        return null;
    }
  }

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: asInt(json['id']),
      numero: asInt(json['numero']),
      capacidad: asInt(json['capacidad']),
      forma: asString(json['forma'], fallback: 'redonda'),
      zonaId: asNullableInt(json['zona']),
      zonaNombre: asNullableString(json['zona_nombre']),
      posicionX: asInt(json['posicion_x']),
      posicionY: asInt(json['posicion_y']),
      disponible: json.containsKey('disponible') && json['disponible'] != null
          ? asBool(json['disponible'])
          : null,
      motivoNoDisponible: asNullableString(json['motivo_no_disponible']),
    );
  }
}
