import 'package:flutter/material.dart';

import '../core/errors/api_exception.dart';
import '../core/utils/formatters.dart';
import '../models/dish.dart';
import '../models/restaurant_table.dart';
import '../models/zone.dart';
import 'api_client.dart';

class MenuService {
  MenuService(this._api);

  final ApiClient _api;

  Future<List<Dish>> fetchDishes({
    String categoria = 'todos',
    String buscar = '',
  }) async {
    final data = await _api.get(
      '/menu/api/platos/',
      query: {
        if (categoria.isNotEmpty && categoria != 'todos')
          'categoria': categoria,
        if (buscar.trim().isNotEmpty) 'buscar': buscar.trim(),
      },
    );
    return _mapList(data, Dish.fromJson, 'la carta');
  }

  Future<List<Zone>> fetchZones() async {
    final data = await _api.get('/menu/api/zonas/');
    return _mapList(data, Zone.fromJson, 'las zonas');
  }

  /// Mesas libres para la fecha, la hora y la cantidad de personas indicadas.
  ///
  /// Endpoint real: `GET /menu/api/mesas/disponibles/`.
  Future<List<RestaurantTable>> fetchAvailableTables({
    required DateTime fecha,
    required TimeOfDay hora,
    required int personas,
    int? zonaId,
  }) async {
    final query = <String, dynamic>{
      'fecha': isoDate(fecha),
      'hora': formatTimeOfDay(hora),
      'personas': personas,
    };
    if (zonaId != null) query['zona'] = zonaId;
    final data = await _api.get('/menu/api/mesas/disponibles/', query: query);
    final tables = _mapList(data, RestaurantTable.fromJson, 'las mesas');
    return tables
        .where((table) => table.disponible != false)
        .toList(growable: false);
  }

  List<T> _mapList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) builder,
    String resource,
  ) {
    if (data is! List) {
      throw ApiException(
        message:
            'El servidor devolvió un formato inesperado para $resource. Inténtalo de nuevo.',
      );
    }
    return data
        .whereType<Map>()
        .map((item) => builder(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
