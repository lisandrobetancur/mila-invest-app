part of 'preferences.dart';

/// Estado de las preferencias del usuario.
class PreferencesState extends Equatable {
  /// Crea el estado.
  const PreferencesState({
    this.preferences = const AppPreferences(),
    this.loaded = false,
  });

  /// Preferencias vigentes.
  final AppPreferences preferences;

  /// `true` cuando ya se leyeron del dispositivo.
  final bool loaded;

  /// Copia el estado cambiando algunos campos.
  PreferencesState copyWith({AppPreferences? preferences, bool? loaded}) =>
      PreferencesState(
        preferences: preferences ?? this.preferences,
        loaded: loaded ?? this.loaded,
      );

  @override
  List<Object?> get props => <Object?>[preferences, loaded];
}
