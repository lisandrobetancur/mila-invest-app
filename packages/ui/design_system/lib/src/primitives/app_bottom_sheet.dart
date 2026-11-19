import 'package:flutter/material.dart';

import '../tokens/app_layout.dart';
import '../tokens/app_spacing.dart';
import 'identified.dart';

/// Hoja modal: bottom sheet en mobile, diálogo centrado en web ancho.
///
/// El identificador de la raíz es el mismo en las dos presentaciones.
abstract final class AppBottomSheet {
  /// Ancho máximo del diálogo en web ancho.
  static const double dialogMaxWidth = 480;

  /// Envuelve [child] con el identificador y el padding de una hoja.
  ///
  /// Lo usan [show] y las rutas modales del shell, para que una hoja abierta
  /// por ruta y una abierta desde una vista sean iguales.
  static Widget frame({
    required BuildContext context,
    required String id,
    required Widget child,
  }) => Identified(
    id: id,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: child,
    ),
  );

  /// Muestra una hoja modal con el contenido de [builder].
  static Future<T?> show<T>({
    required BuildContext context,
    required String id,
    required WidgetBuilder builder,
  }) {
    if (AppLayout.of(context).isWide) {
      return showDialog<T>(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: dialogMaxWidth),
            child: Identified(
              id: id,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: builder(context),
              ),
            ),
          ),
        ),
      );
    }
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) =>
          frame(context: context, id: id, child: builder(context)),
    );
  }
}
