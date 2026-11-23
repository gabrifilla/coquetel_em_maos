import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Paleta "noite de festa": fundo roxo-noite e acentos neon de bar.
abstract final class Party {
  static const night = Color(0xFF150D28);
  static const nightHigh = Color(0xFF1F1538);
  static const surface = Color(0xFF261A45);
  static const surfaceHigh = Color(0xFF33245A);
  static const outline = Color(0xFF4A3A78);

  static const pink = Color(0xFFFF5C8A); // drink de frutas vermelhas
  static const lime = Color(0xFFC6F35C); // limão
  static const citrus = Color(0xFFFFC94A); // laranja/maracujá
  static const lagoon = Color(0xFF3DDCDB); // curaçau
  static const grape = Color(0xFF9B6BFF);

  static const text = Color(0xFFF7F1FF);
  static const textMuted = Color(0xFFB9ACD9);

  static const displayFont = 'Fredoka';
  static const logoFont = 'Pacifico';

  /// Brilho rosa→roxo do topo das telas.
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B1A5E), Color(0xFF6B1E5C), Color(0xFF2A1450)],
  );

  static ThemeData theme() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: pink,
      onPrimary: Color(0xFF2B0614),
      primaryContainer: Color(0xFF5C1A3A),
      onPrimaryContainer: Color(0xFFFFD9E3),
      secondary: lime,
      onSecondary: Color(0xFF1C2600),
      secondaryContainer: Color(0xFF3A4A10),
      onSecondaryContainer: Color(0xFFE6FFB0),
      tertiary: citrus,
      onTertiary: Color(0xFF2E2000),
      tertiaryContainer: Color(0xFF4D3A0A),
      onTertiaryContainer: Color(0xFFFFE9B3),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF3B0A06),
      errorContainer: Color(0xFF5C1712),
      onErrorContainer: Color(0xFFFFDAD5),
      surface: night,
      onSurface: text,
      onSurfaceVariant: textMuted,
      surfaceContainerLowest: Color(0xFF100A1F),
      surfaceContainerLow: nightHigh,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: Color(0xFF3D2D66),
      outline: outline,
      outlineVariant: Color(0xFF3A2C60),
      inverseSurface: text,
      onInverseSurface: night,
      inversePrimary: Color(0xFFB0285A),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: displayFont,
    );
    final textTheme = base.textTheme
        .apply(bodyColor: text, displayColor: text)
        .copyWith(
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleSmall: base.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
    final pill = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    );

    return base.copyWith(
      scaffoldBackgroundColor: night,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: night,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        // Ícones claros na barra de status (inclusive no iPhone).
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: displayFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: lime,
        disabledColor: surface,
        // Texto escuro quando o chip está marcado (fundo limão), claro quando não.
        labelStyle: TextStyle(
          fontFamily: displayFont,
          fontWeight: FontWeight.w500,
          color: WidgetStateColor.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? const Color(0xFF1C2600)
                : text,
          ),
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: displayFont,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C2600),
        ),
        checkmarkColor: const Color(0xFF1C2600),
        side: WidgetStateBorderSide.resolveWith(
          (s) => BorderSide(
            color: s.contains(WidgetState.selected) ? lime : outline,
          ),
        ),
        shape: pill,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: const WidgetStatePropertyAll(surface),
        elevation: const WidgetStatePropertyAll(0),
        hintStyle: const WidgetStatePropertyAll(
          TextStyle(color: textMuted, fontFamily: displayFont),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(color: text, fontFamily: displayFont),
        ),
        side: const WidgetStatePropertyAll(BorderSide(color: outline)),
        shape: WidgetStatePropertyAll(pill),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: pill,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: displayFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: const BorderSide(color: outline, width: 1.5),
          shape: pill,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: displayFont,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: pink,
        foregroundColor: Color(0xFF2B0614),
        shape: StadiumBorder(),
        extendedTextStyle: TextStyle(
          fontFamily: displayFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: nightHigh,
        surfaceTintColor: Colors.transparent,
        indicatorColor: pink.withValues(alpha: 0.22),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? pink : textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: displayFont,
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? text : textMuted,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceHigh,
        contentTextStyle: TextStyle(
          fontFamily: displayFont,
          color: text,
          fontSize: 15,
        ),
        shape: StadiumBorder(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: textMuted),
        hintStyle: TextStyle(color: textMuted),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: outline),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? lime : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Color(0xFF1C2600)),
        side: const BorderSide(color: textMuted, width: 1.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: nightHigh),
      dividerTheme: const DividerThemeData(color: outline),
    );
  }
}
