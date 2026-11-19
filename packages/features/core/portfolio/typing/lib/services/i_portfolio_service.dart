import '../models/portfolio.dart';

/// Servicio de portfolio. Sus métodos lanzan `PortfolioException`.
abstract interface class IPortfolioService {
  /// Portafolio del usuario, totalizado en su moneda base.
  Future<Portfolio> portfolio();
}
