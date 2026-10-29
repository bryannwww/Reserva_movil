int asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? fallback;
}

int? asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

double asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}') ?? fallback;
}

String asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value is String ? value : '$value';
}

String? asNullableString(dynamic value) {
  if (value == null) return null;
  final text = value is String ? value : '$value';
  return text.trim().isEmpty ? null : text;
}

bool asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = '$value'.toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return fallback;
}

Map<String, dynamic> asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry('$key', item));
  return const <String, dynamic>{};
}

List<dynamic> asJsonList(dynamic value) {
  if (value is List) return value;
  return const <dynamic>[];
}
