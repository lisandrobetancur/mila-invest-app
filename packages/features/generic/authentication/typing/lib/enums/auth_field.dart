/// Campos de los formularios de login y registro.
enum AuthField {
  /// Email.
  email('email'),

  /// Contraseña.
  password('password'),

  /// Nombre completo.
  fullName('full_name'),

  /// País.
  country('country'),

  /// Tipo de documento.
  documentType('document_type'),

  /// Número de documento.
  documentNumber('document_number');

  const AuthField(this.apiName);

  /// Busca un campo por el nombre con el que lo nombra la API.
  static AuthField? tryFromApiName(String name) {
    for (final AuthField field in values) {
      if (field.apiName == name) {
        return field;
      }
    }
    return null;
  }

  /// Nombre del campo en la API, en `snake_case`.
  final String apiName;
}
