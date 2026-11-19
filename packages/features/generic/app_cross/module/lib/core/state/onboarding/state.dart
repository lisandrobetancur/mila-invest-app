part of 'onboarding.dart';

/// Estado del onboarding.
class OnboardingState extends Equatable {
  /// Crea el estado.
  const OnboardingState({this.step = 0, this.submitStatus = SubmitStatus.idle});

  /// Paso visible, desde 0.
  final int step;

  /// Estado del cierre del onboarding.
  final SubmitStatus submitStatus;

  /// `true` en el último paso.
  bool get isLastStep => step >= AppCrossLimits.onboardingSteps - 1;

  /// Número del paso visible, desde 1.
  int get stepNumber => step + 1;

  /// Copia el estado cambiando algunos campos.
  OnboardingState copyWith({int? step, SubmitStatus? submitStatus}) =>
      OnboardingState(
        step: step ?? this.step,
        submitStatus: submitStatus ?? this.submitStatus,
      );

  @override
  List<Object?> get props => <Object?>[step, submitStatus];
}
