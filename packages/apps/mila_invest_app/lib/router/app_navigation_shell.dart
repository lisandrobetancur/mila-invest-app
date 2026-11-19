import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shell_ids.dart';

/// Una tab del shell de navegación.
@immutable
class _Tab {
  const _Tab({required this.id, required this.icon, required this.labelKey});

  final String id;
  final IconData icon;
  final String labelKey;
}

/// Shell de navegación: bottom bar por debajo de 768 px y rail lateral
/// desde ahí. Cada tab conserva su estado.
///
/// Las tabs tienen los mismos identificadores en las dos presentaciones.
class AppNavigationShell extends StatelessWidget {
  /// Crea el shell sobre [shell].
  const AppNavigationShell({required this.shell, super.key});

  /// Shell de go_router con una rama por tab.
  final StatefulNavigationShell shell;

  static const List<_Tab> _tabs = <_Tab>[
    _Tab(id: ShellIds.homeTab, icon: AppIcons.home, labelKey: 'shell.nav.home'),
    _Tab(
      id: ShellIds.marketTab,
      icon: AppIcons.market,
      labelKey: 'shell.nav.market',
    ),
    _Tab(
      id: ShellIds.portfolioTab,
      icon: AppIcons.portfolio,
      labelKey: 'shell.nav.portfolio',
    ),
    _Tab(
      id: ShellIds.activityTab,
      icon: AppIcons.activity,
      labelKey: 'shell.nav.activity',
    ),
  ];

  void _select(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final bool wide = AppLayout.of(context).isWide;
    return Identified(
      id: ShellIds.navigationShell,
      child: Scaffold(
        body: wide
            ? Row(
                children: <Widget>[
                  _Rail(
                    tabs: _tabs,
                    selected: shell.currentIndex,
                    onSelect: _select,
                  ),
                  const VerticalDivider(width: 1),
                  // El navigator de cada rama pone un BlockSemantics que oculta
                  // todo lo pintado antes en el mismo contenedor semántico.
                  // Con un contenedor propio, el rail conserva sus nodos.
                  Expanded(child: Semantics(container: true, child: shell)),
                ],
              )
            : shell,
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: shell.currentIndex,
                onDestinationSelected: _select,
                destinations: <Widget>[
                  for (final _Tab tab in _tabs)
                    Identified.control(
                      id: tab.id,
                      child: NavigationDestination(
                        icon: Icon(tab.icon),
                        label: context.tr(tab.labelKey),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<_Tab> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: SizedBox(
          width: 96,
          child: Column(
            children: <Widget>[
              const SizedBox(height: AppSpacing.md),
              for (int index = 0; index < tabs.length; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Identified.control(
                    id: tabs[index].id,
                    child: Semantics(
                      button: true,
                      selected: index == selected,
                      child: InkWell(
                        onTap: () => onSelect(index),
                        borderRadius: AppRadius.mdAll,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                            horizontal: AppSpacing.xxs,
                          ),
                          child: Column(
                            children: <Widget>[
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: index == selected
                                      ? theme
                                            .colorScheme
                                            .surfaceContainerHighest
                                      : Colors.transparent,
                                  borderRadius: AppRadius.pillAll,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xxs,
                                  ),
                                  child: Icon(
                                    tabs[index].icon,
                                    color: index == selected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                context.tr(tabs[index].labelKey),
                                textAlign: TextAlign.center,
                                style: AppTypography.labelSmall.copyWith(
                                  color: index == selected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
