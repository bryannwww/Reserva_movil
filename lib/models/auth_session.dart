import 'user.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: '${json['token'] ?? ''}',
      user: User.fromJson(
        json['user'] is Map
            ? Map<String, dynamic>.from(json['user'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }
}
