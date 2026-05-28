// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ==================== LIGHT THEME ====================
class LightThemeColors {
  static const Color background = Color(0xFFF8F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1A3A5F);
  static const Color primaryLight = Color(0xFF2A5A8F);
  static const Color primaryDark = Color(0xFF0F2A44);
  static const Color secondary = Color(0xFF2E7D32);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color danger = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);
  static const Color purple = Color(0xFF5E35B1);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  
  static const List<Color> chartColors = [
    Color(0xFF1A3A5F), Color(0xFF2E7D32), Color(0xFFED6C02),
    Color(0xFFD32F2F), Color(0xFF5E35B1), Color(0xFF0288D1),
  ];
  
  static const List<List<Color>> kpiGradients = [
    [Color(0xFF1A3A5F), Color(0xFF2A5A8F)],
    [Color(0xFF2E7D32), Color(0xFF43A047)],
    [Color(0xFFED6C02), Color(0xFFFF8F00)],
    [Color(0xFFD32F2F), Color(0xFFEF5350)],
    [Color(0xFF5E35B1), Color(0xFF7E57C2)],
    [Color(0xFF0288D1), Color(0xFF29B6F6)],
  ];
  
  static Color get glassBackground => Colors.white.withValues(alpha: 0.85);
  static Color get glassBorder => Colors.white.withValues(alpha: 0.95);
  static Color get glassShadow => const Color(0xFF1A3A5F).withValues(alpha: 0.08);
}

// ==================== DARK THEME ====================
class DarkThemeColors {
  static const Color backgroundStart = Color(0xFF0A0F1A);
  static const Color backgroundEnd = Color(0xFF121826);
  static const Color surface = Color(0xFF1A1F2E);
  static const Color cardBg = Color(0xFF1E2436);
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF10B981);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF6B7280);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color border = Color(0xFF374151);
  static const Color borderLight = Color(0xFF2D3748);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color lightGreyColor = Color(0xFF2D3748);
  
  static const List<Color> chartColors = [
    Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFF06B6D4),
  ];
  
  static const List<List<Color>> kpiGradients = [
    [Color(0xFF1E3A5F), Color(0xFF2E4A6F)],
    [Color(0xFF1E5F3A), Color(0xFF2E7F4A)],
    [Color(0xFF5F3A1E), Color(0xFF7F5A2E)],
    [Color(0xFF5F1E1E), Color(0xFF7F2E2E)],
    [Color(0xFF3A1E5F), Color(0xFF5A2E7F)],
    [Color(0xFF1E5F5F), Color(0xFF2E7F7F)],
  ];
  
  static Color get glassBackground => const Color(0xFF1A1F2E).withValues(alpha: 0.85);
  static Color get glassBorder => const Color(0xFF2D3748).withValues(alpha: 0.95);
  static Color get glassShadow => const Color(0xFF000000).withValues(alpha: 0.3);
}

// ==================== THEME EXTENSION ====================
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primary;
  final Color secondary;
  final Color warning;
  final Color danger;
  final Color info;
  final Color purple;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color cardBg;
  final Color glassBackground;
  final Color glassBorder;
  final Color glassShadow;
  final List<Color> chartColors;
  final List<List<Color>> kpiGradients;
  final bool isDark;
  
  AppThemeExtension({
    required this.primary,
    required this.secondary,
    required this.warning,
    required this.danger,
    required this.info,
    required this.purple,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.cardBg,
    required this.glassBackground,
    required this.glassBorder,
    required this.glassShadow,
    required this.chartColors,
    required this.kpiGradients,
    required this.isDark,
  });
  
  static AppThemeExtension light = AppThemeExtension(
    primary: LightThemeColors.primary,
    secondary: LightThemeColors.secondary,
    warning: LightThemeColors.warning,
    danger: LightThemeColors.danger,
    info: LightThemeColors.info,
    purple: LightThemeColors.purple,
    textPrimary: LightThemeColors.textPrimary,
    textSecondary: LightThemeColors.textSecondary,
    textHint: LightThemeColors.textHint,
    border: LightThemeColors.border,
    cardBg: LightThemeColors.cardBg,
    glassBackground: LightThemeColors.glassBackground,
    glassBorder: LightThemeColors.glassBorder,
    glassShadow: LightThemeColors.glassShadow,
    chartColors: LightThemeColors.chartColors,
    kpiGradients: LightThemeColors.kpiGradients,
    isDark: false,
  );
  
  static AppThemeExtension dark = AppThemeExtension(
    primary: DarkThemeColors.primary,
    secondary: DarkThemeColors.secondary,
    warning: DarkThemeColors.warning,
    danger: DarkThemeColors.danger,
    info: DarkThemeColors.info,
    purple: DarkThemeColors.purple,
    textPrimary: DarkThemeColors.textPrimary,
    textSecondary: DarkThemeColors.textSecondary,
    textHint: DarkThemeColors.textHint,
    border: DarkThemeColors.border,
    cardBg: DarkThemeColors.cardBg,
    glassBackground: DarkThemeColors.glassBackground,
    glassBorder: DarkThemeColors.glassBorder,
    glassShadow: DarkThemeColors.glassShadow,
    chartColors: DarkThemeColors.chartColors,
    kpiGradients: DarkThemeColors.kpiGradients,
    isDark: true,
  );
  
  @override
  ThemeExtension<AppThemeExtension> copyWith() => this;
  @override
  ThemeExtension<AppThemeExtension> lerp(covariant ThemeExtension<AppThemeExtension>? other, double t) => this;
}

// ==================== DIMENSIONS ====================
class AppDimens {
  static const double fontSizeXXL = 28;
  static const double fontSizeXL = 22;
  static const double fontSizeLG = 18;
  static const double fontSizeMD = 14;
  static const double fontSizeSM = 12;
  static const double fontSizeXS = 10;
  static const double fontSizeXXS = 8;
  static const double spacingXXS = 2;
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 12;
  static const double spacingLG = 16;
  static const double spacingXL = 20;
  static const double spacingXXL = 24;
  static const double spacingXXXL = 32;
  static const double radiusSM = 6;
  static const double radiusMD = 8;
  static const double radiusLG = 12;
  static const double radiusXL = 16;
  static const double radiusXXL = 20;
  static const double radiusCircle = 100;
}

// ==================== TEXT STYLES ====================
class AppTextStyles {
  static TextStyle headingLarge(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GoogleFonts.poppins(fontSize: AppDimens.fontSizeXXL, fontWeight: FontWeight.w700, color: theme.textPrimary, letterSpacing: -0.5);
  }
  static TextStyle headingMedium(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GoogleFonts.poppins(fontSize: AppDimens.fontSizeXL, fontWeight: FontWeight.w700, color: theme.textPrimary, letterSpacing: -0.3);
  }
  static TextStyle headingSmall(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GoogleFonts.poppins(fontSize: AppDimens.fontSizeLG, fontWeight: FontWeight.w600, color: theme.textPrimary);
  }
  static TextStyle subtitle(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GoogleFonts.poppins(fontSize: AppDimens.fontSizeSM, fontWeight: FontWeight.w400, color: theme.textSecondary);
  }
  static TextStyle bodyText(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GoogleFonts.poppins(fontSize: AppDimens.fontSizeMD, fontWeight: FontWeight.w400, color: theme.textPrimary);
  }
  static TextStyle bodySmall(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GoogleFonts.poppins(fontSize: AppDimens.fontSizeSM, fontWeight: FontWeight.w400, color: theme.textSecondary);
  }
  static TextStyle kpiValue(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GoogleFonts.poppins(fontSize: AppDimens.fontSizeLG, fontWeight: FontWeight.bold, color: theme.primary);
  }
  static TextStyle kpiLabel(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GoogleFonts.poppins(fontSize: AppDimens.fontSizeXS, fontWeight: FontWeight.w500, color: theme.textSecondary);
  }
  static TextStyle badgeText(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GoogleFonts.poppins(fontSize: AppDimens.fontSizeXXS, fontWeight: FontWeight.w600, color: theme.textPrimary);
  }
}

// ==================== GLASS CARD ====================
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;
  const GlassCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(AppDimens.spacingLG), this.borderRadius = AppDimens.radiusLG});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [theme.glassBackground, theme.glassBackground.withValues(alpha: 0.95)]),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: theme.glassBorder.withValues(alpha: 0.3), width: 1),
          boxShadow: [BoxShadow(color: theme.glassShadow, blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: child,
      ),
    );
  }
}

// ==================== KPI CARD ====================
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final int gradientIndex;
  final VoidCallback? onTap;
  final String? trend;
  final bool isIncrease;
  const KpiCard({super.key, required this.title, required this.value, required this.icon, this.gradientIndex = 0, this.onTap, this.trend, this.isIncrease = true});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    final colors = theme.kpiGradients[gradientIndex % theme.kpiGradients.length];
    final primaryColor = colors[0];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.spacingLG),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primaryColor.withValues(alpha: 0.12), primaryColor.withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(AppDimens.radiusLG),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: theme.glassShadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(padding: const EdgeInsets.all(AppDimens.spacingSM), decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppDimens.radiusMD)), child: Icon(icon, color: primaryColor, size: 20)),
                if (trend != null) Container(padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSM, vertical: AppDimens.spacingXXS), decoration: BoxDecoration(color: (isIncrease ? theme.secondary : theme.danger).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppDimens.radiusSM)), child: Row(children: [Icon(isIncrease ? Icons.trending_up : Icons.trending_down, size: 10, color: isIncrease ? theme.secondary : theme.danger), const SizedBox(width: 2), Text(trend!, style: AppTextStyles.badgeText(context).copyWith(color: isIncrease ? theme.secondary : theme.danger, fontSize: 8))])),
              ],
            ),
            const SizedBox(height: AppDimens.spacingMD),
            Text(title, style: AppTextStyles.kpiLabel(context)),
            const SizedBox(height: AppDimens.spacingXS),
            Text(value, style: AppTextStyles.kpiValue(context).copyWith(color: primaryColor)),
          ],
        ),
      ),
    );
  }
}

// ==================== STAT BOX ====================
class StatBox extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const StatBox({super.key, required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingSM),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppDimens.radiusMD)),
        child: Column(children: [Text(value.toString(), style: GoogleFonts.poppins(fontSize: AppDimens.fontSizeLG, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 2), Text(label, style: AppTextStyles.kpiLabel(context))]),
      ),
    );
  }
}

// ==================== APP BADGE (TIDAK KONFLIK DENGAN FLUTTER) ====================
class AppBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const AppBadge({super.key, required this.text, required this.color, this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSM, vertical: AppDimens.spacingXXS),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppDimens.radiusSM)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 10, color: color), const SizedBox(width: 2)],
          Text(text, style: AppTextStyles.badgeText(context).copyWith(color: color)),
        ],
      ),
    );
  }
}

// ==================== MATERIAL THEMES ====================
ThemeData getLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: LightThemeColors.primary,
    scaffoldBackgroundColor: LightThemeColors.background,
    cardColor: LightThemeColors.cardBg,
    colorScheme: const ColorScheme.light(primary: LightThemeColors.primary, secondary: LightThemeColors.secondary, error: LightThemeColors.danger),
    textTheme: GoogleFonts.poppinsTextTheme(),
    extensions: [AppThemeExtension.light],
    appBarTheme: AppBarTheme(backgroundColor: LightThemeColors.background, foregroundColor: LightThemeColors.textPrimary, elevation: 0, centerTitle: false, titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: LightThemeColors.textPrimary)),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: LightThemeColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMD), borderSide: const BorderSide(color: LightThemeColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMD), borderSide: const BorderSide(color: LightThemeColors.borderLight)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMD), borderSide: const BorderSide(color: LightThemeColors.primary, width: 2))),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: DarkThemeColors.primary,
    scaffoldBackgroundColor: DarkThemeColors.backgroundStart,
    cardColor: DarkThemeColors.cardBg,
    colorScheme: const ColorScheme.dark(primary: DarkThemeColors.primary, secondary: DarkThemeColors.secondary, error: DarkThemeColors.danger),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    extensions: [AppThemeExtension.dark],
    appBarTheme: AppBarTheme(backgroundColor: DarkThemeColors.backgroundStart, foregroundColor: DarkThemeColors.textPrimary, elevation: 0, centerTitle: false, titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: DarkThemeColors.textPrimary)),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: DarkThemeColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMD), borderSide: const BorderSide(color: DarkThemeColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMD), borderSide: const BorderSide(color: DarkThemeColors.borderLight)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMD), borderSide: const BorderSide(color: DarkThemeColors.primary, width: 2))),
  );
}