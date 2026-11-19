/// Estado de una orden.
enum OrderStatus {
  /// Recibida, sin ejecutar.
  pending('PENDING'),

  /// Ejecutada.
  filled('FILLED'),

  /// Rechazada.
  rejected('REJECTED'),

  /// Cancelada.
  cancelled('CANCELLED');

  const OrderStatus(this.apiCode);

  /// Busca un estado por su código de API, o `null` si no existe.
  static OrderStatus? tryFromApiCode(String code) {
    for (final OrderStatus status in values) {
      if (status.apiCode == code) {
        return status;
      }
    }
    return null;
  }

  /// Código en la API.
  final String apiCode;
}
