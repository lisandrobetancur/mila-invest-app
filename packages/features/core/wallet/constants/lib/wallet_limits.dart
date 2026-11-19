/// Valores fijos de wallet.
abstract final class WalletLimits {
  /// Montos sugeridos de depósito, por código de moneda.
  static const Map<String, List<String>> suggestedDeposits =
      <String, List<String>>{
        'COP': <String>['500000', '1000000', '5000000'],
        'MXN': <String>['2000', '5000', '20000'],
        'PEN': <String>['500', '1000', '5000'],
      };

  /// Monto máximo de un depósito virtual, en unidades de la moneda.
  static const String maxDeposit = '1000000000';
}
