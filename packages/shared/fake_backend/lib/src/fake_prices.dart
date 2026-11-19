import 'fake_instruments.dart';

/// Un punto de una serie de precios: instante y precio en centavos.
typedef FakePricePoint = ({DateTime t, int cents});

/// Precios simulados y determinísticos del backend falso.
///
/// Todo es aritmética entera sobre centavos, con un generador de
/// Park–Miller cuyos productos caben en 53 bits: la misma semilla da la
/// misma serie en la VM y en web.
abstract final class FakePrices {
  /// Rangos soportados por `GET /instruments/{id}/prices`.
  static const List<String> ranges = <String>['1D', '1W', '1M', '3M', '1Y'];

  static const int _modulus = 2147483647;
  static const int _multiplier = 48271;

  /// Oscilación acotada alrededor del precio del seed, en puntos básicos.
  static const List<int> _ticksBp = <int>[0, 4, -3, 7, 2, -5, 1, -2, 6, -4];

  /// Segundos que dura cada tick del precio "en vivo".
  static const int tickSeconds = 15;

  /// Precio vigente de [instrument] en [now], en centavos.
  ///
  /// Con [live] en `false` es siempre el último precio del seed. Con `true`
  /// oscila unos pocos puntos básicos por tick; con un reloj fijo no cambia.
  static int currentCents(
    FakeInstrument instrument,
    DateTime now, {
    required bool live,
  }) {
    if (!live) {
      return instrument.lastCents;
    }
    final int bucket = now.millisecondsSinceEpoch ~/ (tickSeconds * 1000);
    final int bp =
        _ticksBp[(bucket + instrument.ticker.length) % _ticksBp.length];
    return instrument.lastCents + instrument.lastCents * bp ~/ 10000;
  }

  /// Serie de [range] para [instrument], que termina en [lastCents].
  static List<FakePricePoint> series(
    FakeInstrument instrument,
    String range,
    DateTime now,
    int lastCents,
  ) {
    final (int count, Duration step, int volatilityBp) = switch (range) {
      '1W' => (60, const Duration(hours: 2), 28),
      '1M' => (30, const Duration(days: 1), 90),
      '3M' => (90, const Duration(days: 1), 110),
      '1Y' => (52, const Duration(days: 7), 230),
      _ => (78, const Duration(minutes: 5), 12),
    };
    int seed = _seedOf(instrument.ticker, ranges.indexOf(range) + 1);
    final List<int> cents = List<int>.filled(count, lastCents);
    for (int index = count - 2; index >= 0; index--) {
      seed = seed * _multiplier % _modulus;
      final int move =
          seed % (2 * volatilityBp + 1) - volatilityBp + volatilityBp ~/ 12;
      final int previous = cents[index + 1] * 10000 ~/ (10000 + move);
      cents[index] = previous < 1 ? 1 : previous;
    }
    final DateTime end = DateTime.utc(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    return <FakePricePoint>[
      for (int index = 0; index < count; index++)
        (t: end.subtract(step * (count - 1 - index)), cents: cents[index]),
    ];
  }

  static int _seedOf(String ticker, int salt) {
    int seed = 7 * salt;
    for (int index = 0; index < ticker.length; index++) {
      seed = (seed + ticker.codeUnitAt(index) * (index + 1) * 31) % _modulus;
    }
    return seed == 0 ? 1 : seed;
  }
}
