/// Rutas de market.
abstract final class MarketRoutes {
  /// Path de la lista de instrumentos (tab Mercado).
  static const String listPath = '/market';

  /// Nombre de la ruta de la lista.
  static const String listName = 'market.list';

  /// Path del detalle, relativo a la lista.
  static const String detailSubPath = 'instrument/:$idParam';

  /// Nombre de la ruta del detalle.
  static const String detailName = 'market.detail';

  /// Parámetro de path con el id del instrumento.
  static const String idParam = 'id';

  /// Parámetro de query del filtro por país.
  static const String countryQuery = 'country';

  /// Parámetro de query del filtro por tipo.
  static const String typeQuery = 'type';

  /// Parámetro de query de la búsqueda.
  static const String searchQuery = 'q';

  /// Ubicación del detalle del instrumento [id].
  static String detailLocation(String id) =>
      '$listPath/instrument/${Uri.encodeComponent(id)}';
}
