import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reserva_fluter_open/core/theme/app_theme.dart';
import 'package:reserva_fluter_open/models/dish.dart';
import 'package:reserva_fluter_open/models/reservation.dart';
import 'package:reserva_fluter_open/models/restaurant_table.dart';
import 'package:reserva_fluter_open/models/user.dart';
import 'package:reserva_fluter_open/models/zone.dart';
import 'package:reserva_fluter_open/screens/account_screen.dart';
import 'package:reserva_fluter_open/screens/home_screen.dart';
import 'package:reserva_fluter_open/screens/menu_screen.dart';
import 'package:reserva_fluter_open/screens/my_reservations_screen.dart';
import 'package:reserva_fluter_open/screens/reservation_flow_screen.dart';
import 'package:reserva_fluter_open/services/api_client.dart';
import 'package:reserva_fluter_open/services/menu_service.dart';
import 'package:reserva_fluter_open/services/reservation_service.dart';
import 'package:reserva_fluter_open/services/session_store.dart';
import 'package:reserva_fluter_open/state/auth_controller.dart';

import 'test_fonts.dart';

const _user = User(
  id: 7,
  nombre: 'María Torres',
  email: 'maria@example.com',
  rol: 'cliente',
  estado: true,
);

const _dishes = [
  Dish(
    id: 1,
    nombre: 'Ceviche de temporada con leche de tigre',
    descripcion:
        'Pescado blanco marinado en cítricos, ají amarillo, camote y maíz tostado.',
    precio: 65000,
    categoria: 'entradas',
    categoriaDisplay: 'Entradas',
    disponible: true,
    destacado: true,
    imagen: null,
    stock: 2,
  ),
  Dish(
    id: 2,
    nombre: 'Lomo al carbón',
    descripcion: 'Madurado 21 días, puré rústico y reducción de vino tinto.',
    precio: 129000,
    categoria: 'platos_fuertes',
    categoriaDisplay: 'Platos fuertes',
    disponible: true,
    destacado: false,
    imagen: null,
    stock: 12,
  ),
];

final _reservation = Reservation(
  id: 12,
  mesaId: 3,
  mesaNumero: 3,
  cantidadPersonas: 2,
  fecha: DateTime.now().add(const Duration(days: 1)),
  horaRaw: '19:30:00',
  notas: 'Celebración de cumpleaños, silla para bebé.',
  estado: 'pendiente',
);

class _FakeAuth extends AuthController {
  _FakeAuth() : super(api: ApiClient(), store: SessionStore());

  @override
  AuthStatus get status => AuthStatus.authenticated;

  @override
  bool get isAuthenticated => true;

  @override
  User? get user => _user;

  @override
  String get displayName => _user.firstName;

  @override
  Future<void> expireSession() async {}

  @override
  Future<void> refreshProfile() async {}

  @override
  Future<void> logout() async {}
}

class _FakeMenuService extends MenuService {
  _FakeMenuService() : super(ApiClient());

  @override
  Future<List<Dish>> fetchDishes({
    String categoria = 'todos',
    String buscar = '',
  }) async => _dishes;

  @override
  Future<List<Zone>> fetchZones() async => const [
    Zone(id: 1, nombre: 'Salón principal'),
    Zone(id: 2, nombre: 'Terraza exterior'),
    Zone(id: 3, nombre: 'Barra del chef'),
  ];

  @override
  Future<List<RestaurantTable>> fetchAvailableTables({
    required DateTime fecha,
    required TimeOfDay hora,
    required int personas,
    int? zonaId,
  }) async => const [
    RestaurantTable(
      id: 1,
      numero: 1,
      capacidad: 4,
      forma: 'redonda',
      zonaId: 1,
      zonaNombre: 'Salón principal',
      posicionX: 0,
      posicionY: 0,
    ),
    RestaurantTable(
      id: 2,
      numero: 2,
      capacidad: 2,
      forma: 'cuadrada',
      zonaId: 2,
      zonaNombre: 'Terraza exterior',
      posicionX: 0,
      posicionY: 0,
    ),
  ];
}

class _FakeReservationService extends ReservationService {
  _FakeReservationService() : super(ApiClient());

  @override
  Future<List<Reservation>> fetchMine({String? estado}) async => [_reservation];

  @override
  Future<Reservation> create({
    required DateTime fecha,
    required TimeOfDay hora,
    required int cantidadPersonas,
    RestaurantTable? mesa,
    String notas = '',
  }) async => _reservation;

  @override
  Future<Reservation> cancel(int id) async => _reservation;
}

void main() {
  setUpAll(loadAppFonts);

  Future<void> pumpAuthenticated(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: _FakeAuth()),
          Provider<MenuService>.value(value: _FakeMenuService()),
          Provider<ReservationService>.value(value: _FakeReservationService()),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in const [Size(320, 700), Size(390, 844)]) {
    testWidgets('inicio con sesión sin desbordes en ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpAuthenticated(tester, const HomeScreen(), size: size);
      expect(find.text('Hola, María'), findsOneWidget);
    });

    testWidgets('carta con platos sin desbordes en ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpAuthenticated(tester, const MenuScreen(), size: size);
      expect(
        find.text('Ceviche de temporada con leche de tigre'),
        findsOneWidget,
      );
      expect(find.text('Lomo al carbón'), findsOneWidget);
    });

    testWidgets(
      'mis reservas con datos sin desbordes en ${size.width.toInt()} px',
      (tester) async {
        await pumpAuthenticated(
          tester,
          const MyReservationsScreen(),
          size: size,
        );
        expect(find.text('1 RESERVA'), findsOneWidget);
        expect(find.text('Mesa 3'), findsWidgets);
      },
    );

    testWidgets('cuenta con sesión sin desbordes en ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpAuthenticated(tester, const AccountScreen(), size: size);
      expect(find.text('María Torres'), findsWidgets);
      expect(find.text('CLIENTE'), findsWidgets);
    });

    testWidgets(
      'flujo de reserva completo sin desbordes en ${size.width.toInt()} px',
      (tester) async {
        await pumpAuthenticated(
          tester,
          const ReservationFlowScreen(),
          size: size,
        );

        expect(find.text('TERRAZA EXTERIOR'), findsWidgets);

        await tester.ensureVisible(find.text('Ver mesas disponibles'));
        await tester.tap(find.text('Ver mesas disponibles'));
        await tester.pumpAndSettle();
        expect(find.text('Mesa 1'), findsWidgets);

        await tester.tap(find.text('Continuar sin preferencia'));
        await tester.pumpAndSettle();
        expect(find.text('Solicitar reserva'), findsOneWidget);

        await tester.ensureVisible(find.text('Solicitar reserva'));
        await tester.tap(find.text('Solicitar reserva'));
        await tester.pumpAndSettle();
        expect(find.text('Reserva solicitada'), findsOneWidget);
      },
    );
  }
}
