import 'package:equatable/equatable.dart';
import 'package:market_typing/market_typing.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:transactions_typing/transactions_typing.dart';

/// Resumen del inicio: portafolio, top movers y últimas transacciones.
class DashboardSummary extends Equatable {
  /// Crea el resumen.
  const DashboardSummary({
    required this.portfolio,
    required this.gainers,
    required this.losers,
    required this.recentTransactions,
  });

  /// Totales del portafolio.
  final PortfolioSummary portfolio;

  /// Los que más suben hoy.
  final List<Instrument> gainers;

  /// Los que más bajan hoy.
  final List<Instrument> losers;

  /// Últimas transacciones.
  final List<Transaction> recentTransactions;

  /// `true` para un usuario nuevo: sin saldo ni inversiones.
  bool get isNewUser => portfolio.isEmpty;

  @override
  List<Object?> get props => <Object?>[
    portfolio,
    gainers,
    losers,
    recentTransactions,
  ];
}
