import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import 'currency.dart';

/// Un monto de dinero: cantidad exacta más moneda.
///
/// Nunca se usa `double` para dinero. No hay conversión implícita entre
/// monedas: operar dos [Money] de monedas distintas lanza [ArgumentError].
class Money extends Equatable {
  /// Crea un monto con una cantidad exacta.
  const Money(this.amount, this.currency);

  /// Monto cero en [currency].
  Money.zero(this.currency) : amount = Decimal.zero;

  /// Crea un monto a partir de un entero.
  Money.fromInt(int value, this.currency) : amount = Decimal.fromInt(value);

  /// Parsea el string decimal que entrega la API (`"1234.56"`).
  ///
  /// Lanza [FormatException] si [value] no es un decimal válido.
  Money.parse(String value, this.currency) : amount = Decimal.parse(value);

  /// Cantidad exacta, con todos sus decimales.
  final Decimal amount;

  /// Moneda del monto.
  final Currency currency;

  /// `true` si la cantidad es menor que cero.
  bool get isNegative => amount < Decimal.zero;

  /// `true` si la cantidad es exactamente cero.
  bool get isZero => amount == Decimal.zero;

  /// `true` si la cantidad es mayor que cero.
  bool get isPositive => amount > Decimal.zero;

  /// Valor tal como viaja a la API: string decimal sin separadores.
  String get apiValue => amount.toString();

  @override
  List<Object?> get props => <Object?>[amount, currency];

  /// Suma dos montos de la misma moneda.
  Money operator +(Money other) =>
      Money(amount + _sameCurrency(other).amount, currency);

  /// Resta dos montos de la misma moneda.
  Money operator -(Money other) =>
      Money(amount - _sameCurrency(other).amount, currency);

  /// Multiplica el monto por un factor exacto (por ejemplo, una cantidad).
  Money operator *(Decimal factor) => Money(amount * factor, currency);

  /// Niega el monto.
  Money operator -() => Money(-amount, currency);

  /// `true` si este monto es menor que [other] (misma moneda).
  bool operator <(Money other) => amount < _sameCurrency(other).amount;

  /// `true` si este monto es menor o igual que [other] (misma moneda).
  bool operator <=(Money other) => amount <= _sameCurrency(other).amount;

  /// `true` si este monto es mayor que [other] (misma moneda).
  bool operator >(Money other) => amount > _sameCurrency(other).amount;

  /// `true` si este monto es mayor o igual que [other] (misma moneda).
  bool operator >=(Money other) => amount >= _sameCurrency(other).amount;

  /// Valor absoluto del monto.
  Money abs() => Money(amount.abs(), currency);

  /// Compara dos montos de la misma moneda.
  int compareTo(Money other) => amount.compareTo(_sameCurrency(other).amount);

  /// Copia el monto cambiando la cantidad.
  Money withAmount(Decimal value) => Money(value, currency);

  @override
  String toString() => '${amount.toString()} ${currency.code}';

  Money _sameCurrency(Money other) {
    if (other.currency != currency) {
      throw ArgumentError.value(
        other.currency.code,
        'other',
        'No se pueden operar montos en ${currency.code} y '
            '${other.currency.code}',
      );
    }
    return other;
  }
}
