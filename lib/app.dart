import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'routing/app_routes.dart';
import 'services/api_client.dart';
import 'services/menu_service.dart';
import 'services/reservation_service.dart';
import 'services/session_store.dart';
import 'state/auth_controller.dart';

class ReservaApp extends StatelessWidget {
  const ReservaApp({
    super.key,
    required this.apiClient,
    required this.sessionStore,
    required this.authController,
  });

  final ApiClient apiClient;
  final SessionStore sessionStore;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<SessionStore>.value(value: sessionStore),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        Provider<MenuService>(create: (_) => MenuService(apiClient)),
        Provider<ReservationService>(
          create: (_) => ReservationService(apiClient),
        ),
      ],
      child: MaterialApp(
        title: 'ReserVa — Reservas de restaurante',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        locale: const Locale('es', 'CO'),
        supportedLocales: const [
          Locale('es', 'CO'),
          Locale('es'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
      ),
    );
  }
}
