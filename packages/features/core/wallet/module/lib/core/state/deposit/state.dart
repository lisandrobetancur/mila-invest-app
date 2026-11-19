part of 'deposit.dart';

/// Estado del depósito.
class DepositState extends Equatable {
  /// Crea el estado.
  const DepositState({
    required this.currency,
    this.amountText = '',
    this.available,
    this.submitStatus = SubmitStatus.idle,
    this.showValidation = false,
    this.receipt,
    this.errorKey,
  });

  static const Object _unset = Object();

  /// Moneda elegida.
  final Currency currency;

  /// Monto tal como lo escribió el usuario.
  final String amountText;

  /// Saldo disponible en [currency].
  final Money? available;

  /// Estado del envío.
  final SubmitStatus submitStatus;

  /// `true` después del primer intento de envío.
  final bool showValidation;

  /// Comprobante del último depósito.
  final DepositReceipt? receipt;

  /// Clave del error del envío.
  final String? errorKey;

  /// Monto como dinero, o `null` si no es un número.
  ///
  /// Acepta `,` o `.` como separador decimal y descarta espacios.
  Money? get amount {
    final String raw = amountText
        .trim()
        .replaceAll(' ', '')
        .replaceAll(',', '.');
    final Decimal? value = Decimal.tryParse(raw);
    return value == null ? null : Money(value, currency);
  }

  /// Clave del error del monto, o `null` si es válido.
  String? get amountErrorKey {
    final Money? value = amount;
    if (value == null) {
      return 'wallet.deposit.amount_invalid';
    }
    if (!value.isPositive) {
      return 'wallet.deposit.amount_min';
    }
    if (value.amount > Decimal.parse(WalletLimits.maxDeposit)) {
      return 'wallet.deposit.amount_max';
    }
    return null;
  }

  /// Error del monto a mostrar (desde el primer intento de envío).
  String? get visibleAmountErrorKey => showValidation ? amountErrorKey : null;

  /// Montos sugeridos para [currency].
  List<String> get suggestions =>
      WalletLimits.suggestedDeposits[currency.code] ?? const <String>[];

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  DepositState copyWith({
    Currency? currency,
    String? amountText,
    Object? available = _unset,
    SubmitStatus? submitStatus,
    bool? showValidation,
    Object? receipt = _unset,
    Object? errorKey = _unset,
  }) => DepositState(
    currency: currency ?? this.currency,
    amountText: amountText ?? this.amountText,
    available: identical(available, _unset)
        ? this.available
        : available as Money?,
    submitStatus: submitStatus ?? this.submitStatus,
    showValidation: showValidation ?? this.showValidation,
    receipt: identical(receipt, _unset)
        ? this.receipt
        : receipt as DepositReceipt?,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
  );

  @override
  List<Object?> get props => <Object?>[
    currency,
    amountText,
    available,
    submitStatus,
    showValidation,
    receipt,
    errorKey,
  ];
}
