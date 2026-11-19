import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

import '../enums/instrument_type.dart';

/// Instrumento negociable, con su último precio.
class Instrument extends Equatable {
  /// Crea un instrumento.
  const Instrument({
    required this.id,
    required this.ticker,
    required this.name,
    required this.country,
    required this.type,
    required this.lastPrice,
    required this.change,
    required this.changePercent,
    required this.updatedAt,
  });

  /// Id: `<TICKER>-<PAÍS>`.
  final String id;

  /// Ticker.
  final String ticker;

  /// Nombre del emisor.
  final String name;

  /// País del mercado.
  final Country country;

  /// Tipo.
  final InstrumentType type;

  /// Último precio.
  final Money lastPrice;

  /// Variación absoluta del día.
  final Money change;

  /// Variación porcentual del día (`1.49` es 1,49 %).
  final Decimal changePercent;

  /// Instante del último precio, en UTC.
  final DateTime updatedAt;

  /// Moneda en la que cotiza.
  Currency get currency => lastPrice.currency;

  /// Copia el instrumento cambiando algunos campos.
  Instrument copyWith({
    Money? lastPrice,
    Money? change,
    Decimal? changePercent,
    DateTime? updatedAt,
  }) => Instrument(
    id: id,
    ticker: ticker,
    name: name,
    country: country,
    type: type,
    lastPrice: lastPrice ?? this.lastPrice,
    change: change ?? this.change,
    changePercent: changePercent ?? this.changePercent,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    ticker,
    name,
    country,
    type,
    lastPrice,
    change,
    changePercent,
    updatedAt,
  ];
}
