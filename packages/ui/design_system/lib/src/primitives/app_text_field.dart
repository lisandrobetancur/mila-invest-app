import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'identified.dart';

/// Campo de texto de la app.
///
/// El identificador queda en el nodo que tiene `isTextField`. El mensaje de
/// error, si hay, lleva su propio identificador: [errorIdOf].
class AppTextField extends StatelessWidget {
  /// Crea un campo de texto.
  const AppTextField({
    required this.id,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    super.key,
  });

  /// Variante numérica: teclado decimal y solo dígitos y separador.
  ///
  /// Con [allowDecimal] en `false` acepta solo enteros (cantidades).
  AppTextField.numeric({
    required this.id,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    bool allowDecimal = true,
    super.key,
  }) : obscureText = false,
       textCapitalization = TextCapitalization.none,
       autofillHints = null,
       keyboardType = TextInputType.numberWithOptions(decimal: allowDecimal),
       inputFormatters = <TextInputFormatter>[
         FilteringTextInputFormatter.allow(
           RegExp(allowDecimal ? r'[0-9.,]' : r'[0-9]'),
         ),
       ];

  /// Identificador semántico y `Key` del campo.
  final String id;

  /// Etiqueta visible del campo.
  final String label;

  /// Controlador del texto.
  final TextEditingController? controller;

  /// Texto de ejemplo.
  final String? hint;

  /// Ayuda debajo del campo.
  final String? helper;

  /// Mensaje de error ya traducido; `null` si el campo es válido.
  final String? errorText;

  /// Widget antes del texto (un ícono o el símbolo de moneda).
  final Widget? prefix;

  /// Widget después del texto (mostrar/ocultar, limpiar).
  final Widget? suffix;

  /// Oculta el texto (contraseñas).
  final bool obscureText;

  /// Habilita o deshabilita la edición.
  final bool enabled;

  /// Toma el foco al aparecer.
  final bool autofocus;

  /// Tipo de teclado.
  final TextInputType? keyboardType;

  /// Acción del teclado.
  final TextInputAction? textInputAction;

  /// Capitalización automática.
  final TextCapitalization textCapitalization;

  /// Filtros de entrada.
  final List<TextInputFormatter>? inputFormatters;

  /// Pistas de autocompletado.
  final Iterable<String>? autofillHints;

  /// Largo máximo.
  final int? maxLength;

  /// Aviso de cambio de texto.
  final ValueChanged<String>? onChanged;

  /// Aviso de envío desde el teclado.
  final ValueChanged<String>? onSubmitted;

  /// Nodo de foco.
  final FocusNode? focusNode;

  /// Identificador del mensaje de error del campo [fieldId] (§11.1).
  static String errorIdOf(String fieldId) => '${fieldId}_error_text';

  @override
  Widget build(BuildContext context) {
    final String? error = errorText;
    return Identified.field(
      id: id,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        enabled: enabled,
        autofocus: autofocus,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        autofillHints: autofillHints,
        maxLength: maxLength,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helper,
          counterText: '',
          prefixIcon: prefix,
          suffixIcon: suffix,
          error: error == null
              ? null
              : Identified(
                  id: errorIdOf(id),
                  liveRegion: true,
                  child: Text(
                    error,
                    style: Theme.of(context).inputDecorationTheme.errorStyle,
                  ),
                ),
        ),
      ),
    );
  }
}
