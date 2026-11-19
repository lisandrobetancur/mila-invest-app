part of 'splash.dart';

/// Splash: arranca la app y deja que el `redirect` decida a dónde seguir.
///
/// No tiene ninguna animación más larga que lo que tarda el bootstrap.
class SplashView extends ConsumerWidget {
  /// Crea el splash.
  const SplashView({super.key});

  /// Path de la ruta.
  static const String route = AppCrossRoutes.splashPath;

  /// Nombre de la ruta.
  static const String name = AppCrossRoutes.splashName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BootstrapState state = ref.watch(bootstrapViewModelProvider);
    return Identified(
      id: AppCrossIds.splashView,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: switch (state.status) {
              ViewStatus.loading ||
              ViewStatus.data ||
              ViewStatus.empty => const _SplashShimmer(),
              ViewStatus.error => _SplashError(state: state),
            },
          ),
        ),
      ),
    );
  }
}
