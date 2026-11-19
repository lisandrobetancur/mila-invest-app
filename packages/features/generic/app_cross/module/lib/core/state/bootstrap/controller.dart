part of 'bootstrap.dart';

/// Controller del arranque.
///
/// Lee las preferencias, resuelve la sesión (`GET /me` si hay token), abre
/// el `BootstrapGate` y deja que el `redirect` decida entre onboarding,
/// login o la ubicación estacionada.
class BootstrapViewModel extends ViewModel<BootstrapState> {
  late ISessionManager _session;
  late BootstrapGate _gate;
  late AppCrossNavigator _navigator;
  late AppLogger _logger;
  bool _running = false;

  @override
  BootstrapState initState() => const BootstrapState();

  @override
  void postInit() {
    _session = ref.read(sessionManagerProvider);
    _gate = ref.read(bootstrapGateProvider);
    _navigator = ref.read(appCrossNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    runPostBuild(start);
  }

  /// Arranca (o reintenta) el bootstrap. Un segundo llamado en vuelo no
  /// hace nada.
  Future<void> start() async {
    if (_running) {
      return;
    }
    _running = true;
    final Object key = mountedKey;
    state = state.copyWith(status: ViewStatus.loading, errorKey: null);
    try {
      await ref.read(preferencesViewModelProvider.notifier).load();
      await _session.restore();
      if (!isMounted(key)) {
        return;
      }
      _gate.markReady();
      state = state.copyWith(status: ViewStatus.data);
      _navigator.continueAfterBootstrap();
    } on AuthException catch (error, stackTrace) {
      _logger.error('app_cross.bootstrap', error, stackTrace);
      if (!isMounted(key)) {
        return;
      }
      final AppCrossErrorCode code = error.code.isNetwork
          ? AppCrossErrorCode.network
          : AppCrossErrorCode.unknown;
      state = state.copyWith(
        status: ViewStatus.error,
        errorKey: code.messageKey,
        isNetworkError: code.isNetwork,
      );
    } finally {
      _running = false;
    }
  }
}
