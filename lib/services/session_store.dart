import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';

/// Persistencia local de la sesión para Flutter Web.
///
/// En web `shared_preferences` usa `localStorage` del navegador. Solo se
/// guardan el token DRF y los datos públicos del perfil; nunca la contraseña.
/// En producción se recomienda servir la app exclusivamente por HTTPS.
class SessionStore {
  static const String _sessionKey = 'reserva.session.v1';

  Future<AuthSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final session = AuthSession.fromJson(Map<String, dynamic>.from(decoded));
      if (session.token.isEmpty) return null;
      return session;
    } catch (_) {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  Future<void> write(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
