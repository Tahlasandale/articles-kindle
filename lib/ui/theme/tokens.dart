import 'package:flutter/material.dart';

/// Jetons du design system. Aucune couleur, aucun rayon et aucune bordure ne
/// s'écrit en dur dans un écran : tout passe par ici.
///
/// L'app imite un écran e-ink : noir et blanc, liserés nets, coins droits,
/// aucune ombre portée.
class Eink {
  Eink._();

  // --- Couleurs, mode clair -------------------------------------------------
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF000000);
  static const Color inkSecondary = Color(0xFF555555);
  static const Color border = Color(0xFF000000);

  // --- Couleurs, mode sombre ------------------------------------------------
  // L'inversion est stricte : le mode sombre est le mode clair à l'encre
  // négative, pas une troisième palette.
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF0A0A0A);
  static const Color darkInk = Color(0xFFF2F2F2);
  static const Color darkInkSecondary = Color(0xFF9A9A9A);
  static const Color darkBorder = Color(0xFFF2F2F2);

  // --- Liserés -------------------------------------------------------------
  static const double borderWidth = 1;
  static const double borderWidthStrong = 2;

  // --- Rayons --------------------------------------------------------------
  /// Les cartes ont des coins droits ; seuls les boutons et les champs de saisie
  /// en ont, parce qu'ils sont(::pressed) et pas des surfaces de lecture.
  static const double radius = 0;
  static const double radiusControl = 4;

  // --- Espacement, échelle de 4 --------------------------------------------
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space6 = 24;
  static const double space8 = 32;

  // --- Typographie ---------------------------------------------------------
  static const String fontFamily = 'Libron';

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.3,
  );

  /// Fabrique la feuille de style pour une luminosité donnée.
  static ThemeData themeFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? darkInk : ink,
      onPrimary: isDark ? darkBackground : background,
      secondary: isDark ? darkInk : ink,
      onSecondary: isDark ? darkBackground : background,
      error: isDark ? darkInk : ink,
      onError: isDark ? darkBackground : background,
      surface: isDark ? darkBackground : background,
      onSurface: isDark ? darkInk : ink,
      surfaceContainerHighest: isDark ? darkSurface : surface,
      onSurfaceVariant: isDark ? darkInkSecondary : inkSecondary,
      outline: isDark ? darkBorder : border,
      outlineVariant: isDark ? darkBorder : border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkRipple.splashFactory,
      textTheme: TextTheme(
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyMedium: body,
        bodySmall: bodySmall,
        labelLarge: label,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: titleLarge.copyWith(color: scheme.onSurface),
        shape: Border(
          bottom: BorderSide(
            width: borderWidthStrong,
            color: isDark ? darkBorder : border,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
            width: borderWidth,
            color: isDark ? darkBorder : border,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? darkBorder : border,
        thickness: borderWidth,
        space: borderWidth,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: body.copyWith(color: scheme.onSurface),
        subtitleTextStyle: bodySmall.copyWith(color: scheme.onSurfaceVariant),
        iconColor: scheme.onSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space3,
          vertical: space3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(
            width: borderWidth,
            color: isDark ? darkBorder : border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(
            width: borderWidth,
            color: isDark ? darkBorder : border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(
            width: borderWidthStrong,
            color: isDark ? darkInk : ink,
          ),
        ),
        labelStyle: bodySmall.copyWith(color: scheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusControl),
            side: BorderSide(
              width: borderWidth,
              color: isDark ? darkBorder : border,
            ),
          ),
          textStyle: label,
          padding: const EdgeInsets.symmetric(
            horizontal: space4,
            vertical: space3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(
            width: borderWidth,
            color: isDark ? darkBorder : border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusControl),
          ),
          textStyle: label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          textStyle: label,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: BorderSide(
            width: borderWidthStrong,
            color: isDark ? darkBorder : border,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(
          width: borderWidthStrong,
          color: isDark ? darkInk : ink,
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? (isDark ? darkInk : ink)
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(
          isDark ? darkBackground : background,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        side: BorderSide(
          width: borderWidth,
          color: isDark ? darkBorder : border,
        ),
        labelStyle: bodySmall.copyWith(color: scheme.onSurface),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.onSurface,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: label,
        unselectedLabelStyle: label,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.onSurface,
        contentTextStyle: body.copyWith(color: scheme.surface),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: titleMedium.copyWith(color: scheme.onSurface),
        contentTextStyle: body.copyWith(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            width: borderWidthStrong,
            color: isDark ? darkBorder : border,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surface,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            width: borderWidthStrong,
            color: isDark ? darkBorder : border,
          ),
        ),
      ),
    );
  }
}
