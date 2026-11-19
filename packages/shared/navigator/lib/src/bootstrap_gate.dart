import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Donde el router "estaciona" la ubicación pedida mientras la app arranca
/// o mientras el usuario se loguea, para volver a ella después.
///
/// Es un objeto mutable a propósito: lo leen y lo escriben el `redirect` del
/// router y el splash, fuera del ciclo de reconstrucción de widgets.
class BootstrapGate {
  String? _parkedLocation;
  String? _ignoredLocation;
  bool _ready = false;

  /// `true` cuando el bootstrap terminó (preferencias y sesión resueltas).
  bool get isReady => _ready;

  /// Ubicación estacionada, sin consumirla.
  String? get parkedLocation => _parkedLocation;

  /// Marca el bootstrap como terminado.
  void markReady() => _ready = true;

  /// Olvida lo estacionado cuando el usuario cierra sesión a propósito.
  ///
  /// El `redirect` que sigue al logout intentará estacionar la pantalla en
  /// la que estaba el usuario ([ignoring]); eso no debe pasar, o el próximo
  /// login lo devolvería a esa pantalla. Una sesión que *expira* no llama a
  /// este método: ahí sí se quiere volver.
  void forget({String? ignoring}) {
    _parkedLocation = null;
    _ignoredLocation = ignoring;
  }

  /// Estaciona [location] para volver a ella después.
  ///
  /// La última gana: si el usuario abre un deep link mientras otro estaba
  /// estacionado, se va al más reciente.
  void park(String location) {
    if (location == _ignoredLocation) {
      return;
    }
    _ignoredLocation = null;
    _parkedLocation = location;
  }

  /// Devuelve la ubicación estacionada y la olvida.
  String? take() {
    final String? location = _parkedLocation;
    _parkedLocation = null;
    _ignoredLocation = null;
    return location;
  }
}

/// Provider del [BootstrapGate] de la app.
final Provider<BootstrapGate> bootstrapGateProvider = Provider<BootstrapGate>(
  (Ref ref) => BootstrapGate(),
);
