part of 'session.dart';

/// Controller de la sesión: `unknown`, `authenticated(user)` o
/// `unauthenticated`.
///
/// Escucha el aviso de "sesión expirada" de la red: si el refresh falla, la
/// sesión pasa a `unauthenticated` y el `redirect` lleva al login
/// conservando la ubicación en el `BootstrapGate`.
class SessionViewModel extends ViewModel<SessionState> {
  late IAuthenticationService _service;
  late AppLogger _logger;
  StreamSubscription<SessionEvent>? _events;

  @override
  SessionState initState() => const SessionState.unknown();

  @override
  void postInit() {
    _service = ref.read(authenticationServiceProvider);
    _logger = ref.read(loggerProvider);
    _events = ref.read(sessionEventsProvider).stream.listen(_onSessionEvent);
    ref.onDispose(() => _events?.cancel());
  }

  /// Marca la sesión como iniciada (login o registro).
  void authenticate(User user) => state = SessionState.authenticated(user);

  /// Resuelve la sesión guardada al arrancar.
  ///
  /// Un error de red se propaga: el splash lo muestra con "Reintentar" y la
  /// sesión guardada no se descarta.
  Future<void> restore() async {
    final User? user = await _service.restoreSession();
    state = user == null
        ? const SessionState.unauthenticated()
        : SessionState.authenticated(user);
  }

  /// Cierra la sesión por decisión del usuario.
  Future<void> signOut() async {
    ref.read(authNavigatorProvider.notifier).forgetCurrentLocation();
    await _service.logout();
    state = const SessionState.unauthenticated();
  }

  void _onSessionEvent(SessionEvent event) {
    if (state.isAuthenticated) {
      _logger.info('authentication.session.expired');
      state = const SessionState.unauthenticated();
    }
  }
}

/// Adapta el controller al contrato [ISessionManager] que ven otras
/// features.
class SessionManager implements ISessionManager {
  /// Crea el adaptador.
  const SessionManager(this._viewModel);

  final SessionViewModel _viewModel;

  @override
  Future<void> restore() => _viewModel.restore();

  @override
  Future<void> signOut() => _viewModel.signOut();
}
