import 'package:typing/typing.dart';

/// Validación de formato del lado del cliente (§7.2).
///
/// El backend es la fuente de verdad: puede rechazar con `VALIDATION_ERROR`
/// algo que aquí pasó. Estas funciones devuelven `bool` y cada feature elige
/// la clave de traducción del mensaje.
abstract final class Validators {
  /// Largo máximo de un nombre completo.
  static const int nameMaxLength = 80;

  /// Largo mínimo de un nombre completo.
  static const int nameMinLength = 3;

  /// Largo mínimo de una contraseña.
  static const int passwordMinLength = 8;

  static final RegExp _alphanumeric = RegExp(r'^[A-Za-z0-9]+$');
  static final RegExp _curp = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$');
  static final RegExp _digits = RegExp(r'^\d+$');
  static final RegExp _email = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
  );
  static final RegExp _letter = RegExp('[A-Za-zÀ-ÿ]');

  /// `true` si [raw] es un email con formato válido y sin espacios.
  static bool isEmail(String raw) {
    final String value = raw.trim();
    return value.isNotEmpty &&
        !value.contains(' ') &&
        _email.hasMatch(value) &&
        value == raw.trim();
  }

  /// `true` si el nombre completo tiene entre 3 y 80 caracteres.
  static bool isFullName(String raw) {
    final int length = raw.trim().length;
    return length >= nameMinLength && length <= nameMaxLength;
  }

  /// `true` si la contraseña cumple los tres requisitos.
  static bool isPassword(String raw) =>
      passwordHasMinLength(raw) &&
      passwordHasLetter(raw) &&
      passwordHasNumber(raw);

  /// Normaliza un número de documento: sin espacios y, en CURP, en
  /// mayúsculas.
  static String normalizeDocument(DocumentType type, String raw) {
    final String value = raw.trim().replaceAll(' ', '');
    return type == DocumentType.curp ? value.toUpperCase() : value;
  }

  /// Normaliza un email: sin espacios alrededor y en minúsculas.
  static String normalizeEmail(String raw) => raw.trim().toLowerCase();

  /// `true` si la contraseña tiene al menos una letra.
  static bool passwordHasLetter(String raw) => _letter.hasMatch(raw);

  /// `true` si la contraseña llega al largo mínimo.
  static bool passwordHasMinLength(String raw) =>
      raw.length >= passwordMinLength;

  /// `true` si la contraseña tiene al menos un número.
  static bool passwordHasNumber(String raw) => RegExp(r'\d').hasMatch(raw);

  /// `true` si [raw] es un documento válido para [type] en [country].
  ///
  /// `CE` significa cédula de extranjería en Colombia y carné de
  /// extranjería en Perú, con largos distintos, así que hace falta el país.
  static bool isDocumentNumber({
    required Country country,
    required DocumentType type,
    required String raw,
  }) {
    final String value = normalizeDocument(type, raw);
    if (!country.documentTypes.contains(type)) {
      return false;
    }
    return switch (type) {
      DocumentType.cc => _digits.hasMatch(value) && _inRange(value, 6, 10),
      DocumentType.curp => _curp.hasMatch(value),
      DocumentType.dni => _digits.hasMatch(value) && value.length == 8,
      DocumentType.ce =>
        _alphanumeric.hasMatch(value) &&
            (country == Country.co
                ? _inRange(value, 6, 12)
                : _inRange(value, 9, 12)),
    };
  }

  static bool _inRange(String value, int min, int max) =>
      value.length >= min && value.length <= max;
}
