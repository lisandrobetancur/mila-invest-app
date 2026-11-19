part of 'settings.dart';

/// Estado de la pantalla de ajustes.
class SettingsState extends Equatable {
  /// Crea el estado.
  const SettingsState({this.logoutStatus = SubmitStatus.idle});

  /// Estado del cierre de sesión.
  final SubmitStatus logoutStatus;

  /// Copia el estado cambiando algunos campos.
  SettingsState copyWith({SubmitStatus? logoutStatus}) =>
      SettingsState(logoutStatus: logoutStatus ?? this.logoutStatus);

  @override
  List<Object?> get props => <Object?>[logoutStatus];
}
