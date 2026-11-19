import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

import '../enums/market_session_status.dart';

/// Estado del mercado de un país, como lo entrega `GET /meta/countries`.
///
/// La app no tiene horarios escritos en el código: todo viene de la API.
class CountryMarket extends Equatable {
  /// Crea el estado de mercado.
  const CountryMarket({
    required this.country,
    required this.status,
    required this.opensAt,
    required this.closesAt,
  });

  /// País.
  final Country country;

  /// Abierto o cerrado.
  final MarketSessionStatus status;

  /// Próxima (o actual) apertura, en UTC.
  final DateTime opensAt;

  /// Próximo cierre, en UTC.
  final DateTime closesAt;

  /// `true` si se puede operar.
  bool get isOpen => status == MarketSessionStatus.open;

  @override
  List<Object?> get props => <Object?>[country, status, opensAt, closesAt];
}
