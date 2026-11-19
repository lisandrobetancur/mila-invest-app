import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demo_credentials.dart';
import '../models/session_state.dart';
import '../services/i_authentication_service.dart';
import '../services/i_session_manager.dart';

/// Servicio de authentication. Lo implementa el módulo por override.
final Provider<IAuthenticationService> authenticationServiceProvider =
    Provider<IAuthenticationService>(
      (Ref ref) => throw UnimplementedError('authenticationServiceProvider'),
    );

/// Estado de la sesión, de solo lectura. Lo implementa el módulo.
final Provider<SessionState> sessionProvider = Provider<SessionState>(
  (Ref ref) => throw UnimplementedError('sessionProvider'),
);

/// Acciones sobre la sesión. Lo implementa el módulo.
final Provider<ISessionManager> sessionManagerProvider =
    Provider<ISessionManager>(
      (Ref ref) => throw UnimplementedError('sessionManagerProvider'),
    );

/// Credenciales demo; `null` salvo con `API_MODE=fake`.
final Provider<DemoCredentials?> demoCredentialsProvider =
    Provider<DemoCredentials?>((Ref ref) => null);
