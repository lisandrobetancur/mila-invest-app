/// Tipo de documento de identidad aceptado en el registro.
enum DocumentType {
  /// Cédula de ciudadanía (Colombia).
  cc(code: 'CC'),

  /// Cédula de extranjería (Colombia) / carné de extranjería (Perú).
  ce(code: 'CE'),

  /// Clave Única de Registro de Población (México).
  curp(code: 'CURP'),

  /// Documento Nacional de Identidad (Perú).
  dni(code: 'DNI');

  const DocumentType({required this.code});

  /// Busca un tipo de documento por su código, o `null` si no existe.
  static DocumentType? tryFromCode(String code) {
    final String upper = code.toUpperCase();
    for (final DocumentType type in values) {
      if (type.code == upper) {
        return type;
      }
    }
    return null;
  }

  /// Código tal como lo usa la API (`CC`, `CE`, `CURP`, `DNI`).
  final String code;
}
