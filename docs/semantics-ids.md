# Inventario de identificadores semánticos

Contrato público para automatización black-box (§11.1). Se actualiza en el
**mismo PR** que agrega o cambia un id. Renombrar un id existente rompe el
contrato y se anota en la sección *Cambios de contrato*.

Este archivo se genera con `python3 scripts/semantics_inventory.py` a partir
de los `*_ids.dart`; la nota de cada id es su comentario de documentación.

Fuente única: `<feature>_constants/lib/<feature>_ids.dart` y, en el shell,
`shell_ids.dart`. La `Key` de un widget es `ValueKey<String>(<id>)` con el
mismo string.

| Plataforma | Atributo expuesto |
|---|---|
| Android | `resource-id` |
| iOS | `accessibilityIdentifier` |
| Web | `flt-semantics-identifier` (requiere `--dart-define=ENABLE_SEMANTICS=true`) |

Convención: la parte estática cumple `^[a-z][a-z0-9]*(_[a-z0-9]+)*$`; la parte
dinámica es el id de la entidad tal como lo da la API
(`market_list_instrument_item_ECOPETROL-CO`), nunca un índice ni texto traducido.

Ids que entregan los componentes a partir del id de su raíz:

| Componente | Id derivado |
|---|---|
| `AppTextField` | `<id del campo>_error_text` (mensaje de error del campo) |
| `InstrumentTile` | `<id del ítem>_price_text`, `_change_text`, `_country_text` |

## Shell

Fuente: `packages/apps/mila_invest_app/lib/shell_ids.dart`

### `nav_shell`

| Id | Tipo | Nota |
|---|---|---|
| `nav_shell_view` | raíz de vista | Raíz del shell de navegación. |

### `nav_home`

| Id | Tipo | Nota |
|---|---|---|
| `nav_home_tab` | tab | Tab Inicio. |

### `nav_market`

| Id | Tipo | Nota |
|---|---|---|
| `nav_market_tab` | tab | Tab Mercado. |

### `nav_portfolio`

| Id | Tipo | Nota |
|---|---|---|
| `nav_portfolio_tab` | tab | Tab Portafolio. |

### `nav_activity`

| Id | Tipo | Nota |
|---|---|---|
| `nav_activity_tab` | tab | Tab Actividad. |

### `shell_not`

| Id | Tipo | Nota |
|---|---|---|
| `shell_not_found_view` | raíz de vista | Raíz de "no encontrado". |
| `shell_not_found_title_text` | valor / texto | Título de "no encontrado". |
| `shell_not_found_home_button` | botón | "Ir al inicio" desde "no encontrado". |

## app_cross

Fuente: `packages/features/generic/app_cross/constants/lib/app_cross_ids.dart`

### `splash`

| Id | Tipo | Nota |
|---|---|---|
| `splash_view` | raíz de vista | Raíz del splash. |

### `splash_state`

| Id | Tipo | Nota |
|---|---|---|
| `splash_state_loading` | raíz de estado | Splash arrancando. |
| `splash_state_error` | raíz de estado | Splash con error de arranque. |

### `splash_error`

| Id | Tipo | Nota |
|---|---|---|
| `splash_error_text` | valor / texto | Mensaje de error del splash. |

### `splash_retry`

| Id | Tipo | Nota |
|---|---|---|
| `splash_retry_button` | botón | "Reintentar" del splash. |

### `onboarding`

| Id | Tipo | Nota |
|---|---|---|
| `onboarding_view` | raíz de vista | Raíz del onboarding. |

### `onboarding_step`

| Id | Tipo | Nota |
|---|---|---|
| `onboarding_step_title_text` | valor / texto | Título del paso visible. |
| `onboarding_step_body_text` | valor / texto | Texto del paso visible. |

### `onboarding_progress`

| Id | Tipo | Nota |
|---|---|---|
| `onboarding_progress_text` | valor / texto | Indicador "Paso 2 de 3". |

### `onboarding_disclaimer`

| Id | Tipo | Nota |
|---|---|---|
| `onboarding_disclaimer_text` | valor / texto | Aviso de simulación del onboarding. |

### `onboarding_skip`

| Id | Tipo | Nota |
|---|---|---|
| `onboarding_skip_button` | botón | Botón "Saltar". |

### `onboarding_next`

| Id | Tipo | Nota |
|---|---|---|
| `onboarding_next_button` | botón | Botón "Siguiente". |

### `onboarding_start`

| Id | Tipo | Nota |
|---|---|---|
| `onboarding_start_button` | botón | Botón "Empezar" del último paso. |

### `settings`

| Id | Tipo | Nota |
|---|---|---|
| `settings_view` | raíz de vista | Raíz de ajustes. |

### `settings_back`

| Id | Tipo | Nota |
|---|---|---|
| `settings_back_icon_button` | botón de ícono | Volver desde ajustes. |

### `settings_simulated`

| Id | Tipo | Nota |
|---|---|---|
| `settings_simulated_text` | valor / texto | Badge "Simulado" de ajustes. |

### `settings_theme`

| Id | Tipo | Nota |
|---|---|---|
| `settings_theme_menu` | selector | Selector de tema. |
| `settings_theme_system_segment` | segmento | Tema del sistema. |
| `settings_theme_light_segment` | segmento | Tema claro. |
| `settings_theme_dark_segment` | segmento | Tema oscuro. |

### `settings_language`

| Id | Tipo | Nota |
|---|---|---|
| `settings_language_menu` | selector | Selector de idioma. |
| `settings_language_es_segment` | segmento | Idioma español. |
| `settings_language_en_segment` | segmento | Idioma inglés. |

### `settings_account`

| Id | Tipo | Nota |
|---|---|---|
| `settings_account_name_text` | valor / texto | Nombre del titular de la cuenta. |
| `settings_account_email_text` | valor / texto | Email de la cuenta. |
| `settings_account_country_text` | valor / texto | País de la cuenta. |
| `settings_account_document_text` | valor / texto | Documento enmascarado. |

### `settings_logout`

| Id | Tipo | Nota |
|---|---|---|
| `settings_logout_button` | botón | Botón "Cerrar sesión". |
| `settings_logout_dialog` | diálogo | Diálogo de confirmación de cierre de sesión. |
| `settings_logout_confirm_button` | botón | Confirmar el cierre de sesión. |
| `settings_logout_cancel_button` | botón | Cancelar el cierre de sesión. |

### `settings_version`

| Id | Tipo | Nota |
|---|---|---|
| `settings_version_text` | valor / texto | Versión de la app. |

### `settings_api`

| Id | Tipo | Nota |
|---|---|---|
| `settings_api_mode_text` | valor / texto | Modo de API activo (solo fuera de release). |

### `settings_disclaimer`

| Id | Tipo | Nota |
|---|---|---|
| `settings_disclaimer_text` | valor / texto | Aviso de simulación de ajustes. |

## authentication

Fuente: `packages/features/generic/authentication/constants/lib/authentication_ids.dart`

### `auth_login`

| Id | Tipo | Nota |
|---|---|---|
| `auth_login_view` | raíz de vista | Raíz de la vista de login. |
| `auth_login_simulated_text` | valor / texto | Badge "Simulado" del login. |
| `auth_login_email_field` | campo | Campo de email del login. |
| `auth_login_password_field` | campo | Campo de contraseña del login. |
| `auth_login_password_toggle` | interruptor | Mostrar/ocultar la contraseña del login. |
| `auth_login_submit_button` | botón | Botón "Iniciar sesión". |
| `auth_login_demo_button` | botón | Botón "Usar cuenta demo" (solo en modo fake). |
| `auth_login_register_link` | link | Link "Crear cuenta". |
| `auth_login_error_text` | valor / texto | Mensaje de error general del login. |
| `auth_login_disclaimer_text` | valor / texto | Aviso de simulación del login. |

### `auth_register`

| Id | Tipo | Nota |
|---|---|---|
| `auth_register_view` | raíz de vista | Raíz de la vista de registro. |
| `auth_register_back_icon_button` | botón de ícono | Volver desde el registro. |
| `auth_register_simulated_text` | valor / texto | Badge "Simulado" del registro. |
| `auth_register_country_co_chip` | chip | Chip de país Colombia. |
| `auth_register_country_mx_chip` | chip | Chip de país México. |
| `auth_register_country_pe_chip` | chip | Chip de país Perú. |
| `auth_register_country_error_text` | valor / texto | Mensaje de error del país (ninguno elegido). |
| `auth_register_name_field` | campo | Campo de nombre completo. |
| `auth_register_email_field` | campo | Campo de email del registro. |
| `auth_register_document_cc_chip` | chip | Chip de tipo de documento CC. |
| `auth_register_document_ce_chip` | chip | Chip de tipo de documento CE. |
| `auth_register_document_curp_chip` | chip | Chip de tipo de documento CURP. |
| `auth_register_document_dni_chip` | chip | Chip de tipo de documento DNI. |
| `auth_register_document_field` | campo | Campo de número de documento. |
| `auth_register_password_field` | campo | Campo de contraseña del registro. |
| `auth_register_password_toggle` | interruptor | Mostrar/ocultar la contraseña del registro. |
| `auth_register_requirement_length_text` | valor / texto | Requisito de contraseña: largo mínimo. |
| `auth_register_requirement_letter_text` | valor / texto | Requisito de contraseña: al menos una letra. |
| `auth_register_requirement_number_text` | valor / texto | Requisito de contraseña: al menos un número. |
| `auth_register_disclaimer_text` | valor / texto | Aviso de simulación del registro. |
| `auth_register_accept_checkbox` | checkbox | Checkbox de aceptación del aviso de simulación. |
| `auth_register_accept_checkbox_error_text` | valor / texto | Mensaje de error del checkbox de aceptación. |
| `auth_register_submit_button` | botón | Botón "Crear cuenta". |
| `auth_register_login_link` | link | Link "Ya tengo cuenta". |
| `auth_register_error_text` | valor / texto | Mensaje de error general del registro. |

## dashboard

Fuente: `packages/features/core/dashboard/constants/lib/dashboard_ids.dart`

### `dashboard_home`

| Id | Tipo | Nota |
|---|---|---|
| `dashboard_home_view` | raíz de vista | Raíz del inicio. |
| `dashboard_home_state_loading` | raíz de estado | Inicio cargando. |
| `dashboard_home_state_data` | raíz de estado | Inicio con datos. |
| `dashboard_home_state_empty` | raíz de estado | Usuario nuevo: sin saldo ni inversiones. |
| `dashboard_home_state_error` | raíz de estado | Inicio con error. |
| `dashboard_home_greeting_text` | valor / texto | Saludo. |
| `dashboard_home_simulated_text` | valor / texto | Badge "Simulado". |
| `dashboard_home_wallet_icon_button` | botón de ícono | Abrir la billetera. |
| `dashboard_home_settings_icon_button` | botón de ícono | Abrir ajustes. |
| `dashboard_home_total_tile` | tarjeta | Tarjeta del valor total. |
| `dashboard_home_total_text` | valor / texto | Valor total. |
| `dashboard_home_day_change_text` | valor / texto | Variación del día. |
| `dashboard_home_allocation_chart` | gráfico | Distribución compacta. |
| `dashboard_home_gainers_title_text` | valor / texto | Título de los que más suben. |
| `dashboard_home_losers_title_text` | valor / texto | Título de los que más bajan. |
| `dashboard_home_recent_title_text` | valor / texto | Título de las últimas transacciones. |
| `dashboard_home_recent_all_button` | botón | "Ver todo" de las últimas transacciones. |
| `dashboard_home_empty_title_text` | valor / texto | Título de la tarjeta "Haz tu primer depósito". |
| `dashboard_home_empty_deposit_button` | botón | "Depositar" del usuario nuevo. |
| `dashboard_home_error_text` | valor / texto | Mensaje de error. |
| `dashboard_home_retry_button` | botón | "Reintentar". |

### `dashboard_mover`

| Id | Tipo | Nota |
|---|---|---|
| `dashboard_mover_item_<instrumentId>` | ítem / parte de ítem | Instrumento [instrumentId] entre los que más suben o bajan. |

### `dashboard_recent`

| Id | Tipo | Nota |
|---|---|---|
| `dashboard_recent_item_<transactionId>` | ítem / parte de ítem | Transacción reciente [transactionId]. |

### `<…>_amount`

| Id | Tipo | Nota |
|---|---|---|
| `<…>_amount_text` | valor / texto | Monto de una transacción reciente. |

### `dashboard_allocation`

| Id | Tipo | Nota |
|---|---|---|
| `dashboard_allocation_item_<type>` | ítem / parte de ítem | Porción de la distribución de tipo [type]. |

## market

Fuente: `packages/features/core/market/constants/lib/market_ids.dart`

### `market_list`

| Id | Tipo | Nota |
|---|---|---|
| `market_list_view` | raíz de vista | Raíz de la lista. |
| `market_list_state_loading` | raíz de estado | Lista cargando. |
| `market_list_state_data` | raíz de estado | Lista con datos. |
| `market_list_state_empty` | raíz de estado | Lista sin resultados. |
| `market_list_state_error` | raíz de estado | Lista con error. |
| `market_list_simulated_text` | valor / texto | Badge "Simulado" de la lista. |
| `market_list_search_field` | campo | Buscador. |
| `market_list_search_clear_icon_button` | botón de ícono | Limpiar el buscador. |
| `market_list_country_all_chip` | chip | Chip de país: todos. |
| `market_list_country_co_chip` | chip | Chip de país: Colombia. |
| `market_list_country_mx_chip` | chip | Chip de país: México. |
| `market_list_country_pe_chip` | chip | Chip de país: Perú. |
| `market_list_type_stock_chip` | chip | Chip de tipo: acciones. |
| `market_list_type_etf_chip` | chip | Chip de tipo: ETFs. |
| `market_list_status_co_text` | valor / texto | Estado del mercado de Colombia. |
| `market_list_status_mx_text` | valor / texto | Estado del mercado de México. |
| `market_list_status_pe_text` | valor / texto | Estado del mercado de Perú. |
| `market_list_loading_more_text` | valor / texto | Indicador de la página siguiente cargando. |
| `market_list_load_more_error_text` | valor / texto | Error al cargar la página siguiente. |
| `market_list_load_more_retry_button` | botón | Reintentar la página siguiente. |
| `market_list_empty_title_text` | valor / texto | Título del estado vacío. |
| `market_list_clear_filters_button` | botón | "Limpiar filtros". |
| `market_list_error_text` | valor / texto | Mensaje de error de la lista. |
| `market_list_retry_button` | botón | "Reintentar" de la lista. |

### `market_detail`

| Id | Tipo | Nota |
|---|---|---|
| `market_detail_view` | raíz de vista | Raíz del detalle. |
| `market_detail_state_loading` | raíz de estado | Detalle cargando. |
| `market_detail_state_data` | raíz de estado | Detalle con datos. |
| `market_detail_state_empty` | raíz de estado | Instrumento no encontrado. |
| `market_detail_state_error` | raíz de estado | Detalle con error. |
| `market_detail_back_icon_button` | botón de ícono | Volver desde el detalle. |
| `market_detail_simulated_text` | valor / texto | Badge "Simulado" del detalle. |
| `market_detail_ticker_text` | valor / texto | Ticker. |
| `market_detail_name_text` | valor / texto | Nombre del emisor. |
| `market_detail_country_text` | valor / texto | País del instrumento. |
| `market_detail_price_text` | valor / texto | Último precio. |
| `market_detail_change_text` | valor / texto | Variación del día. |
| `market_detail_status_text` | valor / texto | Estado del mercado del instrumento. |
| `market_detail_chart` | gráfico | Raíz del gráfico de precios. |
| `market_detail_chart_error_text` | valor / texto | Error del gráfico. |
| `market_detail_range_menu` | selector | Selector de rango del gráfico. |
| `market_detail_range_1d_segment` | segmento | Rango 1D. |
| `market_detail_range_1w_segment` | segmento | Rango 1S. |
| `market_detail_range_1m_segment` | segmento | Rango 1M. |
| `market_detail_range_3m_segment` | segmento | Rango 3M. |
| `market_detail_range_1y_segment` | segmento | Rango 1A. |
| `market_detail_open_text` | valor / texto | Apertura. |
| `market_detail_high_text` | valor / texto | Máximo del día. |
| `market_detail_low_text` | valor / texto | Mínimo del día. |
| `market_detail_prev_close_text` | valor / texto | Cierre anterior. |
| `market_detail_volume_text` | valor / texto | Volumen. |
| `market_detail_description_text` | valor / texto | Descripción del emisor. |
| `market_detail_position_quantity_text` | valor / texto | Cantidad en posición. |
| `market_detail_position_value_text` | valor / texto | Valor de mercado de la posición. |
| `market_detail_position_pnl_text` | valor / texto | P&L no realizado de la posición. |
| `market_detail_buy_button` | botón | Botón "Comprar". |
| `market_detail_sell_button` | botón | Botón "Vender". |
| `market_detail_closed_reason_text` | valor / texto | Motivo por el que no se puede operar (mercado cerrado). |
| `market_detail_not_found_title_text` | valor / texto | Título del estado "no encontrado". |
| `market_detail_back_to_market_button` | botón | Volver al mercado desde "no encontrado". |
| `market_detail_error_text` | valor / texto | Mensaje de error del detalle. |
| `market_detail_retry_button` | botón | "Reintentar" del detalle. |

### `market_list`

| Id | Tipo | Nota |
|---|---|---|
| `market_list_instrument_item_<instrumentId>` | ítem / parte de ítem | Ítem de la lista para el instrumento [instrumentId]. |

## orders

Fuente: `packages/features/core/orders/constants/lib/orders_ids.dart`

### `orders_ticket`

| Id | Tipo | Nota |
|---|---|---|
| `orders_ticket_view` | raíz de vista | Raíz del ticket. |
| `orders_ticket_state_loading` | raíz de estado | Ticket cargando el instrumento. |
| `orders_ticket_state_data` | raíz de estado | Ticket listo para editar. |
| `orders_ticket_state_empty` | raíz de estado | Instrumento no encontrado. |
| `orders_ticket_state_error` | raíz de estado | Ticket con error de carga. |
| `orders_ticket_close_icon_button` | botón de ícono | Cerrar el ticket. |
| `orders_ticket_simulated_text` | valor / texto | Badge "Simulado" del ticket. |
| `orders_ticket_instrument_text` | valor / texto | Ticker y nombre del instrumento. |
| `orders_ticket_price_text` | valor / texto | Último precio del instrumento. |
| `orders_ticket_side_menu` | selector | Selector de lado. |
| `orders_ticket_side_buy_segment` | segmento | Lado comprar. |
| `orders_ticket_side_sell_segment` | segmento | Lado vender. |
| `orders_ticket_quantity_field` | campo | Campo de cantidad. |
| `orders_ticket_quantity_decrease_stepper` | stepper | Restar una unidad. |
| `orders_ticket_quantity_increase_stepper` | stepper | Sumar una unidad. |
| `orders_ticket_available_text` | valor / texto | Saldo disponible en la moneda del instrumento. |
| `orders_ticket_position_text` | valor / texto | Cantidad en posición. |
| `orders_ticket_preview_loading_text` | valor / texto | Preview calculándose. |
| `orders_ticket_preview_error_text` | valor / texto | Error del preview. |
| `orders_ticket_low_balance_text` | valor / texto | Aviso de saldo bajo después de la orden. |
| `orders_ticket_deposit_button` | botón | "Depositar", cuando no alcanza el saldo. |
| `orders_ticket_closed_reason_text` | valor / texto | Motivo por el que no se puede operar (mercado cerrado). |
| `orders_ticket_review_button` | botón | "Revisar orden". |
| `orders_ticket_not_found_title_text` | valor / texto | Título del estado "no encontrado". |
| `orders_ticket_not_found_close_button` | botón | "Cerrar" desde "no encontrado". |
| `orders_ticket_error_text` | valor / texto | Mensaje de error de carga. |
| `orders_ticket_retry_button` | botón | "Reintentar" la carga. |

### `orders_summary`

| Id | Tipo | Nota |
|---|---|---|
| `orders_summary_panel` | panel | Raíz del resumen de la orden. |
| `orders_summary_price_text` | valor / texto | Precio estimado o de ejecución. |
| `orders_summary_gross_text` | valor / texto | Monto bruto. |
| `orders_summary_commission_text` | valor / texto | Comisión. |
| `orders_summary_total_text` | valor / texto | Total. |
| `orders_summary_available_after_text` | valor / texto | Saldo resultante. |

### `orders_confirm`

| Id | Tipo | Nota |
|---|---|---|
| `orders_confirm_view` | raíz de vista | Raíz de la confirmación. |
| `orders_confirm_back_icon_button` | botón de ícono | Volver de la confirmación al ticket. |
| `orders_confirm_order_text` | valor / texto | Lado y cantidad que se confirman. |
| `orders_confirm_disclaimer_text` | valor / texto | Aviso de simulación de la confirmación. |
| `orders_confirm_submit_button` | botón | "Confirmar compra" / "Confirmar venta". |
| `orders_confirm_error_text` | valor / texto | Error al enviar la orden. |

### `orders_result`

| Id | Tipo | Nota |
|---|---|---|
| `orders_result_view` | raíz de vista | Raíz del resultado. |
| `orders_result_status_text` | valor / texto | Estado de la orden (ejecutada, rechazada, pendiente, cancelada). |
| `orders_result_price_difference_text` | valor / texto | Diferencia entre el precio estimado y el de ejecución. |
| `orders_result_reject_reason_text` | valor / texto | Motivo del rechazo. |
| `orders_result_portfolio_button` | botón | "Ver portafolio". |
| `orders_result_suggested_action_button` | botón | Acción sugerida tras un rechazo (por ejemplo, "Depositar"). |
| `orders_result_done_button` | botón | "Listo": cierra el ticket. |

### `orders_history`

| Id | Tipo | Nota |
|---|---|---|
| `orders_history_view` | raíz de vista | Raíz del historial. |
| `orders_history_state_loading` | raíz de estado | Historial cargando. |
| `orders_history_state_data` | raíz de estado | Historial con órdenes. |
| `orders_history_state_empty` | raíz de estado | Historial vacío. |
| `orders_history_state_error` | raíz de estado | Historial con error. |
| `orders_history_section_menu` | selector | Selector de sección de la tab Actividad. |
| `orders_history_movements_tab` | tab | Sección "Movimientos" del selector de Actividad. |
| `orders_history_orders_tab` | tab | Sección "Órdenes" del selector de Actividad. |
| `orders_history_status_all_chip` | chip | Filtro: todas. |
| `orders_history_status_pending_chip` | chip | Filtro: pendientes. |
| `orders_history_status_filled_chip` | chip | Filtro: ejecutadas. |
| `orders_history_status_rejected_chip` | chip | Filtro: rechazadas. |
| `orders_history_status_cancelled_chip` | chip | Filtro: canceladas. |
| `orders_history_loading_more_text` | valor / texto | Página siguiente cargando. |
| `orders_history_load_more_error_text` | valor / texto | Error al cargar la página siguiente. |
| `orders_history_load_more_retry_button` | botón | Reintentar la página siguiente. |
| `orders_history_empty_title_text` | valor / texto | Título del estado vacío. |
| `orders_history_explore_button` | botón | "Explorar mercado" del estado vacío. |
| `orders_history_error_text` | valor / texto | Mensaje de error. |
| `orders_history_retry_button` | botón | "Reintentar". |

### `orders_detail`

| Id | Tipo | Nota |
|---|---|---|
| `orders_detail_view` | raíz de vista | Raíz del detalle de orden. |
| `orders_detail_state_loading` | raíz de estado | Detalle cargando. |
| `orders_detail_state_data` | raíz de estado | Detalle con datos. |
| `orders_detail_state_empty` | raíz de estado | Orden no encontrada. |
| `orders_detail_state_error` | raíz de estado | Detalle con error. |
| `orders_detail_back_icon_button` | botón de ícono | Volver desde el detalle. |
| `orders_detail_status_text` | valor / texto | Estado de la orden. |
| `orders_detail_instrument_text` | valor / texto | Instrumento de la orden. |
| `orders_detail_side_text` | valor / texto | Lado de la orden. |
| `orders_detail_quantity_text` | valor / texto | Cantidad de la orden. |
| `orders_detail_created_text` | valor / texto | Fecha de creación. |
| `orders_detail_filled_text` | valor / texto | Fecha de ejecución. |
| `orders_detail_reject_reason_text` | valor / texto | Motivo del rechazo. |
| `orders_detail_instrument_button` | botón | Ver el instrumento de la orden. |
| `orders_detail_not_found_title_text` | valor / texto | Título del estado "no encontrada". |
| `orders_detail_back_to_history_button` | botón | Volver al historial desde "no encontrada". |
| `orders_detail_error_text` | valor / texto | Mensaje de error del detalle. |
| `orders_detail_retry_button` | botón | "Reintentar" del detalle. |

### `orders_history`

| Id | Tipo | Nota |
|---|---|---|
| `orders_history_item_<orderId>` | ítem / parte de ítem | Ítem del historial para la orden [orderId]. |

### `<…>_status`

| Id | Tipo | Nota |
|---|---|---|
| `<…>_status_text` | valor / texto | Estado de un ítem del historial. |

### `<…>_total`

| Id | Tipo | Nota |
|---|---|---|
| `<…>_total_text` | valor / texto | Total de un ítem del historial. |

## wallet

Fuente: `packages/features/core/wallet/constants/lib/wallet_ids.dart`

### `wallet_accounts`

| Id | Tipo | Nota |
|---|---|---|
| `wallet_accounts_view` | raíz de vista | Raíz de la billetera. |
| `wallet_accounts_state_loading` | raíz de estado | Billetera cargando. |
| `wallet_accounts_state_data` | raíz de estado | Billetera con saldo. |
| `wallet_accounts_state_empty` | raíz de estado | Billetera sin saldo. |
| `wallet_accounts_state_error` | raíz de estado | Billetera con error. |
| `wallet_accounts_back_icon_button` | botón de ícono | Volver desde la billetera. |
| `wallet_accounts_simulated_text` | valor / texto | Badge "Simulado" de la billetera. |
| `wallet_accounts_empty_title_text` | valor / texto | Título del estado vacío. |
| `wallet_accounts_empty_deposit_button` | botón | "Hacer un depósito" del estado vacío. |
| `wallet_accounts_error_text` | valor / texto | Mensaje de error de la billetera. |
| `wallet_accounts_retry_button` | botón | "Reintentar" de la billetera. |

### `wallet_cop`

| Id | Tipo | Nota |
|---|---|---|
| `wallet_cop_available_text` | valor / texto | Disponible en COP. |
| `wallet_cop_reserved_text` | valor / texto | Reservado en COP. |
| `wallet_cop_deposit_button` | botón | Depositar en COP. |

### `wallet_mxn`

| Id | Tipo | Nota |
|---|---|---|
| `wallet_mxn_available_text` | valor / texto | Disponible en MXN. |
| `wallet_mxn_reserved_text` | valor / texto | Reservado en MXN. |
| `wallet_mxn_deposit_button` | botón | Depositar en MXN. |

### `wallet_pen`

| Id | Tipo | Nota |
|---|---|---|
| `wallet_pen_available_text` | valor / texto | Disponible en PEN. |
| `wallet_pen_reserved_text` | valor / texto | Reservado en PEN. |
| `wallet_pen_deposit_button` | botón | Depositar en PEN. |

### `wallet_deposit`

| Id | Tipo | Nota |
|---|---|---|
| `wallet_deposit_view` | raíz de vista | Raíz del depósito. |
| `wallet_deposit_close_icon_button` | botón de ícono | Cerrar el depósito. |
| `wallet_deposit_currency_menu` | selector | Selector de moneda. |
| `wallet_deposit_currency_cop_segment` | segmento | Moneda COP. |
| `wallet_deposit_currency_mxn_segment` | segmento | Moneda MXN. |
| `wallet_deposit_currency_pen_segment` | segmento | Moneda PEN. |
| `wallet_deposit_amount_field` | campo | Campo del monto. |
| `wallet_deposit_available_text` | valor / texto | Saldo disponible en la moneda elegida. |
| `wallet_deposit_disclaimer_text` | valor / texto | Aviso de simulación del depósito. |
| `wallet_deposit_submit_button` | botón | Botón "Depositar". |
| `wallet_deposit_error_text` | valor / texto | Mensaje de error del depósito. |
| `wallet_deposit_success_snackbar` | snackbar | Snackbar de depósito realizado. |

### `wallet_account`

| Id | Tipo | Nota |
|---|---|---|
| `wallet_account_item_<currencyCode>` | ítem / parte de ítem | Tarjeta de la cuenta en [currencyCode] (`COP`, `MXN`, `PEN`). |

### `wallet_deposit`

| Id | Tipo | Nota |
|---|---|---|
| `wallet_deposit_suggested_item_<amount>` | ítem / parte de ítem | Monto sugerido [amount] (string decimal de la API). |

## portfolio

Fuente: `packages/features/core/portfolio/constants/lib/portfolio_ids.dart`

### `portfolio_overview`

| Id | Tipo | Nota |
|---|---|---|
| `portfolio_overview_view` | raíz de vista | Raíz del portafolio. |
| `portfolio_overview_state_loading` | raíz de estado | Portafolio cargando. |
| `portfolio_overview_state_data` | raíz de estado | Portafolio con datos. |
| `portfolio_overview_state_empty` | raíz de estado | Portafolio sin inversiones. |
| `portfolio_overview_state_error` | raíz de estado | Portafolio con error. |
| `portfolio_overview_simulated_text` | valor / texto | Badge "Simulado". |
| `portfolio_overview_total_tile` | tarjeta | Tarjeta del valor total. |
| `portfolio_overview_total_text` | valor / texto | Valor total en moneda base. |
| `portfolio_overview_day_change_text` | valor / texto | Variación del día. |
| `portfolio_overview_cash_text` | valor / texto | Efectivo. |
| `portfolio_overview_invested_text` | valor / texto | Invertido. |
| `portfolio_overview_allocation_chart` | gráfico | Gráfico de distribución. |
| `portfolio_overview_fx_text` | valor / texto | Nota de los tipos de cambio usados. |
| `portfolio_overview_empty_title_text` | valor / texto | Título del estado vacío. |
| `portfolio_overview_explore_button` | botón | "Explorar mercado". |
| `portfolio_overview_error_text` | valor / texto | Mensaje de error. |
| `portfolio_overview_retry_button` | botón | "Reintentar". |

### `portfolio_position`

| Id | Tipo | Nota |
|---|---|---|
| `portfolio_position_item_<instrumentId>` | ítem / parte de ítem | Posición en el instrumento [instrumentId]. |

### `<…>_quantity`

| Id | Tipo | Nota |
|---|---|---|
| `<…>_quantity_text` | valor / texto | Cantidad de una posición. |

### `<…>_avg`

| Id | Tipo | Nota |
|---|---|---|
| `<…>_avg_cost_text` | valor / texto | Costo promedio de una posición. |

### `<…>_value`

| Id | Tipo | Nota |
|---|---|---|
| `<…>_value_text` | valor / texto | Valor de mercado de una posición. |

### `<…>_pnl`

| Id | Tipo | Nota |
|---|---|---|
| `<…>_pnl_text` | valor / texto | P&L no realizado de una posición. |

### `portfolio_allocation`

| Id | Tipo | Nota |
|---|---|---|
| `portfolio_allocation_item_<type>` | ítem / parte de ítem | Porción de la distribución de tipo [type] (`STOCK`, `ETF`, `CASH`). |

## transactions

Fuente: `packages/features/core/transactions/constants/lib/transactions_ids.dart`

### `transactions_list`

| Id | Tipo | Nota |
|---|---|---|
| `transactions_list_view` | raíz de vista | Raíz de la lista de movimientos. |
| `transactions_list_state_loading` | raíz de estado | Movimientos cargando. |
| `transactions_list_state_data` | raíz de estado | Movimientos con datos. |
| `transactions_list_state_empty` | raíz de estado | Sin movimientos. |
| `transactions_list_state_error` | raíz de estado | Movimientos con error. |
| `transactions_list_simulated_text` | valor / texto | Badge "Simulado". |
| `transactions_list_section_menu` | selector | Selector de sección de la tab Actividad. |
| `transactions_list_movements_tab` | tab | Sección "Movimientos" del selector de Actividad. |
| `transactions_list_orders_tab` | tab | Sección "Órdenes" del selector de Actividad. |
| `transactions_list_type_all_chip` | chip | Filtro de tipo: todos. |
| `transactions_list_type_deposit_chip` | chip | Filtro de tipo: depósitos. |
| `transactions_list_type_buy_chip` | chip | Filtro de tipo: compras. |
| `transactions_list_type_sell_chip` | chip | Filtro de tipo: ventas. |
| `transactions_list_type_fee_chip` | chip | Filtro de tipo: comisiones. |
| `transactions_list_range_all_chip` | chip | Rango: todo. |
| `transactions_list_range_7d_chip` | chip | Rango: últimos 7 días. |
| `transactions_list_range_30d_chip` | chip | Rango: últimos 30 días. |
| `transactions_list_range_90d_chip` | chip | Rango: últimos 90 días. |
| `transactions_list_loading_more_text` | valor / texto | Página siguiente cargando. |
| `transactions_list_load_more_error_text` | valor / texto | Error de la página siguiente. |
| `transactions_list_load_more_retry_button` | botón | Reintentar la página siguiente. |
| `transactions_list_empty_title_text` | valor / texto | Título del estado vacío. |
| `transactions_list_empty_deposit_button` | botón | "Depositar" del estado vacío. |
| `transactions_list_clear_filters_button` | botón | "Limpiar filtros" del estado vacío con filtros. |
| `transactions_list_error_text` | valor / texto | Mensaje de error. |
| `transactions_list_retry_button` | botón | "Reintentar". |

### `transactions_day`

| Id | Tipo | Nota |
|---|---|---|
| `transactions_day_item_<isoDate>` | ítem / parte de ítem | Encabezado del día [isoDate] (`2026-11-18`). |

### `transactions_list`

| Id | Tipo | Nota |
|---|---|---|
| `transactions_list_item_<transactionId>` | ítem / parte de ítem | Movimiento [transactionId]. |

### `<…>_amount`

| Id | Tipo | Nota |
|---|---|---|
| `<…>_amount_text` | valor / texto | Monto de un movimiento. |

### `<…>_description`

| Id | Tipo | Nota |
|---|---|---|
| `<…>_description_text` | valor / texto | Descripción de un movimiento. |

## Cambios de contrato

| Fecha | Id anterior | Id nuevo | Motivo |
|---|---|---|---|
| — | — | — | Versión inicial del contrato. |

_Total: 338 identificadores._
