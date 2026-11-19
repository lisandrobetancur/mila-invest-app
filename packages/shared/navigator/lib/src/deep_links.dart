/// Helpers de deep links.
abstract final class DeepLinks {
  /// Scheme propio de la app.
  static const String scheme = 'milainvest';

  /// Convierte un deep link en una ubicación interna del router.
  ///
  /// `milainvest://market/instrument/ECOPETROL-CO` pasa a
  /// `/market/instrument/ECOPETROL-CO`. Con el scheme propio, lo que la
  /// URI llama "host" es en realidad el primer segmento del path. Una URL
  /// http(s) (web o universal link) conserva su path. La query se mantiene.
  static String normalize(Uri uri) {
    final List<String> segments = <String>[
      if (uri.scheme == scheme && uri.host.isNotEmpty) uri.host,
      ...uri.pathSegments.where((String segment) => segment.isNotEmpty),
    ];
    final String path = '/${segments.join('/')}';
    return uri.hasQuery ? '$path?${uri.query}' : path;
  }

  /// `true` si [uri] usa el scheme propio de la app.
  static bool isAppLink(Uri uri) => uri.scheme == scheme;
}
