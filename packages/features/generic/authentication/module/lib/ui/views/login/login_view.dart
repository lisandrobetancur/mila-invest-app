part of 'login.dart';

/// Login: email, contraseña y acceso al registro.
///
/// Con el backend falso ofrece "Usar cuenta demo".
class LoginView extends ConsumerStatefulWidget {
  /// Crea el login.
  const LoginView({super.key});

  /// Path de la ruta.
  static const String route = AuthRoutes.loginPath;

  /// Nombre de la ruta.
  static const String name = AuthRoutes.loginName;

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoginState state = ref.watch(loginViewModelProvider);
    final LoginViewModel viewModel = ref.read(loginViewModelProvider.notifier);
    final DemoCredentials? demo = ref.watch(demoCredentialsProvider);
    final ThemeData theme = Theme.of(context);
    final String? emailError = state.emailErrorKey;
    final String? passwordError = state.passwordErrorKey;
    final String? error = state.errorKey;

    void useDemo(DemoCredentials credentials) {
      _email.text = credentials.email;
      _password.text = credentials.password;
      viewModel.useDemo(credentials);
    }

    return AppScaffold(
      id: AuthIds.loginView,
      maxWidth: 440,
      badge: AppBadge(
        id: AuthIds.loginSimulatedText,
        label: context.tr('auth.common.simulated'),
        tone: AppBadgeTone.accent,
      ),
      title: 'MILA Invest',
      body: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.tr('auth.login.title'),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              context.tr('auth.login.subtitle'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              id: AuthIds.loginEmailField,
              label: context.tr('auth.login.email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.email],
              errorText: emailError == null ? null : context.tr(emailError),
              onChanged: viewModel.setEmail,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              id: AuthIds.loginPasswordField,
              label: context.tr('auth.login.password'),
              controller: _password,
              obscureText: state.obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.password],
              errorText: passwordError == null
                  ? null
                  : context.tr(passwordError),
              onChanged: viewModel.setPassword,
              onSubmitted: (_) => viewModel.submit(),
              suffix: AppIconButton(
                id: AuthIds.loginPasswordToggle,
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
            if (error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              AppBanner(
                id: AuthIds.loginErrorText,
                message: context.tr(error),
                tone: AppBannerTone.error,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              id: AuthIds.loginSubmitButton,
              label: context.tr('auth.login.submit'),
              expanded: true,
              loading: state.submitStatus.isSubmitting,
              onPressed: viewModel.submit,
            ),
            if (demo != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                id: AuthIds.loginDemoButton,
                label: context.tr('auth.login.demo'),
                icon: AppIcons.simulated,
                variant: AppButtonVariant.secondary,
                expanded: true,
                onPressed: state.submitStatus.isSubmitting
                    ? null
                    : () => useDemo(demo),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  context.tr('auth.login.no_account'),
                  style: theme.textTheme.bodyMedium,
                ),
                AppButton(
                  id: AuthIds.loginRegisterLink,
                  label: context.tr('auth.login.register'),
                  variant: AppButtonVariant.text,
                  onPressed: viewModel.goToRegister,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            DisclaimerBanner(
              id: AuthIds.loginDisclaimerText,
              text: context.tr('auth.common.disclaimer'),
              variant: DisclaimerBannerVariant.compact,
            ),
          ],
        ),
      ),
    );
  }
}
