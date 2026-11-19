/// Estado de una vista que muestra datos.
///
/// Toda vista con datos resuelve exactamente estos cuatro casos con un
/// `switch` exhaustivo, cada uno en su propio archivo.
enum ViewStatus {
  /// Cargando por primera vez: se muestra el shimmer.
  loading,

  /// Hay datos para mostrar.
  data,

  /// La carga terminó bien pero no hay nada que mostrar.
  empty,

  /// La carga falló: se muestra el mensaje y "Reintentar".
  error;

  /// `true` si la vista está cargando.
  bool get isLoading => this == ViewStatus.loading;

  /// `true` si la vista tiene datos.
  bool get isData => this == ViewStatus.data;

  /// `true` si la vista está vacía.
  bool get isEmpty => this == ViewStatus.empty;

  /// `true` si la vista falló.
  bool get isError => this == ViewStatus.error;
}

/// Estado de una acción de escritura (enviar orden, depositar, login).
enum SubmitStatus {
  /// Sin enviar.
  idle,

  /// Enviando: el botón queda deshabilitado y con indicador.
  submitting,

  /// La escritura terminó bien.
  success,

  /// La escritura falló.
  failure;

  /// `true` si no hay nada en vuelo.
  bool get isIdle => this == SubmitStatus.idle;

  /// `true` si hay una petición en vuelo.
  bool get isSubmitting => this == SubmitStatus.submitting;

  /// `true` si la última escritura terminó bien.
  bool get isSuccess => this == SubmitStatus.success;

  /// `true` si la última escritura falló.
  bool get isFailure => this == SubmitStatus.failure;
}
