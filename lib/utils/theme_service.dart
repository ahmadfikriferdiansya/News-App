import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeService {
  ThemeService._();

  /// ValueNotifier global untuk theme mode.
  /// - Default: ThemeMode.system (ikut sistem)
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Toggle antara light dan dark.
  static void toggle() {
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  /// ⭐ Set mode langsung (untuk pengaturan tema di Profile).
  /// - `ThemeMode.light`  → Terang
  /// - `ThemeMode.dark`   → Gelap
  /// - `ThemeMode.system` → Ikut sistem
  static void setMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  /// Cek apakah dark mode aktif.
  static bool get isDark => themeMode.value == ThemeMode.dark;
}