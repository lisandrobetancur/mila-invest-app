import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/portfolio.dart';
import '../services/i_portfolio_service.dart';

/// Servicio de portfolio. Lo implementa el módulo por override.
final Provider<IPortfolioService> portfolioServiceProvider =
    Provider<IPortfolioService>(
      (Ref ref) => throw UnimplementedError('portfolioServiceProvider'),
    );

/// Portafolio del usuario, de solo lectura.
///
/// Lo leen el detalle de instrumento (tu posición), el ticket de orden
/// (cantidad para vender) y el dashboard. Quien ejecuta una orden lo
/// invalida con `ref.invalidate(portfolioProvider)`.
final FutureProvider<Portfolio> portfolioProvider = FutureProvider<Portfolio>(
  (Ref ref) => throw UnimplementedError('portfolioProvider'),
);
