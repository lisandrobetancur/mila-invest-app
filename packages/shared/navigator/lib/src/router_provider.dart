import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider del router de la app.
///
/// Lo sobrescribe el shell con su builder, para que las features naveguen
/// sin depender del shell.
final Provider<GoRouter> goRouterProvider = Provider<GoRouter>(
  (Ref ref) => throw UnimplementedError('goRouterProvider'),
);
