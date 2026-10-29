import 'package:flutter/foundation.dart';

import '../core/errors/api_exception.dart';
import '../models/auth_session.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/session_store.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController({
    required ApiClient api,
    required SessionStore store,
    AuthService? authService,
  }) : _api = api,
       _store = store,
       _auth = authService ?? AuthService(api);

  final ApiClient _api;
  final SessionStore _store;
  final AuthService _auth;

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  String? _token;
  bool _busy = false;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isBusy => _busy;
  String? get token => _token;

  String get displayName {
    final current = _user;
    if (current == null) return 'Comensal';
    return current.firstName.isEmpty ? current.nombre : current.firstName;
  }

  Future<void> bootstrap() async {
    final stored = await _store.read();
    if (stored == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _token = stored.token;
    _user = stored.user;
    _api.token = stored.token;

    try {
      final fresh = await _auth.me();
      _user = fresh;
      await _store.write(AuthSession(token: stored.token, user: fresh));
      _status = AuthStatus.authenticated;
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _clearLocal();
        _status = AuthStatus.unauthenticated;
      } else {
        // Un corte de red no debe destruir una sesión válida guardada.
        _status = AuthStatus.authenticated;
      }
    } catch (_) {
      _status = AuthStatus.authenticated;
    }

    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _setBusy(true);
    try {
      final session = await _auth.login(email: email, password: password);
      await _applySession(session);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    try {
      final session = await _auth.register(
        nombre: nombre,
        email: email,
        password: password,
      );
      await _applySession(session);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    _setBusy(true);
    try {
      await _auth.logout();
    } on ApiException {
      // El token pudo expirar: el cierre de sesión local es igualmente válido.
    } catch (_) {
      // Sin red el usuario también debe poder salir en este dispositivo.
    } finally {
      await _clearLocal();
      _status = AuthStatus.unauthenticated;
      _setBusy(false);
      notifyListeners();
    }
  }

  /// Se invoca cuando una pantalla recibe un 401.
  Future<void> expireSession() async {
    await _clearLocal();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;
    final fresh = await _auth.me();
    _user = fresh;
    final currentToken = _token;
    if (currentToken != null) {
      await _store.write(AuthSession(token: currentToken, user: fresh));
    }
    notifyListeners();
  }

  Future<void> _applySession(AuthSession session) async {
    _token = session.token;
    _user = session.user;
    _api.token = session.token;
    await _store.write(session);
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> _clearLocal() async {
    _token = null;
    _user = null;
    _api.token = null;
    await _store.clear();
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();
  }
}
