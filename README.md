# Muslimin

Aplikasi utilitas ibadah harian berbasis Android yang dibangun dengan Flutter. Dirancang 100% offline, mengutamakan privasi pengguna, dan bebas iklan.

---

## Fitur Utama

- **Jadwal Sholat & Waktu Matahari**
  - Perhitungan waktu sholat fardhu (Subuh, Dzuhur, Ashar, Maghrib, Isya) berdasarkan algoritma astronomi posisi matahari (`adhan`).
  - Standar hisab Kementerian Agama RI (Subuh 20°, Isya 18°) dengan opsi metode internasional (Muslim World League, Mesir, Umm al-Qura, Karachi).
  - Pilihan mazhab penentuan waktu Ashar (Syafi'i/Hanbali/Maliki 1x bayangan vs Hanafi 2x bayangan).
  - Informasi waktu Imsak (10 menit sebelum Subuh), Terbit (Syuruq), dan Dhuha.
  - Kartu suasana waktu sholat dinamis dan kutipan mutiara harian yang berganti otomatis setiap hari.
  - Deteksi nama kota/wilayah otomatis dari koordinat GPS dengan fallback pencarian kota terdekat secara offline.

- **Tracker Sholat Harian**
  - Pencatatan pelaksanaan sholat fardhu 5 waktu dengan status biner sederhana (*Sudah / Lewat*).
  - Strip kalender mingguan interaktif untuk berpindah tanggal secara instan dengan indikator penyelesaian di bawah tanggal.
  - Penghitung streak harian dan rasio kepatuhan 7 hari terakhir.
  - Haptic feedback motor getar saat menandai status sholat.
  - Data tersimpan lokal di SQLite via Drift.

- **Al-Qur'an Digital**
  - Teks lengkap 114 surah (6.236 ayat) bersumber dari Tanzil & Kemenag RI, dibundel lokal di dalam aset aplikasi (tanpa request jaringan).
  - Tipografi mushaf klasik menggunakan font resmi **Amiri** (Regular & Bold) lengkap dengan simbol nomor ayat khas mushaf Madinah (`۝`).
  - Pencarian surah cepat berdasarkan nama latin, nomor urut, atau aksara Arab.
  - Pengatur ukuran huruf Arab real-time (20–38 pt) dengan penyimpanan preferensi lokal.
  - Fitur bookmark ayat dan penanda bacaan terakhir (*Reading Progress*).
  - Fitur salin ayat dan terjemahan ke clipboard.

- **Arah Kiblat (Kompas Interaktif)**
  - Perhitungan Great Circle Bearing dari koordinat perangkat ke Ka'bah (Makkah).
  - Kompas visual real-time terhubung ke sensor magnetometer perangkat.
  - Haptic feedback saat ponsel berada tepat searah dengan Ka'bah (toleransi ±3.5°).
  - Petunjuk kalibrasi kompas angka delapan (∞).

- **Tasbih Digital & Doa Harian**
  - Tombol tasbih digital dengan animasi spring tactile dan getaran motor fisik di setiap ketukan.
  - Pola getaran ganda saat putaran dzikir mencapai target (33x atau 100x).
  - Koleksi doa sehari-hari lengkap dengan teks Arab, transliterasi latin, terjemahan, dan rujukan sumber hadits/Al-Qur'an.
  - Tombol salin doa ke clipboard.

- **Pengingat Adhan Otomatis**
  - Penjadwalan alarm persis via `AlarmManager` Android (`RTC_WAKEUP`) tanpa backend.
  - Opsi audio adhan lokal (`res/raw/adhan.ogg`).
  - Pengaturan per-sholat dan waktu pengingat fleksibel (Tepat Waktu, 5, 10, 15, atau 30 menit sebelumnya).

- **OLED Dark Mode & Desain Terpusat**
  - Desain terinspirasi Shadcn (Slate + Emerald).
  - Mode Gelap OLED murni (`#09090B`) yang ramah mata di malam hari dan hemat baterai layar AMOLED.
  - Pilihan tema: Ikuti Sistem, Mode Terang, atau OLED Gelap.

---

## Arsitektur & Teknologi

Aplikasi ini menggunakan arsitektur **Feature-First / Vertical Slice**:

```text
lib/src/
  ├── app/                  # Entry app, theme loader, navigation shell
  ├── core/                 # Shared database (Drift), theme tokens, providers, utils
  └── features/
      ├── prayer_times/     # Jadwal sholat, kalkulator hisab, lokasi
      ├── prayer_tracker/   # Pencatatan sholat, streak, statistik
      ├── quran_reader/     # Pembaca Al-Qur'an, bookmark, aset 114 surah
      ├── qibla_finder/     # Kompas kiblat, bearing calculator
      ├── adhan_reminder/   # Notifikasi lokal Android, scheduler
      └── dhikr_tasbih/     # Tasbih digital tactile, doa harian
```

- **Framework**: Flutter (Dart 3)
- **Target Platform**: Android (Minimum SDK 24 / Android 7.0+)
- **State Management**: Flutter Riverpod
- **Local Persistence**: Drift (SQLite) & SharedPreferences
- **Astronomical Engine**: `adhan` (Dart)
- **Sensors & Hardware**: `geolocator`, `geocoding`, `flutter_compass`, `vibration`
- **Notifications**: `flutter_local_notifications`, `timezone`

---

## Cara Menjalankan Proyek

### Prasyarat
- Flutter SDK (stable channel, Dart >= 3.3)
- Android SDK (API level 34/35)

### Menjalankan Mode Debug
```bash
# Ambil dependensi
flutter pub get

# Jalankan di perangkat Android yang terhubung
flutter run
```

### Menjalankan Pengujian Otomatis
```bash
# Analisis statis linter
flutter analyze

# Jalankan seluruh unit test
flutter test
```

### Membangun File APK Release
```bash
# Build fat APK universal
flutter build apk --release

# Atau build split ABI (misal arm64-v8a untuk ukuran lebih ramping)
flutter build apk --split-per-abi
```

Hasil file APK tersimpan di `build/app/outputs/flutter-apk/`.

---

## Lisensi & Kredensial Data

- **Teks Al-Qur'an Uthmani**: Tanzil Project.
- **Terjemahan Bahasa Indonesia**: Kementerian Agama Republik Indonesia (Kemenag RI).
- **Font Kaligrafi Arab**: [Amiri Font](https://github.com/aliftype/amiri) (Open Font License).
- **Perhitungan Waktu Sholat**: Formula algoritma hisab posisi matahari astronomis (`adhan` library).
