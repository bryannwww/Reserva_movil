/// Error normalizado de la API con mensajes aptos para el usuario final.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const <String, List<String>>{},
    this.isNetworkError = false,
    this.isUnauthorized = false,
  });

  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;
  final bool isNetworkError;
  final bool isUnauthorized;

  String? fieldError(String field) {
    final errors = fieldErrors[field];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }

  bool get hasFieldErrors => fieldErrors.isNotEmpty;

  factory ApiException.network() {
    return ApiException(
      message:
          'No pudimos conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
      isNetworkError: true,
    );
  }

  factory ApiException.timeout() {
    return ApiException(
      message:
          'El servidor tardó demasiado en responder. Inténtalo de nuevo en unos momentos.',
      isNetworkError: true,
    );
  }

  factory ApiException.fromResponse(int status, dynamic body) {
    final fieldErrors = <String, List<String>>{};
    String detail = '';

    if (body is Map) {
      for (final entry in body.entries) {
        final key = '${entry.key}';
        final value = entry.value;
        if (key == 'detail') {
          detail = _stringify(value);
          continue;
        }
        if (key == 'non_field_errors') {
          final text = _stringify(value);
          if (text.isNotEmpty) detail = detail.isEmpty ? text : detail;
          continue;
        }
        final messages = value is List
            ? value.map(_stringify).where((item) => item.isNotEmpty).toList()
            : <String>[if (_stringify(value).isNotEmpty) _stringify(value)];
        if (messages.isNotEmpty) fieldErrors[key] = messages;
      }
    }

    final unauthorized = status == 401;
    final message = switch (status) {
      400 =>
        detail.isNotEmpty
            ? detail
            : fieldErrors.isNotEmpty
            ? fieldErrors.values.first.first
            : 'Revisa la información enviada e inténtalo de nuevo.',
      401 =>
        detail.isNotEmpty
            ? detail
            : 'Tu sesión venció o no es válida. Inicia sesión de nuevo.',
      403 =>
        detail.isNotEmpty
            ? detail
            : 'No tienes permiso para realizar esta operación.',
      404 =>
        detail.isNotEmpty
            ? detail
            : 'No encontramos la información solicitada.',
      409 =>
        detail.isNotEmpty
            ? detail
            : 'La información cambió mientras la consultábamos. Actualiza e inténtalo de nuevo.',
      429 => 'Demasiados intentos. Espera un momento antes de continuar.',
      >= 500 => 'El servidor tuvo un problema. Inténtalo de nuevo más tarde.',
      _ =>
        detail.isNotEmpty
            ? detail
            : 'No pudimos completar la operación (error $status).',
    };

    return ApiException(
      message: message,
      statusCode: status,
      fieldErrors: fieldErrors,
      isUnauthorized: unauthorized,
    );
  }

  static String _stringify(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is List) {
      return value.map(_stringify).where((item) => item.isNotEmpty).join(' ');
    }
    if (value is Map) {
      return value.values
          .map(_stringify)
          .where((item) => item.isNotEmpty)
          .join(' ');
    }
    return '$value'.trim();
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
