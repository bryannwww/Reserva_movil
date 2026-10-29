import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_fluter_open/core/utils/validators.dart';

void main() {
  group('Validators.name', () {
    test('exige un nombre real', () {
      expect(Validators.name(null), isNotNull);
      expect(Validators.name('  '), isNotNull);
      expect(Validators.name('A'), isNotNull);
      expect(Validators.name('Ana'), isNull);
    });

    test('limita la longitud al máximo del backend', () {
      expect(Validators.name('a' * 101), isNotNull);
    });
  });

  group('Validators.email', () {
    test('acepta correos válidos y rechaza inválidos', () {
      expect(Validators.email('comensal@reserva.co'), isNull);
      expect(Validators.email('sin-arroba'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('en registro exige mínimo 8 caracteres', () {
      expect(
        Validators.password('1234567', registering: true),
        'La contraseña debe tener al menos 8 caracteres.',
      );
      expect(Validators.password('12345678', registering: true), isNull);
    });

    test('en acceso solo exige que no esté vacía', () {
      expect(Validators.password('123', registering: false), isNull);
      expect(Validators.password('', registering: false), isNotNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('debe coincidir con la contraseña original', () {
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
      expect(
        Validators.confirmPassword('otra', 'abc12345'),
        'Las contraseñas no coinciden.',
      );
    });
  });

  group('Validators.notes', () {
    test('permite notas vacías y limita a 500 caracteres', () {
      expect(Validators.notes(null), isNull);
      expect(Validators.notes(''), isNull);
      expect(Validators.notes('a' * 500), isNull);
      expect(Validators.notes('a' * 501), isNotNull);
    });
  });
}
