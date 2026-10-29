class Validators {
  const Validators._();

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $fieldName.';
    }
    return null;
  }

  static String? name(String? value) {
    final empty = required(value, 'tu nombre');
    if (empty != null) return empty;
    if (value!.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres.';
    }
    if (value.trim().length > 100) {
      return 'El nombre no puede superar 100 caracteres.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    final email = value.trim();
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(email)) {
      return 'Ingresa un correo electrónico válido.';
    }
    if (email.length > 100) {
      return 'El correo no puede superar 100 caracteres.';
    }
    return null;
  }

  static String? password(String? value, {bool registering = false}) {
    if (value == null || value.isEmpty) {
      return registering ? 'Crea una contraseña.' : 'Ingresa tu contraseña.';
    }
    if (registering && value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    if (value.length > 128) {
      return 'La contraseña no puede superar 128 caracteres.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña.';
    }
    if (value != original) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  static String? notes(String? value) {
    if (value != null && value.length > 500) {
      return 'Las notas no pueden superar 500 caracteres.';
    }
    return null;
  }
}
