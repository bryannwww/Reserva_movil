import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static const String displayFont = 'CormorantGaramond';
  static const String bodyFont = 'Manrope';

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: AppColors.black,
      secondary: AppColors.goldLight,
      onSecondary: AppColors.black,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.black,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      fontFamily: bodyFont,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      primaryTextTheme: _textTheme(base.primaryTextTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: displayFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: AppColors.gold,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D0D0D),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          letterSpacing: 0.6,
        ),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textSecondary,
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.gold),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger),
        errorStyle: const TextStyle(
          color: AppColors.danger,
          fontSize: 12,
          height: 1.4,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.black,
          disabledBackgroundColor: AppColors.surfaceSecondary,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.black,
          elevation: 0,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.border),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldLight,
          textStyle: const TextStyle(
            fontFamily: bodyFont,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          minimumSize: const Size(44, 44),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.gold,
        disabledColor: AppColors.surface,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.black,
          fontFamily: bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        side: const BorderSide(color: AppColors.borderSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        showCheckmark: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: bodyFont,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.border),
        ),
        elevation: 0,
        insetPadding: const EdgeInsets.all(18),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: displayFont,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: bodyFont,
          fontSize: 14.5,
          height: 1.55,
          color: AppColors.textSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.border,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.surfaceSecondary,
        circularTrackColor: AppColors.surfaceSecondary,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.surface,
        headerForegroundColor: AppColors.textPrimary,
        weekdayStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        dayStyle: const TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        todayBorder: const BorderSide(color: AppColors.gold),
        dayOverlayColor: WidgetStatePropertyAll(
          AppColors.gold.withValues(alpha: 0.12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surfaceElevated,
        hourMinuteColor: AppColors.surfaceSecondary,
        hourMinuteTextColor: AppColors.textPrimary,
        dialBackgroundColor: AppColors.surface,
        dialHandColor: AppColors.gold,
        dialTextColor: AppColors.textSecondary,
        entryModeIconColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          AppColors.textMuted.withValues(alpha: 0.5),
        ),
        radius: const Radius.circular(4),
        thickness: const WidgetStatePropertyAll(5),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontFamily: bodyFont,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.gold,
        selectionColor: Color(0x33C9A861),
        selectionHandleColor: AppColors.gold,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: color),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: const TextStyle(
        fontFamily: displayFont,
        fontSize: 58,
        height: 1.04,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: AppColors.textPrimary,
      ),
      displayMedium: const TextStyle(
        fontFamily: displayFont,
        fontSize: 48,
        height: 1.06,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      ),
      displaySmall: const TextStyle(
        fontFamily: displayFont,
        fontSize: 38,
        height: 1.08,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineLarge: const TextStyle(
        fontFamily: displayFont,
        fontSize: 32,
        height: 1.14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: const TextStyle(
        fontFamily: displayFont,
        fontSize: 28,
        height: 1.18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: const TextStyle(
        fontFamily: displayFont,
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 19,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        height: 1.65,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 14.5,
        height: 1.6,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodySmall: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 12.5,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
      labelLarge: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textPrimary,
      ),
      labelMedium: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.3,
        color: AppColors.textSecondary,
      ),
      labelSmall: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 10,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: AppColors.gold,
      ),
    );
  }
}
