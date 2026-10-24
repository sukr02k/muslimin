import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/prayer_name.dart';
import '../../../core/providers.dart';
import '../domain/prayer_status.dart';
import '../domain/prayer_tracker_summary.dart';
import '../data/prayer_tracker_repository.dart';

final prayerTrackerRepositoryProvider = Provider<PrayerTrackerRepository>(
  (ref) => PrayerTrackerRepository(ref.watch(appDatabaseProvider)),
);

final trackerDateProvider =
    NotifierProvider<TrackerDateNotifier, DateTime>(TrackerDateNotifier.new);

class TrackerDateNotifier extends Notifier<DateTime> {
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

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

final trackerStatusesProvider = AsyncNotifierProvider<TrackerStatusesNotifier,
    Map<PrayerName, PrayerStatus>>(TrackerStatusesNotifier.new);

class TrackerStatusesNotifier
    extends AsyncNotifier<Map<PrayerName, PrayerStatus>> {
  @override
  Future<Map<PrayerName, PrayerStatus>> build() {
    final date = ref.watch(trackerDateProvider);
    return ref.watch(prayerTrackerRepositoryProvider).statusesFor(date);
  }

  Future<void> set(PrayerName name, PrayerStatus status) async {
    final date = ref.read(trackerDateProvider);
    final repo = ref.read(prayerTrackerRepositoryProvider);
    await repo.setStatus(date, name, status);
    ref.invalidateSelf();
    ref.invalidate(trackerSummaryProvider);
  }

  Future<void> clear(PrayerName name) async {
    final date = ref.read(trackerDateProvider);
    final repo = ref.read(prayerTrackerRepositoryProvider);
    await repo.clearStatus(date, name);
    ref.invalidateSelf();
    ref.invalidate(trackerSummaryProvider);
  }
}

final trackerSummaryProvider = FutureProvider<PrayerTrackerSummary>((ref) async {
  final now = DateTime.now();
  return ref
      .watch(prayerTrackerRepositoryProvider)
      .summary(DateTime(now.year, now.month, now.day));
});