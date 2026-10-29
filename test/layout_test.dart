import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reserva_fluter_open/core/theme/app_theme.dart';
import 'package:reserva_fluter_open/screens/account_screen.dart';
import 'package:reserva_fluter_open/screens/home_screen.dart';
import 'package:reserva_fluter_open/screens/login_screen.dart';
import 'package:reserva_fluter_open/screens/menu_screen.dart';
import 'package:reserva_fluter_open/screens/my_reservations_screen.dart';
import 'package:reserva_fluter_open/screens/register_screen.dart';
import 'package:reserva_fluter_open/screens/reservation_flow_screen.dart';
import 'package:reserva_fluter_open/services/api_client.dart';
import 'package:reserva_fluter_open/services/session_store.dart';
import 'package:reserva_fluter_open/state/auth_controller.dart';

import 'test_fonts.dart';

/// Comprueba que las pantallas se maquetan sin desbordamientos en los anchos
/// reales de iPhone/Android y en una tableta. Cualquier RenderFlex overflow
/// se registra como excepción y hace fallar la prueba.
void main() {
  setUpAll(loadAppFonts);

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(360, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthController(api: ApiClient(), store: SessionStore());

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(theme: AppTheme.dark, home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in const [Size(320, 700), Size(360, 800), Size(390, 844)]) {
    testWidgets('inicio sin desbordes en ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpScreen(tester, const HomeScreen(), size: size);
      expect(find.text('ReserVa'), findsWidgets);
    });

    testWidgets('acceso sin desbordes en ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpScreen(tester, const LoginScreen(), size: size);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('registro sin desbordes en ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpScreen(tester, const RegisterScreen(), size: size);
      expect(find.text('Registrarme'), findsOneWidget);
    });

    testWidgets('carta sin sesión sin desbordes en ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpScreen(tester, const MenuScreen(), size: size);
      expect(find.text('La carta te espera'), findsOneWidget);
    });

    testWidgets(
      'reserva sin sesión sin desbordes en ${size.width.toInt()} px',
      (tester) async {
        await pumpScreen(tester, const ReservationFlowScreen(), size: size);
        expect(find.text('Reserva tu mesa'), findsOneWidget);
      },
    );

    testWidgets(
      'mis reservas sin sesión sin desbordes en ${size.width.toInt()} px',
      (tester) async {
        await pumpScreen(tester, const MyReservationsScreen(), size: size);
        expect(find.text('Tu historial de reservas'), findsOneWidget);
      },
    );

    testWidgets('cuenta sin sesión sin desbordes en ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpScreen(tester, const AccountScreen(), size: size);
      expect(find.text('Tu cuenta ReserVa'), findsOneWidget);
    });
  }

  testWidgets('inicio en tableta sin desbordes', (tester) async {
    await pumpScreen(tester, const HomeScreen(), size: const Size(768, 1024));
    expect(find.text('ReserVa'), findsWidgets);
  });

  testWidgets('registro en tableta sin desbordes', (tester) async {
    await pumpScreen(
      tester,
      const RegisterScreen(),
      size: const Size(768, 1024),
    );
    expect(find.text('Registrarme'), findsOneWidget);
  });
}
