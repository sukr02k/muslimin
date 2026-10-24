enum PrayerMethod { kemenag, muslimWorldLeague, egyptian, karachi, ummAlQura }

enum PrayerMadhab { shafi, hanafi }

extension PrayerMethodX on PrayerMethod {
  String get labelId => switch (this) {
        PrayerMethod.kemenag => 'Kemenag (20°/18°)',
        PrayerMethod.muslimWorldLeague => 'Muslim World League',
        PrayerMethod.egyptian => 'Mesir',
        PrayerMethod.karachi => 'Karachi',
        PrayerMethod.ummAlQura => 'Umm al-Qura',
      };
}

extension PrayerMadhabX on PrayerMadhab {
  String get labelId => switch (this) {
        PrayerMadhab.shafi => "Syafi'i",
        PrayerMadhab.hanafi => 'Hanafi',
      };
}

class PrayerSettings {
  const PrayerSettings({
    this.method = PrayerMethod.kemenag,
    this.madhab = PrayerMadhab.shafi,
  });

  final PrayerMethod method;
  final PrayerMadhab madhab;

  PrayerSettings copyWith({PrayerMethod? method, PrayerMadhab? madhab}) {
    return PrayerSettings(
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
    );
  }
}