part of 'session.dart';

/// Provider del controller de sesión. Vive toda la app.
final NotifierProvider<SessionViewModel, SessionState>
sessionViewModelProvider = NotifierProvider<SessionViewModel, SessionState>(
  SessionViewModel.new,
);
