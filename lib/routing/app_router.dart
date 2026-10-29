import 'package:flutter/material.dart';

import '../screens/account_screen.dart';
import '../screens/login_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/my_reservations_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/register_screen.dart';
import '../screens/reservation_flow_screen.dart';
import '../screens/root_screen.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = switch (settings.name) {
      AppRoutes.home => (BuildContext _) => const RootScreen(),
      AppRoutes.login => (BuildContext _) => LoginScreen(
        nextRoute: _nextRoute(settings.arguments),
      ),
      AppRoutes.register => (BuildContext _) => RegisterScreen(
        nextRoute: _nextRoute(settings.arguments),
      ),
      AppRoutes.menu => (BuildContext _) => const MenuScreen(),
      AppRoutes.reservation =>
        (BuildContext _) => const ReservationFlowScreen(),
      AppRoutes.myReservations =>
        (BuildContext _) => const MyReservationsScreen(),
      AppRoutes.account => (BuildContext _) => const AccountScreen(),
      _ => (BuildContext _) => NotFoundScreen(routeName: settings.name),
    };
    return _pageRoute(settings, builder);
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _pageRoute(
      settings,
      (BuildContext _) => NotFoundScreen(routeName: settings.name),
    );
  }

  static String? _nextRoute(Object? arguments) {
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }
    return null;
  }

  static PageRoute<dynamic> _pageRoute(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.015),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
