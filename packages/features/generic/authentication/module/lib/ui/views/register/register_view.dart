part of 'register.dart';

/// Registro: país primero, luego nombre, email, documento, contraseña con
/// indicador de requisitos y aceptación del aviso de simulación.
class RegisterView extends ConsumerStatefulWidget {
  /// Crea el registro.
  const RegisterView({super.key});

  /// Path de la ruta.
  static const String route = AuthRoutes.registerPath;

  /// Nombre de la ruta.
  static const String name = AuthRoutes.registerName;

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final TextEditingController _document = TextEditingController();

  @override
  void dispose() {
    _document.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RegisterState state = ref.watch(registerViewModelProvider);
    final RegisterViewModel viewModel = ref.read(
      registerViewModelProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);
    final Country? country = state.country;
    final String? error = state.errorKey;
    ref.listen<RegisterState>(registerViewModelProvider, (
      RegisterState? previous,
      RegisterState next,
    ) {
      if (next.documentNumber.isEmpty && _document.text.isNotEmpty) {
        _document.clear();
      }
    });

    String? errorOf(AuthField field) {
      final String? key = state.errorKeyOf(field);
      return key == null ? null : context.tr(key);
    }

    return AppScaffold(
      id: AuthIds.registerView,
      title: context.tr('auth.register.title'),
      maxWidth: 520,
      leading: AppIconButton(
        id: AuthIds.registerBackIconButton,
        icon: AppIcons.back,
        tooltip: context.tr('auth.common.back'),
        onPressed: viewModel.goToLogin,
      ),
      badge: AppBadge(
        id: AuthIds.registerSimulatedText,
        label: context.tr('auth.common.simulated'),
        tone: AppBadgeTone.accent,
      ),
      body: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              context.tr('auth.register.country_title'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                for (final Country option in Country.values)
                  AppChip(
                    id: _countryChipId(option),
                    label: context.tr(
                      'auth.register.country_${option.code.toLowerCase()}',
                    ),
                    selected: option == country,
                    onSelected: (_) => viewModel.setCountry(option),
                  ),
              ],
            ),
            _FieldMessage(
              id: AuthIds.registerCountryErrorText,
              message: errorOf(AuthField.country),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              id: AuthIds.registerNameField,
              label: context.tr('auth.register.name'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.name],
              errorText: errorOf(AuthField.fullName),
              onChanged: viewModel.setFullName,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              id: AuthIds.registerEmailField,
              label: context.tr('auth.register.email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.email],
              errorText: errorOf(AuthField.email),
              onChanged: viewModel.setEmail,
            ),
            if (country != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                context.tr('auth.register.document_type'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  for (final DocumentType type in state.documentTypes)
                    AppChip(
                      id: _documentChipId(type),
                      label: context.tr(_documentLabelKey(type, country)),
                      selected: type == state.documentType,
                      onSelected: (_) => viewModel.setDocumentType(type),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                id: AuthIds.registerDocumentField,
                label: context.tr('auth.register.document_number'),
                controller: _document,
                maxLength: AuthLimits.documentMaxLength,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                errorText: errorOf(AuthField.documentNumber),
                onChanged: viewModel.setDocumentNumber,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              id: AuthIds.registerPasswordField,
              label: context.tr('auth.register.password'),
              obscureText: state.obscurePassword,
              autofillHints: const <String>[AutofillHints.newPassword],
              errorText: errorOf(AuthField.password),
              onChanged: viewModel.setPassword,
              suffix: AppIconButton(
                id: AuthIds.registerPasswordToggle,
                icon: state.obscurePassword
                    ? AppIcons.visibility
                    : AppIcons.visibilityOff,
                tooltip: context.tr(
                  state.obscurePassword
                      ? 'auth.common.show_password'
                      : 'auth.common.hide_password',
                ),
                onPressed: viewModel.toggleObscure,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _Requirement(
              id: AuthIds.registerRequirementLengthText,
              labelKey: 'auth.register.requirement_length',
              met: state.passwordHasMinLength,
            ),
            _Requirement(
              id: AuthIds.registerRequirementLetterText,
              labelKey: 'auth.register.requirement_letter',
              met: state.passwordHasLetter,
            ),
            _Requirement(
              id: AuthIds.registerRequirementNumberText,
              labelKey: 'auth.register.requirement_number',
              met: state.passwordHasNumber,
            ),
            const SizedBox(height: AppSpacing.md),
            DisclaimerBanner(
              id: AuthIds.registerDisclaimerText,
              text: context.tr('auth.common.disclaimer'),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCheckbox(
              id: AuthIds.registerAcceptCheckbox,
              label: context.tr('auth.register.accept'),
              value: state.accepted,
              onChanged: (bool accepted) =>
                  viewModel.setAccepted(accepted: accepted),
            ),
            _FieldMessage(
              id: AuthIds.registerAcceptCheckboxErrorText,
              message: state.acceptErrorKey == null
                  ? null
                  : context.tr(state.acceptErrorKey!),
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              AppBanner(
                id: AuthIds.registerErrorText,
                message: context.tr(error),
                tone: AppBannerTone.error,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              id: AuthIds.registerSubmitButton,
              label: context.tr('auth.register.submit'),
              expanded: true,
              loading: state.submitStatus.isSubmitting,
              onPressed: viewModel.submit,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  context.tr('auth.register.have_account'),
                  style: theme.textTheme.bodyMedium,
                ),
                AppButton(
                  id: AuthIds.registerLoginLink,
                  label: context.tr('auth.register.login'),
                  variant: AppButtonVariant.text,
                  onPressed: viewModel.goToLogin,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
