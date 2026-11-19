/// Identificadores semánticos del shell (§11.1).
abstract final class ShellIds {
  /// Raíz del shell de navegación.
  static const String navigationShell = 'nav_shell_view';

  /// Tab Inicio.
  static const String homeTab = 'nav_home_tab';

  /// Tab Mercado.
  static const String marketTab = 'nav_market_tab';

  /// Tab Portafolio.
  static const String portfolioTab = 'nav_portfolio_tab';

  /// Tab Actividad.
  static const String activityTab = 'nav_activity_tab';

  /// Raíz de "no encontrado".
  static const String notFoundView = 'shell_not_found_view';

  /// Título de "no encontrado".
  static const String notFoundTitleText = 'shell_not_found_title_text';

  /// "Ir al inicio" desde "no encontrado".
  static const String notFoundHomeButton = 'shell_not_found_home_button';

  /// Todos los ids estáticos, para el test de unicidad y formato.
  static const List<String> all = <String>[
    navigationShell,
    homeTab,
    marketTab,
    portfolioTab,
    activityTab,
    notFoundView,
    notFoundTitleText,
    notFoundHomeButton,
  ];
}
