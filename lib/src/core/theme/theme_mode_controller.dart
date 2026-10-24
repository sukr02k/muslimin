import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Provider mode tema tampilan: Sistem, Terang (Light), atau Gelap (Dark).
final appThemeModeProvider =
    NotifierProvider<AppThemeModeNotifier, ThemeMode>(
  AppThemeModeNotifier.new,
);

class AppThemeModeNotifier extends Notifier<ThemeMode> {
  static const _storageKey = 'app_theme_mode';

  @override
  ThemeMode build() {
    final settingsRepo = ref.watch(appSettingsRepositoryProvider);
    // Muat preferensi tema tersimpan
    settingsRepo.get(_storageKey).then((val) {
      if (val != null) {
        final mode = ThemeMode.values.firstWhere(
          (m) => m.name == val,
          orElse: () => ThemeMode.system,
        );
        state = mode;
      }
    });
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final settingsRepo = ref.read(appSettingsRepositoryProvider);
    await settingsRepo.set(_storageKey, mode.name);
  }
}