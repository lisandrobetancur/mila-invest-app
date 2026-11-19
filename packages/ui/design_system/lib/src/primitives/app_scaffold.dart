import 'package:flutter/material.dart';

import '../tokens/app_layout.dart';
import '../tokens/app_spacing.dart';
import 'identified.dart';

/// Esqueleto de una pantalla.
///
/// Resuelve SafeArea, padding de página, ancho máximo centrado, scroll y
/// pull-to-refresh opcionales, y el slot del badge "Simulado". El [id] es la
/// raíz de la vista (`<feature>_<vista>_view`).
class AppScaffold extends StatelessWidget {
  /// Crea el esqueleto de una pantalla.
  const AppScaffold({
    required this.id,
    required this.body,
    this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.badge,
    this.bottomBar,
    this.onRefresh,
    this.scrollable = true,
    this.padded = true,
    this.maxWidth = AppSpacing.maxContentWidth,
    super.key,
  });

  /// Identificador semántico y `Key` de la raíz de la vista.
  final String id;

  /// Contenido.
  final Widget body;

  /// Título de la pantalla.
  final String? title;

  /// Botón inicial de la barra (volver o cerrar), con su identificador.
  final Widget? leading;

  /// Acciones de la barra, cada una con su identificador.
  final List<Widget> actions;

  /// Slot del badge "Simulado", junto al título.
  final Widget? badge;

  /// Acciones fijas al pie (por ejemplo, "Comprar" / "Vender").
  final Widget? bottomBar;

  /// Pull-to-refresh. Con `null` no hay `RefreshIndicator`.
  final Future<void> Function()? onRefresh;

  /// Envuelve [body] en un scroll. Las vistas con lista propia lo apagan.
  final bool scrollable;

  /// Aplica el padding de página a [body].
  final bool padded;

  /// Ancho máximo del contenido centrado.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final AppLayout layout = AppLayout.of(context);
    final String? heading = title;
    final Widget? simulatedBadge = badge;
    final Widget? footer = bottomBar;
    final Future<void> Function()? refresh = onRefresh;
    final bool hasBar =
        heading != null ||
        leading != null ||
        simulatedBadge != null ||
        actions.isNotEmpty;

    Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padded
              ? EdgeInsets.symmetric(
                  horizontal: layout.pagePadding,
                  vertical: AppSpacing.md,
                )
              : EdgeInsets.zero,
          child: body,
        ),
      ),
    );
    if (scrollable) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }
    if (refresh != null) {
      content = RefreshIndicator(onRefresh: refresh, child: content);
    }

    return Identified(
      id: id,
      child: Scaffold(
        appBar: hasBar
            ? AppBar(
                automaticallyImplyLeading: false,
                leading: leading,
                titleSpacing: leading == null ? layout.pagePadding : 0,
                title: Row(
                  children: <Widget>[
                    if (heading != null)
                      Flexible(
                        child: Text(
                          heading,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (simulatedBadge != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.xs),
                      simulatedBadge,
                    ],
                  ],
                ),
                actions: <Widget>[
                  ...actions,
                  const SizedBox(width: AppSpacing.xs),
                ],
              )
            : null,
        body: SafeArea(child: content),
        bottomNavigationBar: footer == null
            ? null
            : SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: layout.pagePadding,
                        vertical: AppSpacing.sm,
                      ),
                      child: footer,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
