/// Rutas de wallet.
abstract final class WalletRoutes {
  /// Path de la billetera.
  static const String accountsPath = '/wallet';

  /// Nombre de la ruta de la billetera.
  static const String accountsName = 'wallet.accounts';

  /// Path del depósito (hoja modal), con la moneda preseleccionada.
  static const String depositPath = '/wallet/deposit/:$currencyParam';

  /// Nombre de la ruta del depósito.
  static const String depositName = 'wallet.deposit';

  /// Parámetro de path con el código de moneda.
  static const String currencyParam = 'currency';

  /// Ubicación del depósito en [currencyCode].
  static String depositLocation(String currencyCode) =>
      '/wallet/deposit/$currencyCode';
}
