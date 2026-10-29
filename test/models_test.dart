import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_fluter_open/models/auth_session.dart';
import 'package:reserva_fluter_open/models/dish.dart';
import 'package:reserva_fluter_open/models/reservation.dart';
import 'package:reserva_fluter_open/models/restaurant_table.dart';
import 'package:reserva_fluter_open/models/user.dart';
import 'package:reserva_fluter_open/models/zone.dart';

void main() {
  group('Dish', () {
    test('interpreta el precio como texto y la disponibilidad reales', () {
      final dish = Dish.fromJson({
        'id': 7,
        'nombre': 'Lomo al carbón',
        'descripcion': 'Con papas rústicas.',
        'precio': '65000.00',
        'categoria': 'platos_fuertes',
        'categoria_display': 'Platos fuertes',
        'disponible': true,
        'destacado': true,
        'imagen': '/media/platos/lomo.jpg',
        'stock': 2,
      });

      expect(dish.id, 7);
      expect(dish.precio, 65000);
      expect(dish.categoriaDisplay, 'Platos fuertes');
      expect(dish.isLowStock, isTrue);
      expect(dish.hasStock, isTrue);
    });

    test('tolera campos ausentes', () {
      final dish = Dish.fromJson(const <String, dynamic>{});
      expect(dish.nombre, 'Plato sin nombre');
      expect(dish.categoriaDisplay, 'Otros');
      expect(dish.stock, 0);
      expect(dish.imagen, isNull);
    });
  });

  group('RestaurantTable', () {
    test('lee zona, posición y disponibilidad con motivo', () {
      final table = RestaurantTable.fromJson({
        'id': 3,
        'numero': 12,
        'capacidad': 4,
        'forma': 'redonda',
        'zona': 2,
        'zona_nombre': 'Terraza',
        'posicion_x': 4,
        'posicion_y': 6,
        'disponible': false,
        'motivo_no_disponible': 'reservada',
      });

      expect(table.displayName, 'Mesa 12');
      expect(table.zonaNombre, 'Terraza');
      expect(table.disponible, isFalse);
      expect(table.motivoLabel, 'Reservada en este horario');
      expect(table.formaLabel, 'Redonda');
    });

    test('sin datos de disponibilidad deja el valor nulo', () {
      final table = RestaurantTable.fromJson({
        'id': 1,
        'numero': 1,
        'capacidad': 2,
        'forma': 'cuadrada',
        'zona': null,
        'zona_nombre': null,
        'posicion_x': 0,
        'posicion_y': 0,
      });

      expect(table.disponible, isNull);
      expect(table.motivoLabel, isNull);
    });
  });

  group('Reservation', () {
    test('interpreta fecha, hora y estado del backend', () {
      final reservation = Reservation.fromJson({
        'id': 21,
        'mesa': 3,
        'mesa_numero': 12,
        'cantidad_personas': 2,
        'fecha': '2026-11-05',
        'hora': '19:30:00',
        'notas': 'Mesa junto a la ventana.',
        'estado': 'confirmada',
      });

      expect(reservation.horaLabel, '19:30');
      expect(reservation.hora, const TimeOfDay(hour: 19, minute: 30));
      expect(reservation.mesaLabel, 'Mesa 12');
      expect(reservation.estadoLabel, 'Confirmada');
      expect(reservation.isCancelable, isTrue);
      expect(reservation.isActive, isTrue);
    });

    test('una reserva sin mesa se muestra correctamente', () {
      final reservation = Reservation.fromJson({
        'id': 22,
        'mesa': null,
        'mesa_numero': null,
        'cantidad_personas': 5,
        'fecha': '2026-11-06',
        'hora': '20:00:00',
        'notas': null,
        'estado': 'pendiente',
      });

      expect(reservation.mesaLabel, 'Sin mesa asignada');
      expect(reservation.notas, isNull);
      expect(reservation.isCancelable, isTrue);
    });

    test('las reservas completadas o canceladas no se pueden cancelar', () {
      Reservation build(String estado) => Reservation.fromJson({
        'id': 1,
        'cantidad_personas': 2,
        'fecha': '2026-11-05',
        'hora': '19:30:00',
        'estado': estado,
      });

      expect(build('completada').isCancelable, isFalse);
      expect(build('cancelada').isCancelable, isFalse);
      expect(build('completada').isActive, isFalse);
    });
  });

  group('User y AuthSession', () {
    test('lee el usuario que devuelve el backend', () {
      final user = User.fromJson({
        'id': 4,
        'nombre': 'María Torres',
        'email': 'maria@reserva.co',
        'rol': 'cliente',
        'estado': true,
      });

      expect(user.firstName, 'María');
      expect(user.isAdmin, isFalse);
      expect(user.roleLabel, 'Cliente');
      expect(user.statusLabel, 'Cuenta activa');
    });

    test('restaura la sesión guardada', () {
      final session = AuthSession.fromJson({
        'token': 'abc123',
        'user': {
          'id': 1,
          'nombre': 'Ana',
          'email': 'ana@reserva.co',
          'rol': 'cliente',
          'estado': true,
        },
      });

      expect(session.token, 'abc123');
      expect(session.user.nombre, 'Ana');
      expect(session.toJson()['token'], 'abc123');
    });
  });

  test('Zone interpreta el endpoint de zonas', () {
    final zone = Zone.fromJson({'id': 2, 'nombre': 'Terraza'});
    expect(zone.id, 2);
    expect(zone.nombre, 'Terraza');
  });
}
