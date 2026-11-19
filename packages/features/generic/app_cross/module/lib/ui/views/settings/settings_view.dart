part of 'settings.dart';

/// Ajustes: tema, idioma, datos de la cuenta, cierre de sesión y datos del
/// build.
class SettingsView extends ConsumerWidget {
  /// Crea la vista de ajustes.
  const SettingsView({super.key});

  /// Path de la ruta.
  static const String route = AppCrossRoutes.settingsPath;

  /// Nombre de la ruta.
  static const String name = AppCrossRoutes.settingsName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPreferences preferences = ref.watch(appPreferencesProvider);
    final SettingsState state = ref.watch(settingsViewModelProvider);
    final User? user = ref.watch(sessionProvider).user;
    final AppInfo info = ref.watch(appInfoProvider);
    final PreferencesViewModel preferencesViewModel = ref.read(
      preferencesViewModelProvider.notifier,
    );
    final SettingsViewModel viewModel = ref.read(
      settingsViewModelProvider.notifier,
    );

    Future<void> confirmLogout() async {
      final bool confirmed = await AppDialog.show(
        context,
        id: AppCrossIds.settingsLogoutDialog,
        title: context.tr('app_cross.settings.logout_title'),
        message: context.tr('app_cross.settings.logout_message'),
        confirmId: AppCrossIds.settingsLogoutConfirmButton,
        confirmLabel: context.tr('app_cross.settings.logout_confirm'),
        cancelId: AppCrossIds.settingsLogoutCancelButton,
        cancelLabel: context.tr('app_cross.settings.logout_cancel'),
        destructive: true,
      );
      if (confirmed) {
        await viewModel.signOut();
      }
    }

    return AppScaffold(
      id: AppCrossIds.settingsView,
      title: context.tr('app_cross.settings.title'),
      maxWidth: 640,
      leading: AppIconButton(
        id: AppCrossIds.settingsBackIconButton,
        icon: AppIcons.back,
        tooltip: context.tr('app_cross.common.back'),
        onPressed: ref.read(appCrossNavigatorProvider.notifier).closeSettings,
      ),
      badge: AppBadge(
        id: AppCrossIds.settingsSimulatedText,
        label: context.tr('app_cross.common.simulated'),
        tone: AppBadgeTone.accent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Section(
            title: context.tr('app_cross.settings.theme_title'),
            child: AppSegmentedControl<AppThemePreference>(
              id: AppCrossIds.settingsThemeMenu,
              selected: preferences.theme,
              onChanged: preferencesViewModel.setTheme,
              segments: <AppSegment<AppThemePreference>>[
                AppSegment<AppThemePreference>(
                  id: AppCrossIds.settingsThemeSystemSegment,
                  value: AppThemePreference.system,
                  label: context.tr('app_cross.settings.theme_system'),
                ),
                AppSegment<AppThemePreference>(
                  id: AppCrossIds.settingsThemeLightSegment,
                  value: AppThemePreference.light,
                  label: context.tr('app_cross.settings.theme_light'),
                ),
                AppSegment<AppThemePreference>(
                  id: AppCrossIds.settingsThemeDarkSegment,
                  value: AppThemePreference.dark,
                  label: context.tr('app_cross.settings.theme_dark'),
                ),
              ],
            ),
          ),
          _Section(
            title: context.tr('app_cross.settings.language_title'),
            child: AppSegmentedControl<AppLanguage>(
              id: AppCrossIds.settingsLanguageMenu,
              selected: preferences.language,
              onChanged: preferencesViewModel.setLanguage,
              segments: <AppSegment<AppLanguage>>[
                AppSegment<AppLanguage>(
                  id: AppCrossIds.settingsLanguageEsSegment,
                  value: AppLanguage.es,
                  label: AppLanguage.es.nativeName,
                ),
                AppSegment<AppLanguage>(
                  id: AppCrossIds.settingsLanguageEnSegment,
                  value: AppLanguage.en,
                  label: AppLanguage.en.nativeName,
                ),
              ],
            ),
          ),
          if (user != null)
            _Section(
              title: context.tr('app_cross.settings.account_title'),
              child: _AccountCard(user: user),
            ),
          AppButton(
            id: AppCrossIds.settingsLogoutButton,
            label: context.tr('app_cross.settings.logout'),
            icon: AppIcons.logout,
            variant: AppButtonVariant.secondary,
            loading: state.logoutStatus.isSubmitting,
            onPressed: confirmLogout,
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: context.tr('app_cross.settings.about_title'),
            child: _AboutCard(info: info),
          ),
          DisclaimerBanner(
            id: AppCrossIds.settingsDisclaimerText,
            text: context.tr('app_cross.common.disclaimer'),
            variant: DisclaimerBannerVariant.compact,
          ),
        ],
      ),
    );
  }
}
