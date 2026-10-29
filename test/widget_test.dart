import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_fluter_open/core/theme/app_theme.dart';
import 'package:reserva_fluter_open/screens/login_screen.dart';

void main() {
  testWidgets('la pantalla de acceso muestra sus campos y valida vacíos', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const LoginScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);

    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });
}
