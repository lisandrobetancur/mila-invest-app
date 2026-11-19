part of 'deposit.dart';

/// Depósito virtual: moneda, monto con sugerencias y confirmación.
///
/// Es un formulario, no una vista con datos: no tiene los cuatro estados.
class DepositView extends ConsumerStatefulWidget {
  /// Crea el depósito con [currency] preseleccionada.
  const DepositView({required this.currency, super.key});

  /// Path de la ruta.
  static const String route = WalletRoutes.depositPath;

  /// Nombre de la ruta.
  static const String name = WalletRoutes.depositName;

  /// Moneda preseleccionada.
  final Currency currency;

  @override
  ConsumerState<DepositView> createState() => _DepositViewState();
}

class _DepositViewState extends ConsumerState<DepositView> {
  final TextEditingController _amount = TextEditingController();

  static const List<Currency> _currencies = <Currency>[
    Currency.cop,
    Currency.mxn,
    Currency.pen,
  ];

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DepositState state = ref.watch(
      depositViewModelProvider(widget.currency),
    );
    final DepositViewModel viewModel = ref.read(
      depositViewModelProvider(widget.currency).notifier,
    );
    ref.listen<String>(
      depositViewModelProvider(
        widget.currency,
      ).select((DepositState next) => next.amountText),
      (String? previous, String next) {
        if (_amount.text != next) {
          _amount.text = next;
        }
      },
    );
    final ThemeData theme = Theme.of(context);
    final String? amountError = state.visibleAmountErrorKey;
    final String? error = state.errorKey;
    final Money? available = state.available;

    Future<void> submit() async {
      final bool done = await viewModel.submit();
      final Money? amount = state.amount;
      if (done && context.mounted && amount != null) {
        AppSnackbar.show(
          context,
          id: WalletIds.depositSuccessSnackbar,
          message: context.tr(
            'wallet.deposit.success',
            namedArgs: <String, String>{'amount': Formatters.money(amount)},
          ),
          tone: AppSnackbarTone.success,
        );
        viewModel.close();
      }
    }

    return Identified(
      id: WalletIds.depositView,
      child: Material(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            context.tr('wallet.deposit.title'),
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        AppIconButton(
                          id: WalletIds.depositCloseIconButton,
                          icon: AppIcons.close,
                          tooltip: context.tr('wallet.common.close'),
                          onPressed: viewModel.close,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      context.tr('wallet.deposit.currency'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppSegmentedControl<Currency>(
                      id: WalletIds.depositCurrencyMenu,
                      selected: state.currency,
                      onChanged: viewModel.setCurrency,
                      segments: <AppSegment<Currency>>[
                        for (final Currency currency in _currencies)
                          AppSegment<Currency>(
                            id: WalletIdsOf.segment(currency),
                            value: currency,
                            label: currency.code,
                          ),
                      ],
                    ),
                    if (available != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Identified(
                        id: WalletIds.depositAvailableText,
                        child: Text(
                          context.tr(
                            'wallet.deposit.available',
                            namedArgs: <String, String>{
                              'amount': Formatters.money(available),
                            },
                          ),
                          style: AppTypography.tabular(
                            theme.textTheme.bodyMedium ??
                                AppTypography.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppTextField.numeric(
                      id: WalletIds.depositAmountField,
                      label: context.tr('wallet.deposit.amount'),
                      controller: _amount,
                      prefix: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          state.currency.symbol,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      errorText: amountError == null
                          ? null
                          : context.tr(amountError),
                      onChanged: viewModel.setAmountText,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        for (final String suggestion in state.suggestions)
                          AppChip(
                            id: WalletIds.suggestedItem(suggestion),
                            label: Formatters.money(
                              Money.parse(suggestion, state.currency),
                            ),
                            selected: state.amountText == suggestion,
                            onSelected: (_) =>
                                viewModel.useSuggestion(suggestion),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DisclaimerBanner(
                      id: WalletIds.depositDisclaimerText,
                      text: context.tr('wallet.common.disclaimer'),
                    ),
                    if (error != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      AppBanner(
                        id: WalletIds.depositErrorText,
                        message: context.tr(error),
                        tone: AppBannerTone.error,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      id: WalletIds.depositSubmitButton,
                      label: context.tr('wallet.deposit.submit'),
                      expanded: true,
                      loading: state.submitStatus.isSubmitting,
                      onPressed: submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
