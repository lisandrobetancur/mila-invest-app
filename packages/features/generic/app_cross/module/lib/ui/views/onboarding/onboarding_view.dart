part of 'onboarding.dart';

/// Onboarding de tres pasos: qué es MILA Invest, que es una simulación con
/// dinero virtual y qué productos hay. Solo se muestra la primera vez.
class OnboardingView extends ConsumerWidget {
  /// Crea el onboarding.
  const OnboardingView({super.key});

  /// Path de la ruta.
  static const String route = AppCrossRoutes.onboardingPath;

  /// Nombre de la ruta.
  static const String name = AppCrossRoutes.onboardingName;

  static const List<IconData> _icons = <IconData>[
    AppIcons.market,
    AppIcons.simulated,
    AppIcons.portfolio,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
    final OnboardingViewModel viewModel = ref.read(
      onboardingViewModelProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);
    final int number = state.stepNumber;
    return AppScaffold(
      id: AppCrossIds.onboardingView,
      maxWidth: 560,
      actions: <Widget>[
        AppButton(
          id: AppCrossIds.onboardingSkipButton,
          label: context.tr('app_cross.onboarding.skip'),
          variant: AppButtonVariant.text,
          onPressed: state.submitStatus.isSubmitting ? null : viewModel.finish,
        ),
      ],
      bottomBar: state.isLastStep
          ? AppButton(
              id: AppCrossIds.onboardingStartButton,
              label: context.tr('app_cross.onboarding.start'),
              expanded: true,
              loading: state.submitStatus.isSubmitting,
              onPressed: viewModel.finish,
            )
          : AppButton(
              id: AppCrossIds.onboardingNextButton,
              label: context.tr('app_cross.onboarding.next'),
              expanded: true,
              onPressed: viewModel.next,
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: AppSpacing.lg),
          ExcludeSemantics(
            child: Icon(
              _icons[state.step],
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Identified(
            id: AppCrossIds.onboardingProgressText,
            child: Text(
              context.tr(
                'app_cross.onboarding.progress',
                namedArgs: <String, String>{
                  'current': '$number',
                  'total': '${AppCrossLimits.onboardingSteps}',
                },
              ),
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Identified(
            id: AppCrossIds.onboardingStepTitleText,
            child: Text(
              context.tr('app_cross.onboarding.step${number}_title'),
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Identified(
            id: AppCrossIds.onboardingStepBodyText,
            child: Text(
              context.tr('app_cross.onboarding.step${number}_body'),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DisclaimerBanner(
            id: AppCrossIds.onboardingDisclaimerText,
            text: context.tr('app_cross.common.disclaimer'),
          ),
        ],
      ),
    );
  }
}
