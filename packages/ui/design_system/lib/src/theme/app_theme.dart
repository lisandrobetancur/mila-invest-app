import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'market_colors.dart';

/// Temas de MILA Invest, sobre Material 3.
///
/// Todo widget nativo de Material se estiliza aquí: ninguna vista envuelve
/// widgets en `Theme(data: ...)` ad hoc.
abstract final class AppTheme {
  /// Tema claro.
  static ThemeData get light => _build(
    brightness: Brightness.light,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.onPrimaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.onSecondaryLight,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceVariant: AppColors.surfaceVariantLight,
    outline: AppColors.outlineLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    error: AppColors.errorLight,
    onError: AppColors.onErrorLight,
    market: MarketColors.light,
    shadowOpacity: 0.12,
  );

  /// Tema oscuro.
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.onPrimaryDark,
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.onSecondaryDark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceVariant: AppColors.surfaceVariantDark,
    outline: AppColors.outlineDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    error: AppColors.errorDark,
    onError: AppColors.onErrorDark,
    market: MarketColors.dark,
    shadowOpacity: 0.4,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color outline,
    required Color textPrimary,
    required Color textSecondary,
    required Color error,
    required Color onError,
    required MarketColors market,
    required double shadowOpacity,
  }) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          secondary: secondary,
          onSecondary: onSecondary,
          surface: surface,
          onSurface: textPrimary,
          onSurfaceVariant: textSecondary,
          surfaceContainerLowest: surface,
          surfaceContainerLow: surface,
          surfaceContainer: surface,
          surfaceContainerHigh: surfaceVariant,
          surfaceContainerHighest: surfaceVariant,
          outline: outline,
          outlineVariant: outline,
          error: error,
          onError: onError,
          surfaceTint: Colors.transparent,
          shadow: Colors.black.withValues(alpha: shadowOpacity),
        );
    final TextTheme textTheme = AppTypography.textTheme(
      primary: textPrimary,
      secondary: textSecondary,
    );
    final BorderSide hairline = BorderSide(color: outline);
    const Size minButton = Size(
      AppSpacing.minTouchTarget,
      AppSpacing.minTouchTarget,
    );
    const EdgeInsets buttonPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.sm,
    );
    const RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
      borderRadius: AppRadius.mdAll,
    );
    OutlineInputBorder inputBorder(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      fontFamily: AppTypography.inter,
      package: AppTypography.fontPackage,
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: <ThemeExtension<dynamic>>[market],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: hairline,
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: textPrimary, size: 24, weight: 400),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minButton,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: AppTypography.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minButton,
          padding: buttonPadding,
          shape: buttonShape,
          side: hairline,
          foregroundColor: primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: minButton,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          shape: buttonShape,
          foregroundColor: primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: minButton,
          foregroundColor: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: textTheme.bodyMedium,
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: primary),
        hintStyle: textTheme.bodyMedium,
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: error),
        errorMaxLines: 3,
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: inputBorder(Colors.transparent),
        enabledBorder: inputBorder(Colors.transparent),
        disabledBorder: inputBorder(Colors.transparent),
        focusedBorder: inputBorder(primary, width: 1.5),
        errorBorder: inputBorder(error),
        focusedErrorBorder: inputBorder(error, width: 1.5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary,
        disabledColor: surfaceVariant,
        checkmarkColor: onPrimary,
        showCheckmark: false,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        // El color del texto depende de la selección: sobre `primary` va
        // `onPrimary`; si no, el texto quedaba del mismo color que el fondo.
        labelStyle: AppTypography.labelSmall.copyWith(
          color: WidgetStateColor.resolveWith(
            (Set<WidgetState> states) =>
                states.contains(WidgetState.selected) ? onPrimary : textPrimary,
          ),
        ),
        secondaryLabelStyle: AppTypography.labelSmall.copyWith(
          color: onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: minButton,
          backgroundColor: surfaceVariant,
          foregroundColor: textPrimary,
          selectedBackgroundColor: primary,
          selectedForegroundColor: onPrimary,
          side: BorderSide.none,
          shape: buttonShape,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shadowColor: Colors.black.withValues(alpha: shadowOpacity),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        modalElevation: 24,
        shadowColor: Colors.black.withValues(alpha: shadowOpacity),
        showDragHandle: true,
        dragHandleColor: outline,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlTop),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: surface),
        actionTextColor: brightness == Brightness.light
            ? AppColors.primaryDark
            : AppColors.primaryLight,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: surfaceVariant,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) => AppTypography.labelSmall.copyWith(
            color: states.contains(WidgetState.selected)
                ? primary
                : textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primary
                : textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: surfaceVariant,
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: primary,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: textSecondary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        dividerColor: outline,
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelLarge,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        side: BorderSide(color: textSecondary, width: 1.5),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceVariant,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textPrimary,
          borderRadius: AppRadius.smAll,
        ),
        textStyle: AppTypography.labelSmall.copyWith(color: surface),
      ),
    );
  }
}
