part of 'onboarding.dart';

/// Provider del controller del onboarding.
final AutoDisposeNotifierProvider<OnboardingViewModel, OnboardingState>
onboardingViewModelProvider =
    NotifierProvider.autoDispose<OnboardingViewModel, OnboardingState>(
      OnboardingViewModel.new,
    );
