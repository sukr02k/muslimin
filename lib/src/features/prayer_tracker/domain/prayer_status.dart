/// Status sholat yang ditandai user.
enum PrayerStatus { done, missed, qada }

extension PrayerStatusX on PrayerStatus {
  String get labelId => switch (this) {
        PrayerStatus.done => 'Dikerjakan',
        PrayerStatus.missed => 'Terlewat',
        PrayerStatus.qada => 'Qada',
      };

  String get chipLabel => switch (this) {
        PrayerStatus.done => 'Sudah',
        PrayerStatus.missed => 'Terlewat',
        PrayerStatus.qada => 'Qada',
      };
}