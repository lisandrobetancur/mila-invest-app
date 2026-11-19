part of 'onboarding.dart';

/// Controller del onboarding.
class OnboardingViewModel extends AutoDisposeViewModel<OnboardingState> {
  late AppCrossNavigator _navigator;

  @override
  OnboardingState initState() => const OnboardingState();

  @override
  void postInit() => _navigator = ref.read(appCrossNavigatorProvider.notifier);

  /// Termina (o salta) el onboarding y va al login.
  Future<void> finish() async {
    if (state.submitStatus.isSubmitting) {
      return;
    }
    final Object key = mountedKey;
    state = state.copyWith(submitStatus: SubmitStatus.submitting);
    await ref.read(preferencesViewModelProvider.notifier).completeOnboarding();
    if (!isMounted(key)) {
      return;
    }
    state = state.copyWith(submitStatus: SubmitStatus.success);
    _navigator.goToLogin();
  }

  /// Avanza un paso; en el último, termina.
  Future<void> next() async {
    if (state.isLastStep) {
      await finish();
      return;
    }
    state = state.copyWith(step: state.step + 1);
  }
}
