// lib/core/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

// State provider untuk theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Provider untuk mendapatkan AppThemeExtension saat ini
final appThemeProvider = Provider<AppThemeExtension>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  
  if (themeMode == ThemeMode.light) {
    return AppThemeExtension.light;
  } else if (themeMode == ThemeMode.dark) {
    return AppThemeExtension.dark;
  } else {
    // system
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    return brightness == Brightness.dark 
        ? AppThemeExtension.dark 
        : AppThemeExtension.light;
  }
});

// 🔥 PERBAIKAN: Menggunakan StateProvider untuk toggle (bukan Provider<void>)
final isDarkModeProvider = StateProvider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  if (themeMode == ThemeMode.light) {
    return false;
  } else if (themeMode == ThemeMode.dark) {
    return true;
  } else {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    return brightness == Brightness.dark;
  }
});

// Function untuk toggle theme (bisa dipanggil dari mana saja)
void toggleTheme(WidgetRef ref) {
  final currentMode = ref.read(themeModeProvider);
  if (currentMode == ThemeMode.light) {
    ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
  } else if (currentMode == ThemeMode.dark) {
    ref.read(themeModeProvider.notifier).state = ThemeMode.light;
  } else {
    // system -> cek brightness saat ini
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    if (brightness == Brightness.dark) {
      ref.read(themeModeProvider.notifier).state = ThemeMode.light;
    } else {
      ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
    }
  }
}

// Widget untuk toggle button
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    
    IconData icon;
    String tooltip;
    
    if (themeMode == ThemeMode.light) {
      icon = Icons.dark_mode;
      tooltip = 'Switch to Dark Mode';
    } else if (themeMode == ThemeMode.dark) {
      icon = Icons.light_mode;
      tooltip = 'Switch to Light Mode';
    } else {
      // system
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      icon = brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode;
      tooltip = 'Switch to ${brightness == Brightness.dark ? 'Light' : 'Dark'} Mode';
    }
    
    return IconButton(
      icon: Icon(icon, color: theme.textPrimary),
      tooltip: tooltip,
      onPressed: () {
        toggleTheme(ref);
      },
    );
  }
}