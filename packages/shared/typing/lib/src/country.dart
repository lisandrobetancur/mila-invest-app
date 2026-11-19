import 'currency.dart';
import 'document_type.dart';

/// País en el que se registra un usuario.
enum Country {
  /// Colombia.
  co(
    code: 'CO',
    currency: Currency.cop,
    locale: 'es_CO',
    timeZoneName: 'America/Bogota',
    utcOffsetHours: -5,
    documentTypes: <DocumentType>[DocumentType.cc, DocumentType.ce],
  ),

  /// México.
  mx(
    code: 'MX',
    currency: Currency.mxn,
    locale: 'es_MX',
    timeZoneName: 'America/Mexico_City',
    utcOffsetHours: -6,
    documentTypes: <DocumentType>[DocumentType.curp],
  ),

  /// Perú.
  pe(
    code: 'PE',
    currency: Currency.pen,
    locale: 'es_PE',
    timeZoneName: 'America/Lima',
    utcOffsetHours: -5,
    documentTypes: <DocumentType>[DocumentType.dni, DocumentType.ce],
  );

  const Country({
    required this.code,
    required this.currency,
    required this.locale,
    required this.timeZoneName,
    required this.utcOffsetHours,
    required this.documentTypes,
  });

  /// Busca un país por su código ISO, o `null` si no existe.
  static Country? tryFromCode(String code) {
    final String upper = code.toUpperCase();
    for (final Country country in values) {
      if (country.code == upper) {
        return country;
      }
    }
    return null;
  }

  /// Código ISO 3166-1 alfa-2.
  final String code;

  /// Moneda base del país.
  final Currency currency;

  /// Locale de `intl` para fechas y números de este país.
  final String locale;

  /// Nombre IANA de la zona horaria.
  final String timeZoneName;

  /// Desplazamiento fijo respecto a UTC. Ninguno de los tres países usa
  /// horario de verano, así que un offset fijo es exacto.
  final int utcOffsetHours;

  /// Tipos de documento aceptados en el registro, en orden de presentación.
  final List<DocumentType> documentTypes;

  /// Desplazamiento respecto a UTC como [Duration].
  Duration get utcOffset => Duration(hours: utcOffsetHours);
}
