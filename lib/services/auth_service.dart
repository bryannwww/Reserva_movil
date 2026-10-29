import '../core/errors/api_exception.dart';
import '../models/auth_session.dart';
import '../models/json_utils.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/api/auth/login/',
      body: {'email': email.trim().toLowerCase(), 'password': password},
    );
    return _parseSession(data);
  }

  Future<AuthSession> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/api/auth/register/',
      body: {
        'nombre': nombre.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    return _parseSession(data);
  }

  Future<User> me() async {
    final data = await _api.get('/api/auth/me/');
    if (data is! Map || data['user'] is! Map) {
      throw ApiException(
        message:
            'El servidor devolvió un perfil inesperado. Inténtalo de nuevo.',
      );
    }
    return User.fromJson(asJsonMap(data['user']));
  }

  /// Revoca el token en el servidor. Un fallo de red no debe impedir el cierre
  /// de sesión local, por eso el controlador ignora los errores.
  Future<void> logout() async {
    await _api.post('/api/auth/logout/');
  }

  AuthSession _parseSession(dynamic data) {
    if (data is! Map) {
      throw ApiException(
        message:
            'El servidor devolvió una respuesta inesperada. Inténtalo de nuevo.',
      );
    }
    final token = asString(data['token']);
    if (token.isEmpty || data['user'] is! Map) {
      throw ApiException(
        message:
            'El servidor no devolvió una sesión válida. Inténtalo de nuevo.',
      );
    }
    return AuthSession(
      token: token,
      user: User.fromJson(asJsonMap(data['user'])),
    );
  }
}
