import 'package:equatable/equatable.dart';

/// Datos del build que muestra la pantalla de ajustes.
class AppInfo extends Equatable {
  /// Crea los datos del build.
  const AppInfo({
    required this.version,
    required this.apiMode,
    required this.showApiMode,
  });

  /// Versión de la app.
  final String version;

  /// Modo de API activo (`fake` / `remote`).
  final String apiMode;

  /// `true` si el modo de API se muestra: solo fuera de release.
  final bool showApiMode;

  @override
  List<Object?> get props => <Object?>[version, apiMode, showApiMode];
}
