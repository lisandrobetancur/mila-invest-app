import 'package:flutter/material.dart';

import 'app_button.dart';
import 'identified.dart';

/// Diálogo de confirmación.
///
/// Lleva un identificador en la raíz y uno por acción.
class AppDialog extends StatelessWidget {
  /// Crea un diálogo.
  const AppDialog({
    required this.id,
    required this.title,
    required this.confirmId,
    required this.confirmLabel,
    this.message,
    this.content,
    this.cancelId,
    this.cancelLabel,
    this.destructive = false,
    super.key,
  }) : assert(
         (cancelId == null) == (cancelLabel == null),
         'cancelId y cancelLabel van juntos',
       );

  /// Identificador semántico y `Key` de la raíz del diálogo.
  final String id;

  /// Título.
  final String title;

  /// Identificador de la acción de confirmar.
  final String confirmId;

  /// Texto de la acción de confirmar: la acción concreta.
  final String confirmLabel;

  /// Mensaje del cuerpo.
  final String? message;

  /// Cuerpo personalizado; tiene prioridad sobre [message].
  final Widget? content;

  /// Identificador de la acción de cancelar.
  final String? cancelId;

  /// Texto de la acción de cancelar.
  final String? cancelLabel;

  /// Marca la confirmación como destructiva (cerrar sesión).
  final bool destructive;

  /// Muestra el diálogo y devuelve `true` si el usuario confirmó.
  static Future<bool> show(
    BuildContext context, {
    required String id,
    required String title,
    required String confirmId,
    required String confirmLabel,
    String? message,
    Widget? content,
    String? cancelId,
    String? cancelLabel,
    bool destructive = false,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AppDialog(
        id: id,
        title: title,
        confirmId: confirmId,
        confirmLabel: confirmLabel,
        message: message,
        content: content,
        cancelId: cancelId,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final String? body = message;
    final String? cancel = cancelLabel;
    final String? cancelIdentifier = cancelId;
    return Identified(
      id: id,
      child: AlertDialog(
        title: Text(title),
        content: content ?? (body == null ? null : Text(body)),
        actions: <Widget>[
          if (cancel != null && cancelIdentifier != null)
            AppButton(
              id: cancelIdentifier,
              label: cancel,
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          AppButton(
            id: confirmId,
            label: confirmLabel,
            variant: destructive
                ? AppButtonVariant.sell
                : AppButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
