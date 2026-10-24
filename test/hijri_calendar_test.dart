import 'package:flutter_test/flutter_test.dart';
import 'package:muslimin/src/core/calendar/hijri_calendar.dart';

void main() {
  group('HijriCalendar', () {
    test('Format Hijriah menghasilkan format yang valid', () {
      final formatted = HijriCalendar.formatHijri(DateTime(2026, 10, 24));
      expect(formatted, contains('H'));
      expect(formatted, contains(RegExp(r'\d{4}')));
    });

    test('Bulan Hijriah berada di rentang 1..12 dan hari 1..30', () {
      final sampleDates = [
        DateTime(2026, 1, 1),
        DateTime(2026, 3, 15),
        DateTime(2026, 10, 24),
        DateTime(2026, 12, 31),
      ];

      for (final date in sampleDates) {
        final h = HijriCalendar.fromGregorian(date);
        expect(h.month, inInclusiveRange(1, 12));
        expect(h.day, inInclusiveRange(1, 30));
        expect(h.year, greaterThan(1440));
      }
    });

    test('Bulan Ramadhan terdeteksi pada daftar nama bulan', () {
      expect(HijriCalendar.monthNamesId[8], 'Ramadhan');
    });
  });
}