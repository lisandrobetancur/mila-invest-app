/// Datos con los que arranca el backend falso (`FAKE_SEED`).
enum FakeSeed {
  /// Usuario demo con saldo, posiciones, órdenes y movimientos.
  demo,

  /// Usuario demo sin saldo ni posiciones: todas las vistas quedan vacías.
  empty;

  /// Resuelve el valor del flag `FAKE_SEED`; uno desconocido es [demo].
  static FakeSeed fromName(String name) =>
      name.toLowerCase() == 'empty' ? FakeSeed.empty : FakeSeed.demo;
}

/// Credenciales de la cuenta demo del backend falso.
abstract final class FakeDemoAccount {
  /// Email de la cuenta demo.
  static const String email = 'demo@milainvest.app';

  /// Contraseña de la cuenta demo. Es un valor de prueba público: el
  /// backend falso vive en memoria y no protege nada real.
  static const String password = 'Demo1234!';

  /// Nombre de la cuenta demo.
  static const String fullName = 'Camila Demo';

  /// Documento (CC) de la cuenta demo.
  static const String documentNumber = '1012345678';
}
