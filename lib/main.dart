import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'services/api_client.dart';
import 'services/session_store.dart';
import 'state/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final sessionStore = SessionStore();
  final authController = AuthController(api: apiClient, store: sessionStore);

  runApp(
    ReservaApp(
      apiClient: apiClient,
      sessionStore: sessionStore,
      authController: authController,
    ),
  );

  // Restaura el token guardado y valida el perfil contra la API. Mientras
  // tanto, la ruta raíz muestra la pantalla de bienvenida.
  unawaited(authController.bootstrap());
}
