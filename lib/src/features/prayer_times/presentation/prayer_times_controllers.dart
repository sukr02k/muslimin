import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/daily_prayer_times.dart';
import '../domain/geo_location.dart';
import '../domain/prayer_settings.dart';
import '../domain/prayer_times_calculator.dart';
import '../data/location_repository.dart';
import '../data/prayer_times_settings_repository.dart';

final locationRepositoryProvider =
    Provider<LocationRepository>((ref) => const LocationRepository());

final prayerTimesSettingsRepositoryProvider =
    Provider<PrayerTimesSettingsRepository>(
  (ref) => PrayerTimesSettingsRepository(ref.watch(appSettingsRepositoryProvider)),
);

final locationProvider =
    AsyncNotifierProvider<LocationNotifier, GeoLocation>(LocationNotifier.new);

class LocationNotifier extends AsyncNotifier<GeoLocation> {
  @override
  Future<GeoLocation> build() async {
    final repo = ref.watch(prayerTimesSettingsRepositoryProvider);
    return await repo.loadLocation() ??
        ref.read(locationRepositoryProvider).defaultCity;
  }

  Future<void> selectCity(GeoLocation city) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(prayerTimesSettingsRepositoryProvider);
      await repo.saveLocation(city);
      return city;
    });
  }

  Future<void> useGps() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(prayerTimesSettingsRepositoryProvider);
      final location = await ref.read(locationRepositoryProvider).currentGpsLocation();
      await repo.saveLocation(location);
      return location;
    });
  }
}

final prayerSettingsProvider =
    AsyncNotifierProvider<PrayerSettingsNotifier, PrayerSettings>(
        PrayerSettingsNotifier.new);

class PrayerSettingsNotifier extends AsyncNotifier<PrayerSettings> {
  @override
  Future<PrayerSettings> build() async {
    return ref.watch(prayerTimesSettingsRepositoryProvider).loadSettings();
  }

  Future<void> save(PrayerSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(prayerTimesSettingsRepositoryProvider);
      await repo.saveSettings(settings);
      return settings;
    });
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void previous() => state = state.subtract(const Duration(days: 1));

  void next() => state = state.add(const Duration(days: 1));

  void goToday() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, now.day);
  }
}

final dailyPrayerTimesProvider = FutureProvider<DailyPrayerTimes>((ref) async {
  final location = await ref.watch(locationProvider.future);
  final settings = await ref.watch(prayerSettingsProvider.future);
  final date = ref.watch(selectedDateProvider);
  return const PrayerTimesCalculator().forDate(location, date, settings);
});

final tomorrowPrayerTimesProvider =
    FutureProvider<DailyPrayerTimes>((ref) async {
  final location = await ref.watch(locationProvider.future);
  final settings = await ref.watch(prayerSettingsProvider.future);
  final date = ref.watch(selectedDateProvider).add(const Duration(days: 1));
  return const PrayerTimesCalculator().forDate(location, date, settings);
});