import 'package:flutter/widgets.dart';

/// Radios de borde (§10.4).
abstract final class AppRadius {
  /// Chips e inputs.
  static const double sm = 8;

  /// Botones.
  static const double md = 12;

  /// Tarjetas.
  static const double lg = 16;

  /// Bottom sheets.
  static const double xl = 24;

  /// Píldoras.
  static const double pill = 999;

  /// `BorderRadius` de [sm].
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));

  /// `BorderRadius` de [md].
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));

  /// `BorderRadius` de [lg].
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));

  /// `BorderRadius` de [pill].
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// `BorderRadius` superior de [xl], para bottom sheets.
  static const BorderRadius xlTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
