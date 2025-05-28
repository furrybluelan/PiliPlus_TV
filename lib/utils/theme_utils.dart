import 'package:PiliPlus/main.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';

class ThemeUtils {
  static ThemeData getThemeData({
    required ColorScheme colorScheme,
    required bool isDynamic,
    bool isDark = false,
    required FlexSchemeVariant variant,
  }) {
    final appFontWeight =
        GStorage.appFontWeight.clamp(-1, FontWeight.values.length - 1);
    final fontWeight =
        appFontWeight == -1 ? null : FontWeight.values[appFontWeight];
    late final textStyle = TextStyle(fontWeight: fontWeight);
    ThemeData themeData = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: fontWeight == null
          ? null
          : TextTheme(
              displayLarge: textStyle,
              displayMedium: textStyle,
              displaySmall: textStyle,
              headlineLarge: textStyle,
              headlineMedium: textStyle,
              headlineSmall: textStyle,
              titleLarge: textStyle,
              titleMedium: textStyle,
              titleSmall: textStyle,
              bodyLarge: textStyle,
              bodyMedium: textStyle,
              bodySmall: textStyle,
              labelLarge: textStyle,
              labelMedium: textStyle,
              labelSmall: textStyle,
            ),
      tabBarTheme:
          fontWeight == null ? null : TabBarThemeData(labelStyle: textStyle),
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: isDynamic ? null : colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
          fontWeight: fontWeight,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        surfaceTintColor: isDynamic ? colorScheme.onSurfaceVariant : null,
      ),
      snackBarTheme: SnackBarThemeData(
        actionTextColor: colorScheme.primary,
        backgroundColor: colorScheme.secondaryContainer,
        closeIconColor: colorScheme.secondary,
        contentTextStyle: TextStyle(color: colorScheme.secondary),
        elevation: 20,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(
            allowEnterRouteSnapshotting: false,
          ),
        },
      ),
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: isDynamic ? colorScheme.onSurfaceVariant : null,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        surfaceTintColor: isDynamic
            ? colorScheme.onSurfaceVariant
            : isDark
                ? colorScheme.onSurfaceVariant
                : null,
        shadowColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        // ignore: deprecated_member_use
        year2023: false,
        refreshBackgroundColor: colorScheme.onSecondary,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: colorScheme.onSurface,
          fontWeight: fontWeight,
        ),
        backgroundColor: colorScheme.surface,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
      ),
      // ignore: deprecated_member_use
      sliderTheme: const SliderThemeData(year2023: false),
    );
    if (isDark && GStorage.isPureBlackTheme) {
      themeData = darkenTheme(themeData);
    }
    if (isDark && GStorage.darkVideoPage) {
      MyApp.darkThemeData = themeData;
    }
    return themeData;
  }

  static ThemeData darkenTheme(ThemeData themeData) {
    Color color = themeData.colorScheme.surfaceContainerHighest.darken(0.7);
    return themeData.copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: themeData.appBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      cardTheme: themeData.cardTheme.copyWith(
        color: Colors.black,
      ),
      dialogTheme: themeData.dialogTheme.copyWith(
        backgroundColor: color,
      ),
      bottomSheetTheme:
          themeData.bottomSheetTheme.copyWith(backgroundColor: color),
      bottomNavigationBarTheme:
          themeData.bottomNavigationBarTheme.copyWith(backgroundColor: color),
      navigationBarTheme:
          themeData.navigationBarTheme.copyWith(backgroundColor: color),
      navigationRailTheme:
          themeData.navigationRailTheme.copyWith(backgroundColor: Colors.black),
      colorScheme: themeData.colorScheme.copyWith(
        primary: themeData.colorScheme.primary.darken(0.1),
        onPrimary: themeData.colorScheme.onPrimary.darken(0.1),
        primaryContainer: themeData.colorScheme.primaryContainer.darken(0.1),
        onPrimaryContainer:
            themeData.colorScheme.onPrimaryContainer.darken(0.1),
        inversePrimary: themeData.colorScheme.inversePrimary.darken(0.1),
        secondary: themeData.colorScheme.secondary.darken(0.1),
        onSecondary: themeData.colorScheme.onSecondary.darken(0.1),
        secondaryContainer:
            themeData.colorScheme.secondaryContainer.darken(0.1),
        onSecondaryContainer:
            themeData.colorScheme.onSecondaryContainer.darken(0.1),
        error: themeData.colorScheme.error.darken(0.1),
        surface: Colors.black,
        onSurface: themeData.colorScheme.onSurface.darken(0.15),
        surfaceTint: themeData.colorScheme.surfaceTint.darken(),
        inverseSurface: themeData.colorScheme.inverseSurface.darken(),
        onInverseSurface: themeData.colorScheme.onInverseSurface.darken(),
        surfaceContainer: themeData.colorScheme.surfaceContainer.darken(),
        surfaceContainerHigh:
            themeData.colorScheme.surfaceContainerHigh.darken(),
        surfaceContainerHighest:
            themeData.colorScheme.surfaceContainerHighest.darken(0.4),
      ),
    );
  }
}
