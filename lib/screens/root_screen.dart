import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_controller.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

/// Ruta raíz: muestra la pantalla de carga mientras se restaura la sesión y
/// luego la portada. Así la app nunca parpadea entre “invitado” y “conectado”.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthController, AuthStatus>(
      (auth) => auth.status,
    );
    if (status == AuthStatus.loading) {
      return const SplashScreen();
    }
    return const HomeScreen();
  }
}
