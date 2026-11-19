import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Donde el router "estaciona" la ubicación pedida mientras la app arranca
/// o mientras el usuario se loguea, para volver a ella después.
///
/// Es un objeto mutable a propósito: lo leen y lo escriben el `redirect` del
/// router y el splash, fuera del ciclo de reconstrucción de widgets.
class BootstrapGate {
  String? _parkedLocation;
  bool _ready = false;

  /// `true` cuando el bootstrap terminó (preferencias y sesión resueltas).
  bool get isReady => _ready;

  /// Ubicación estacionada, sin consumirla.
  String? get parkedLocation => _parkedLocation;

  /// Marca el bootstrap como terminado.
  void markReady() => _ready = true;

  /// Estaciona [location] para volver a ella después.
  ///
  /// La última gana: si el usuario abre un deep link mientras otro estaba
  /// estacionado, se va al más reciente.
  void park(String location) => _parkedLocation = location;

  /// Vuelve al estado inicial (logout).
  void reset() => _parkedLocation = null;

  /// Devuelve la ubicación estacionada y la olvida.
  String? take() {
    final String? location = _parkedLocation;
    _parkedLocation = null;
    return location;
  }
}

/// Provider del [BootstrapGate] de la app.
final Provider<BootstrapGate> bootstrapGateProvider = Provider<BootstrapGate>(
  (Ref ref) => BootstrapGate(),
);
