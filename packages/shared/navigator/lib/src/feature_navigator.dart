import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_manager.dart';

/// Base del navigator de cada feature.
///
/// Cada feature deriva el suyo con métodos de intención
/// (`goToInstrument(id)`, `openOrderTicket(id, side)`) y lo registra como
/// `NotifierProvider<XNavigator, void>`. Las vistas y los controllers nunca
/// importan `go_router`: llaman a estos métodos.
abstract class FeatureNavigator extends Notifier<void> {
  /// Fachada de navegación.
  @protected
  NavigationManager get navigation => ref.read(navigationManagerProvider);

  @override
  void build() {}
}
