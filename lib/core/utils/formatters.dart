import 'package:flutter/material.dart';

const List<String> _weekdays = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

const List<String> _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

const List<String> _monthsShort = [
  'ENE',
  'FEB',
  'MAR',
  'ABR',
  'MAY',
  'JUN',
  'JUL',
  'AGO',
  'SEP',
  'OCT',
  'NOV',
  'DIC',
];

String capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

/// Formato de moneda colombiana sin decimales: `$65.000`.
String formatCurrency(num value) {
  final rounded = value.round();
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${rounded < 0 ? '-' : ''}\$${buffer.toString()}';
}

String formatLongDate(DateTime date, {bool includeWeekday = true}) {
  final text = includeWeekday
      ? '${_weekdays[date.weekday - 1]}, ${date.day} de ${_months[date.month - 1]} de ${date.year}'
      : '${date.day} de ${_months[date.month - 1]} de ${date.year}';
  return capitalize(text);
}

String formatShortDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${_monthsShort[date.month - 1]}';
}

String monthShort(DateTime date) => _monthsShort[date.month - 1];

String formatTimeOfDay(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

/// Convierte `19:30` o `19:30:00` en `19:30`.
String formatApiTime(String raw) {
  final parts = raw.split(':');
  if (parts.length >= 2) {
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour != null && minute != null) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
  }
  return raw;
}

String isoDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String isoTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

DateTime? parseApiDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  return DateTime.tryParse(raw.trim());
}

TimeOfDay? parseApiTime(String? raw) {
  if (raw == null) return null;
  final parts = raw.trim().split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

/// Etiqueta amable para una fecha cercana.
String relativeDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final difference = target.difference(today).inDays;
  if (difference == 0) return 'Hoy';
  if (difference == 1) return 'Mañana';
  return formatLongDate(target);
}

String statusLabel(String raw) {
  switch (raw.toLowerCase()) {
    case 'pendiente':
      return 'Pendiente';
    case 'confirmada':
      return 'Confirmada';
    case 'asistio':
      return 'Asistió';
    case 'completada':
      return 'Completada';
    case 'cancelada':
      return 'Cancelada';
    case 'no_asistio':
      return 'No asistió';
    default:
      return capitalize(raw.replaceAll('_', ' '));
  }
}

String initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'R';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
