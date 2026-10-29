import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/errors/api_exception.dart';

/// Cliente HTTP centralizado. La URL base se configura en [AppConfig].
///
/// Todas las solicitudes protegidas envían `Authorization: Token <token>`,
/// el esquema real configurado en Django REST Framework.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  String? _token;

  String get baseUrl => _baseUrl;

  String? get token => _token;

  set token(String? value) {
    _token = (value == null || value.isEmpty) ? null : value;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    return _send('GET', path, query: query);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) {
    return _send('POST', path, body: body, query: query);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    final uri = _buildUri(path, query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Token $_token',
      if (body != null) 'Content-Type': 'application/json; charset=utf-8',
    };

    http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client
          .send(request)
          .timeout(AppConfig.requestTimeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException.timeout();
    } catch (_) {
      throw ApiException.network();
    }

    AppConfig.logRequest(method, path, response.statusCode);

    dynamic decoded;
    final text = utf8.decode(response.bodyBytes);
    if (text.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(text);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw ApiException.fromResponse(response.statusCode, decoded);
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final queryParameters = <String, String>{};
    query?.forEach((key, value) {
      if (value == null) return;
      final text = '$value'.trim();
      if (text.isEmpty) return;
      queryParameters[key] = text;
    });
    return Uri.parse('$_baseUrl$normalized').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  void dispose() => _client.close();
}
