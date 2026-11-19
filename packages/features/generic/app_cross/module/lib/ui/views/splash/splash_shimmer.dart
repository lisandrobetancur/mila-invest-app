part of 'splash.dart';

class _SplashShimmer extends StatelessWidget {
  const _SplashShimmer();

  @override
  Widget build(BuildContext context) => Center(
    child: Identified(
      id: AppCrossIds.splashStateLoading,
      label: context.tr('app_cross.splash.loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            context.tr('app_cross.splash.title'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppShimmer(child: AppShimmerBox(width: 96, height: 4)),
        ],
      ),
    ),
  );
}
