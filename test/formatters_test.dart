import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_fluter_open/core/utils/formatters.dart';

void main() {
  group('formatCurrency', () {
    test('formatea pesos colombianos sin decimales', () {
      expect(formatCurrency(65000), r'$65.000');
      expect(formatCurrency(2500.4), r'$2.500');
      expect(formatCurrency(0), r'$0');
      expect(formatCurrency(1234567), r'$1.234.567');
    });
  });

  group('formatApiTime', () {
    test('recorta los segundos que devuelve Django', () {
      expect(formatApiTime('19:30:00'), '19:30');
      expect(formatApiTime('09:05:00'), '09:05');
      expect(formatApiTime('7:5'), '07:05');
    });

    test('conserva un valor no reconocido', () {
      expect(formatApiTime('sin hora'), 'sin hora');
    });
  });

  group('fechas', () {
    test('isoDate usa el formato de la API', () {
      expect(isoDate(DateTime(2026, 1, 5)), '2026-01-05');
      expect(isoDate(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('formatLongDate se muestra en español', () {
      expect(
        formatLongDate(DateTime(2026, 10, 28)),
        'Miércoles, 28 de octubre de 2026',
      );
      expect(
        formatLongDate(DateTime(2026, 10, 28), includeWeekday: false),
        '28 de octubre de 2026',
      );
    });

    test('formatShortDate usa el mes abreviado', () {
      expect(formatShortDate(DateTime(2026, 10, 28)), '28 OCT');
    });

    test('parseApiTime valida hora y minuto', () {
      expect(parseApiTime('19:30:00'), const TimeOfDay(hour: 19, minute: 30));
      expect(parseApiTime('24:00'), isNull);
      expect(parseApiTime('19:99'), isNull);
      expect(parseApiTime(null), isNull);
    });
  });

  group('statusLabel', () {
    test('traduce los estados reales del backend', () {
      expect(statusLabel('pendiente'), 'Pendiente');
      expect(statusLabel('confirmada'), 'Confirmada');
      expect(statusLabel('asistio'), 'Asistió');
      expect(statusLabel('completada'), 'Completada');
      expect(statusLabel('cancelada'), 'Cancelada');
    });

    test('humaniza estados desconocidos sin romper', () {
      expect(statusLabel('en_espera'), 'En espera');
    });
  });

  group('initials', () {
    test('toma la inicial del nombre y del apellido', () {
      expect(initials('María Torres'), 'MT');
      expect(initials('Ana'), 'A');
      expect(initials('   '), 'R');
    });
  });
}
