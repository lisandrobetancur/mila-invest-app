part of 'settings.dart';

/// Controller de ajustes: cierra la sesión.
///
/// El tema y el idioma los maneja el controller de preferencias.
class SettingsViewModel extends AutoDisposeViewModel<SettingsState> {
  late ISessionManager _session;
  late AppLogger _logger;

  @override
  SettingsState initState() => const SettingsState();

  @override
  void postInit() {
    _session = ref.read(sessionManagerProvider);
    _logger = ref.read(loggerProvider);
  }

  /// Cierra la sesión. Un segundo toque en vuelo no hace nada.
  ///
  /// Al terminar, el `redirect` lleva al login.
  Future<void> signOut() async {
    if (state.logoutStatus.isSubmitting) {
      return;
    }
    final Object key = mountedKey;
    state = state.copyWith(logoutStatus: SubmitStatus.submitting);
    try {
      await _session.signOut();
      if (isMounted(key)) {
        state = state.copyWith(logoutStatus: SubmitStatus.success);
      }
    } on AuthException catch (error, stackTrace) {
      _logger.error('app_cross.settings.sign_out', error, stackTrace);
      if (isMounted(key)) {
        state = state.copyWith(logoutStatus: SubmitStatus.failure);
      }
    }
  }
}
