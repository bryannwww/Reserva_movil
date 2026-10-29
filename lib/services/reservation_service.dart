import 'package:flutter/material.dart';

import '../core/errors/api_exception.dart';
import '../core/utils/formatters.dart';
import '../models/json_utils.dart';
import '../models/reservation.dart';
import '../models/restaurant_table.dart';
import 'api_client.dart';

class ReservationService {
  ReservationService(this._api);

  final ApiClient _api;

  /// `GET /reservas/api/reservas/mis-reservas/` — solo las del token actual.
  Future<List<Reservation>> fetchMine({String? estado}) async {
    final data = await _api.get(
      '/reservas/api/reservas/mis-reservas/',
      query: {if (estado != null && estado.isNotEmpty) 'estado': estado},
    );
    if (data is! List) {
      throw ApiException(
        message:
            'El servidor devolvió un formato inesperado para tus reservas.',
      );
    }
    return data
        .whereType<Map>()
        .map((item) => Reservation.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  /// `POST /reservas/api/reservas/`
  ///
  /// El propietario y el estado los define el backend a partir del token.
  Future<Reservation> create({
    required DateTime fecha,
    required TimeOfDay hora,
    required int cantidadPersonas,
    RestaurantTable? mesa,
    String notas = '',
  }) async {
    final data = await _api.post(
      '/reservas/api/reservas/',
      body: {
        'fecha': isoDate(fecha),
        'hora': formatTimeOfDay(hora),
        'cantidad_personas': cantidadPersonas,
        if (mesa != null) 'mesa': mesa.id,
        if (notas.trim().isNotEmpty) 'notas': notas.trim(),
      },
    );
    if (data is! Map) {
      throw ApiException(
        message: 'El servidor no confirmó la reserva. Revisa "Mis reservas".',
      );
    }
    return Reservation.fromJson(asJsonMap(data));
  }

  /// `POST /reservas/api/reservas/{id}/cancelar/`
  Future<Reservation> cancel(int id) async {
    final data = await _api.post('/reservas/api/reservas/$id/cancelar/');
    if (data is! Map) {
      throw ApiException(
        message: 'El servidor no devolvió la reserva cancelada.',
      );
    }
    return Reservation.fromJson(asJsonMap(data));
  }
}
