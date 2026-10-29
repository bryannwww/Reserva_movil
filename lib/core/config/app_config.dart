import 'package:flutter/foundation.dart';

/// Configuración única de la aplicación.
///
/// La URL de la API se define en tiempo de compilación:
///
/// ```bash
/// flutter run -d chrome --web-port=5000 \
///   --dart-define=API_BASE_URL=http://127.0.0.1:8000
///
/// flutter build web --dart-define=API_BASE_URL=https://api.midominio.com
/// ```
class AppConfig {
  const AppConfig._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _defaultBaseUrl = 'http://127.0.0.1:8000';

  /// Zona horaria del backend (`TIME_ZONE`). El backend usa `USE_TZ = False`,
  /// por lo que las horas que se envían son la hora local del restaurante.
  static const String restaurantTimeZone = 'America/Bogota';

  static const Duration requestTimeout = Duration(seconds: 20);

  static String get apiBaseUrl {
    final value = (_envBaseUrl.isEmpty ? _defaultBaseUrl : _envBaseUrl).trim();
    return value.replaceFirst(RegExp(r'/+$'), '');
  }

  static bool get isUsingDefaultBaseUrl => _envBaseUrl.isEmpty;

  /// Convierte rutas de media relativas (`/media/...`) en absolutas.
  static String resolveMediaUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;
    if (value.startsWith('/')) return '$apiBaseUrl$value';
    return '$apiBaseUrl/$value';
  }

  static void logRequest(String method, String path, int? status) {
    if (!kDebugMode) return;
    // Nunca se registran cabeceras, tokens ni cuerpos de petición.
    debugPrint('[ReserVa API] $method $path -> ${status ?? 'sin respuesta'}');
  }
}
