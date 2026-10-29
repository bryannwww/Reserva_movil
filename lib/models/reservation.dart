import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import 'json_utils.dart';

class Reservation {
  const Reservation({
    required this.id,
    required this.mesaId,
    required this.mesaNumero,
    required this.cantidadPersonas,
    required this.fecha,
    required this.horaRaw,
    required this.notas,
    required this.estado,
  });

  final int id;
  final int? mesaId;
  final int? mesaNumero;
  final int cantidadPersonas;
  final DateTime fecha;
  final String horaRaw;
  final String? notas;
  final String estado;

  String get horaLabel => formatApiTime(horaRaw);

  TimeOfDay get hora =>
      parseApiTime(horaRaw) ?? const TimeOfDay(hour: 0, minute: 0);

  String get mesaLabel =>
      mesaNumero != null ? 'Mesa $mesaNumero' : 'Sin mesa asignada';

  String get estadoLabel => statusLabel(estado);

  bool get isCancelable =>
      estado.toLowerCase() == 'pendiente' ||
      estado.toLowerCase() == 'confirmada';

  bool get isActive => const {
    'pendiente',
    'confirmada',
    'asistio',
  }.contains(estado.toLowerCase());

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final rawDate = asString(json['fecha']);
    return Reservation(
      id: asInt(json['id']),
      mesaId: asNullableInt(json['mesa']),
      mesaNumero: asNullableInt(json['mesa_numero']),
      cantidadPersonas: asInt(json['cantidad_personas']),
      fecha: DateTime.tryParse(rawDate) ?? DateTime.now(),
      horaRaw: asString(json['hora'], fallback: '00:00'),
      notas: asNullableString(json['notas']),
      estado: asString(json['estado'], fallback: 'pendiente'),
    );
  }
}
