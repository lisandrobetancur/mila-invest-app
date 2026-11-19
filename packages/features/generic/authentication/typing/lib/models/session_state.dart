import 'package:equatable/equatable.dart';

import '../enums/session_status.dart';
import 'user.dart';

/// Estado de la sesión: de él depende el `redirect` del router.
class SessionState extends Equatable {
  /// La app todavía no resolvió la sesión.
  const SessionState.unknown() : status = SessionStatus.unknown, user = null;

  /// Hay un usuario con sesión válida.
  const SessionState.authenticated(User this.user)
    : status = SessionStatus.authenticated;

  /// No hay sesión.
  const SessionState.unauthenticated()
    : status = SessionStatus.unauthenticated,
      user = null;

  /// Estado de la sesión.
  final SessionStatus status;

  /// Usuario con sesión; `null` salvo en `authenticated`.
  final User? user;

  /// `true` si hay un usuario con sesión.
  bool get isAuthenticated => status == SessionStatus.authenticated;

  /// `true` si la sesión todavía no se resolvió.
  bool get isUnknown => status == SessionStatus.unknown;

  @override
  List<Object?> get props => <Object?>[status, user];
}
