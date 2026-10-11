import 'package:flutter/material.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';

/// The app's Material theme, built from the Organic tokens so stock widgets
/// (buttons, chips, fields, sheets, the nav bar) already look like the
/// handoff and screens only add layout.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, Organic.light);

  static ThemeData dark() => _build(Brightness.dark, Organic.dark);

  static ThemeData _build(Brightness brightness, Organic o) {
    final light = brightness == Brightness.light;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: o.accent,
      onPrimary: o.onAccent,
      primaryContainer: o.accentSoft,
      onPrimaryContainer: o.onAccentSoft,
      secondary: o.sage,
      onSecondary: light ? Colors.white : OrganicPalette.sage900,
      secondaryContainer: o.sageSoft,
      onSecondaryContainer: o.onSageSoft,
      tertiary: o.accentStrong,
      onTertiary: light ? Colors.white : OrganicPalette.accent900,
      tertiaryContainer: o.accentDecor,
      onTertiaryContainer: o.onAccentSoft,
      // A warm brick red: distinct from the terracotta accent for errors and
      // destructive actions, without leaving the palette's warmth.
      error: light ? const Color(0xFFA8321F) : const Color(0xFFFFB4A1),
      onError: light ? Colors.white : const Color(0xFF5C1408),
      errorContainer: light ? const Color(0xFFFFDAD2) : const Color(0xFF7A2414),
      onErrorContainer: light
          ? const Color(0xFF3E0A02)
          : const Color(0xFFFFDAD2),
      surface: o.bg,
      onSurface: o.text,
      onSurfaceVariant: o.muted,
      surfaceDim: light ? OrganicPalette.neutral300 : const Color(0xFF181614),
      surfaceBright: light
          ? OrganicPalette.neutral100
          : const Color(0xFF3A362F),
      surfaceContainerLowest: light ? OrganicPalette.neutral100 : o.bg,
      surfaceContainerLow: light ? const Color(0xFFF0E3CE) : o.raised,
      surfaceContainer: o.surface,
      surfaceContainerHigh: light
          ? const Color(0xFFE3D3B8)
          : const Color(0xFF36322B),
      surfaceContainerHighest: light
          ? OrganicPalette.neutral300
          : OrganicPalette.neutral800,
      outline: light ? OrganicPalette.neutral500 : OrganicPalette.neutral600,
      outlineVariant: light
          ? OrganicPalette.neutral300
          : OrganicPalette.neutral800,
      shadow: OrganicPalette.neutral900,
      scrim: OrganicPalette.neutral900,
      inverseSurface: light ? OrganicPalette.neutral900 : OrganicPalette.bg,
      onInverseSurface: light ? Colors.white : OrganicPalette.text,
      inversePrimary: light
          ? OrganicPalette.accent400
          : OrganicPalette.accent600,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: OrganicFonts.body,
      fontFamilyFallback: OrganicFonts.fallback,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
    final text = _textTheme(base.textTheme, o);
    const stadium = StadiumBorder();
    const buttonText = TextStyle(
      fontFamily: OrganicFonts.body,
      fontFamilyFallback: OrganicFonts.fallback,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );
    final focusRing = BorderSide(color: o.accent, width: 2);

    return base.copyWith(
      extensions: [o],
      scaffoldBackgroundColor: o.bg,
      canvasColor: o.bg,
      dividerColor: o.divider,
      textTheme: text,
      primaryTextTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: o.bg,
        foregroundColor: o.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleSpacing: 20,
        titleTextStyle: text.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: o.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 5),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrganicRadius.card),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: o.muted,
        textColor: o.text,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodyMedium?.copyWith(color: o.muted),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrganicRadius.card),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: o.accent,
          foregroundColor: o.onAccent,
          disabledBackgroundColor: light
              ? OrganicPalette.neutral400
              : OrganicPalette.neutral700,
          disabledForegroundColor: light ? Colors.white : o.muted,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: stadium,
          textStyle: buttonText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: o.surface,
          foregroundColor: o.text,
          elevation: 0,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: stadium,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: o.accentStrong,
          side: BorderSide(color: o.accent, width: 2),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: stadium,
          textStyle: buttonText.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: o.accentStrong,
          minimumSize: const Size(48, 48),
          shape: stadium,
          textStyle: buttonText.copyWith(fontSize: 15),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: o.text,
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: o.accent,
        foregroundColor: o.onAccent,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 4,
        highlightElevation: 2,
        shape: stadium,
        extendedTextStyle: buttonText,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 22),
        extendedSizeConstraints: const BoxConstraints.tightFor(height: 56),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: o.surface,
        selectedColor: o.accent,
        disabledColor: o.surface.withValues(alpha: 0.45),
        labelStyle: text.labelLarge?.copyWith(color: o.text),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: o.onAccent),
        checkmarkColor: o.onAccent,
        iconTheme: IconThemeData(color: o.muted, size: 18),
        side: BorderSide.none,
        shape: stadium,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        // A surface pill holding the options; the chosen one fills with the
        // accent (the handoff's `.seg`). The surface-coloured border draws the
        // pill's inner padding.
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? o.accent : o.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? o.onAccent : o.text,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? o.onAccent : o.text,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: o.surface, width: 4)),
          shape: const WidgetStatePropertyAll(stadium),
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          textStyle: WidgetStatePropertyAll(
            buttonText.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: ShapeDecoration(color: o.accent, shape: stadium),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelColor: o.onAccent,
        unselectedLabelColor: o.text,
        labelStyle: buttonText.copyWith(fontSize: 14),
        unselectedLabelStyle: buttonText.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        splashBorderRadius: BorderRadius.circular(OrganicRadius.pill),
        overlayColor: WidgetStatePropertyAll(o.accent.withValues(alpha: 0.08)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: o.raised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
        labelStyle: text.bodyLarge?.copyWith(color: o.muted),
        floatingLabelStyle: text.bodyLarge?.copyWith(
          color: o.accentStrong,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: text.bodyLarge?.copyWith(color: o.muted),
        prefixIconColor: o.muted,
        suffixIconColor: o.muted,
        border: _inputBorder(o.neutralSoft),
        enabledBorder: _inputBorder(
          light ? OrganicPalette.neutral300 : OrganicPalette.neutral700,
        ),
        focusedBorder: _inputBorder(
          light ? OrganicPalette.accent500 : OrganicPalette.accent400,
        ),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error),
        disabledBorder: _inputBorder(o.divider),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: o.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 74,
        indicatorColor: o.accentSoft,
        indicatorShape: stadium,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected)
                ? (light ? OrganicPalette.accent800 : o.onAccentSoft)
                : o.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: OrganicFonts.body,
            fontFamilyFallback: OrganicFonts.fallback,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: s.contains(WidgetState.selected)
                ? (light ? OrganicPalette.accent800 : o.onAccentSoft)
                : o.muted,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: o.bg,
        modalBackgroundColor: o.bg,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: light
            ? OrganicPalette.neutral400
            : OrganicPalette.neutral600,
        dragHandleSize: const Size(44, 5),
        modalBarrierColor: OrganicPalette.text.withValues(alpha: 0.45),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OrganicRadius.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: o.bg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrganicRadius.sheet),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: o.raised,
        surfaceTintColor: Colors.transparent,
        textStyle: text.bodyLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: light ? OrganicPalette.neutral900 : OrganicPalette.bg,
        contentTextStyle: TextStyle(
          fontFamily: OrganicFonts.body,
          fontFamilyFallback: OrganicFonts.fallback,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: light ? Colors.white : OrganicPalette.text,
        ),
        actionTextColor: light
            ? OrganicPalette.accent300
            : OrganicPalette.accent700,
        shape: stadium,
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : (light ? Colors.white : OrganicPalette.neutral300),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? o.sage
              : (light ? OrganicPalette.neutral400 : OrganicPalette.neutral700),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? o.accent : null,
        ),
        checkColor: WidgetStatePropertyAll(o.onAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? o.accent : o.muted,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: o.accent,
        linearTrackColor: o.track,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 10,
        borderRadius: BorderRadius.circular(OrganicRadius.pill),
      ),
      dividerTheme: DividerThemeData(color: o.divider, space: 24),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: o.accentStrong,
        textColor: o.text,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: ShapeDecoration(
          color: light ? OrganicPalette.neutral900 : OrganicPalette.bg,
          shape: stadium,
        ),
        textStyle: TextStyle(
          fontFamily: OrganicFonts.body,
          fontFamilyFallback: OrganicFonts.fallback,
          fontSize: 13,
          color: light ? Colors.white : OrganicPalette.text,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: o.bg,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: o.accentSoft,
        headerForegroundColor: o.onAccentSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrganicRadius.sheet),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: o.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrganicRadius.sheet),
        ),
      ),
      focusColor: focusRing.color.withValues(alpha: 0.16),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(OrganicRadius.panel),
    borderSide: BorderSide(color: color, width: 2),
  );

  /// Caprasimo for display and headline sizes, Figtree for the rest; both fall
  /// back to Hind Siliguri for Bangla. Sizes follow the handoff: 40 hero
  /// figures, 28 screen titles, 24 sheet titles, 20 section titles.
  static TextTheme _textTheme(TextTheme base, Organic o) {
    TextStyle head(double size, double height) => TextStyle(
      fontFamily: OrganicFonts.heading,
      fontFamilyFallback: OrganicFonts.fallback,
      fontWeight: FontWeight.w400,
      fontSize: size,
      height: height,
      letterSpacing: -0.2,
      color: o.text,
    );
    TextStyle body(double size, FontWeight weight, {Color? color}) => TextStyle(
      fontFamily: OrganicFonts.body,
      fontFamilyFallback: OrganicFonts.fallback,
      fontWeight: weight,
      fontSize: size,
      height: 1.4,
      color: color ?? o.text,
    );
    return base.copyWith(
      displayLarge: head(48, 1.1),
      displayMedium: head(40, 1.15),
      displaySmall: head(34, 1.2),
      headlineLarge: head(30, 1.2),
      headlineMedium: head(28, 1.25),
      headlineSmall: head(24, 1.3),
      titleLarge: head(20, 1.3),
      titleMedium: body(16, FontWeight.w600),
      titleSmall: body(15, FontWeight.w600),
      bodyLarge: body(16, FontWeight.w400),
      bodyMedium: body(14, FontWeight.w400),
      bodySmall: body(13, FontWeight.w400, color: o.muted),
      labelLarge: body(14, FontWeight.w600),
      labelMedium: body(13, FontWeight.w600),
      labelSmall: body(12, FontWeight.w600),
    );
  }
}
