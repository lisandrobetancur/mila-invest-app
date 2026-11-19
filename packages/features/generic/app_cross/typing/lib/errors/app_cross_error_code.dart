/// Códigos de error de app_cross.
enum AppCrossErrorCode {
  /// No se pudo consultar la sesión por un problema de red.
  network,

  /// No se pudieron leer o guardar las preferencias.
  storage,

  /// Cualquier otro error de arranque.
  unknown;

  /// `true` si el error es de red.
  bool get isNetwork => this == AppCrossErrorCode.network;

  /// Clave de traducción del mensaje.
  String get messageKey => switch (this) {
    AppCrossErrorCode.network => 'app_cross.error.network',
    AppCrossErrorCode.storage => 'app_cross.error.storage',
    AppCrossErrorCode.unknown => 'app_cross.error.unknown',
  };
}
