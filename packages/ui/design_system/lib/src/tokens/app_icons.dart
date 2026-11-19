import 'package:flutter/material.dart';

/// Íconos de la app: Material outlined, peso 400.
///
/// Las vistas nunca usan `Icons.*` sueltos: piden el ícono por su intención,
/// así cambiar la familia toca un solo archivo.
abstract final class AppIcons {
  /// Tab Inicio.
  static const IconData home = Icons.home_outlined;

  /// Tab Mercado.
  static const IconData market = Icons.show_chart_outlined;

  /// Tab Portafolio.
  static const IconData portfolio = Icons.pie_chart_outline;

  /// Tab Actividad.
  static const IconData activity = Icons.receipt_long_outlined;

  /// Billetera.
  static const IconData wallet = Icons.account_balance_wallet_outlined;

  /// Ajustes.
  static const IconData settings = Icons.settings_outlined;

  /// Volver.
  static const IconData back = Icons.arrow_back_outlined;

  /// Cerrar.
  static const IconData close = Icons.close_outlined;

  /// Buscar.
  static const IconData search = Icons.search_outlined;

  /// Limpiar un campo.
  static const IconData clear = Icons.cancel_outlined;

  /// Sumar una unidad.
  static const IconData add = Icons.add_outlined;

  /// Restar una unidad.
  static const IconData remove = Icons.remove_outlined;

  /// Reintentar.
  static const IconData refresh = Icons.refresh_outlined;

  /// Avanzar a un detalle.
  static const IconData chevronRight = Icons.chevron_right_outlined;

  /// Mostrar contraseña.
  static const IconData visibility = Icons.visibility_outlined;

  /// Ocultar contraseña.
  static const IconData visibilityOff = Icons.visibility_off_outlined;

  /// Requisito cumplido.
  static const IconData check = Icons.check_circle_outline;

  /// Requisito pendiente.
  static const IconData pending = Icons.radio_button_unchecked_outlined;

  /// Error.
  static const IconData error = Icons.error_outline;

  /// Aviso.
  static const IconData warning = Icons.warning_amber_outlined;

  /// Información.
  static const IconData info = Icons.info_outline;

  /// Sin conexión.
  static const IconData offline = Icons.cloud_off_outlined;

  /// Depositar.
  static const IconData deposit = Icons.south_west_outlined;

  /// Compra.
  static const IconData buy = Icons.add_shopping_cart_outlined;

  /// Venta.
  static const IconData sell = Icons.sell_outlined;

  /// Comisión.
  static const IconData fee = Icons.percent_outlined;

  /// Cerrar sesión.
  static const IconData logout = Icons.logout_outlined;

  /// Idioma.
  static const IconData language = Icons.translate_outlined;

  /// Tema.
  static const IconData theme = Icons.brightness_6_outlined;

  /// Cuenta del usuario.
  static const IconData account = Icons.person_outline;

  /// Estado vacío de búsqueda.
  static const IconData emptySearch = Icons.search_off_outlined;

  /// Estado vacío de lista.
  static const IconData emptyList = Icons.inbox_outlined;

  /// Estado vacío de portafolio.
  static const IconData emptyPortfolio = Icons.donut_large_outlined;

  /// No encontrado.
  static const IconData notFound = Icons.travel_explore_outlined;

  /// Simulación / educación.
  static const IconData simulated = Icons.school_outlined;

  /// Reloj de mercado.
  static const IconData schedule = Icons.schedule_outlined;

  /// Éxito de una operación.
  static const IconData success = Icons.task_alt_outlined;

  /// Calendario, para rangos de fechas.
  static const IconData calendar = Icons.calendar_today_outlined;
}
