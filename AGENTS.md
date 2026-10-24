# AGENTS.md — Muslimin

Panduan utama untuk AI coding agent (OpenCode / Cursor / Claude Code) yang bekerja di proyek ini.
Baca sebelum mengerjakan apa pun.

---

## Detected Tech Stack

| Layer | Teknologi |
|---|---|
| Framework | Flutter (stable, Dart 3) |
| Platform | **Android saja** (min SDK 24 / Android 7.0) |
| State Management | Riverpod (`flutter_riverpod`) |
| Local Database | `drift` (SQLite, type-safe, compile-time query) |
| Lokasi | `geolocator` (GPS + izin) |
| Kompas | `flutter_compass` / `sensors_plus` |
| Kalkulasi Sholat | `adhan` (paket Dart, perhitungan astronomis offline) |
| Notifikasi | `flutter_local_notifications` + `timezone` (adhan reminder offline) |
| Kiblat | kalkulasi bearing manual (rumus baku) + kompas |
| Data Quran | asset lokal (SQLite/JSON Tanzil/Uthmani + terjemahan ID) |
| Testing | `flutter_test` + integration test |
| Linting | `flutter analyze` + `dart format` |

**Non-negotiable:** aplikasi **full offline**, data **hanya di device user**. Tidak ada backend, tidak ada akun, tidak ada HTTP call untuk fitur inti.

---

## Local Skills Mapping

Panggil skill via `skill` tool (ID) atau baca SKILL.md dari path. Gunakan skill yang relevan:

### Flutter / Dart / Arsitektur
- `dart-flutter-patterns` — `~/.config/opencode/skills/dart-flutter-patterns`
  Wajib untuk pola Flutter produksi: null safety, immutable state (Freezed), async, arsitektur widget, state management, navigasi (GoRouter + auth guard), Dio/networking, error handling, testing.
- `flutter-dart-code-review` — `~/.config/opencode/skills/flutter-dart-code-review`
  Pakai saat me-review kode Flutter/Dart sebelum commit.
- `android-clean-architecture` — `~/.config/opencode/skills/android-clean-architecture`
  Pakai untuk struktur modul/layer, dependency rule, UseCase, Repository (clean architecture).

### Pengujian & Verifikasi
- `tdd-workflow` — `~/.config/opencode/skills/tdd-workflow`
  Wajib: tulis test gagal dulu, lalu implementasi, refactor. Target coverage ≥ 80%.
- `verification-loop` — `~/.config/opencode/skills/verification-loop`
  Wajib di akhir tiap slice: build + `flutter analyze` + lint + test + review diff.

### UI / Anti-Slop (jika mengerjakan tampilan)
- `accessibility` — `~/.config/opencode/skills/accessibility`
  Target WCAG level AA: label, kontras, target sentuh, dukungan screen reader.
- `frontend-design-direction` — `~/.config/opencode/skills/frontend-design-direction`
  Saat menentukan arah desain UI.
- `anti-slop` (rule) — jaga agar tidak ada UI generik, metrik palsu, teks filler AI.

> Skill lain tersedia di `~/.config/opencode/skills/`. Cek daftar dengan `ls` bila ragu.

---

## Vibe Coding Rules (WAJIB)

### 1. No Monster Prompts
Dilarang mengimplementasikan banyak fitur sekaligus dalam satu prompt.
**Kerjakan 1 vertical slice per prompt.** Slice = fitur utuh vertikal:
UI widget + state management + repository/DB query + validasi + error handling + test.

Rujukan slice: lihat `docs/uat-checklist.md` (Slice 0–6).

### 2. Verification Loop
Setiap slice **wajib** diverifikasi SEBELUM pindah ke slice berikutnya:
1. `flutter analyze` → bersih (0 error).
2. `dart format` → format rapi.
3. `flutter test` → unit/widget test hijau.
4. Jalankan app di emulator/device → fitur slice benar-benar berfungsi (manual smoke).
5. Review diff kritis (data, logika kalkulasi, DB).

Jangan izinkan "belum dites tapi harusnya jalan".

### 3. Zero Code Slop
- Tanpa header ASCII dekoratif.
- Tanpa komentar gema (echo comments) — komentar yang menulis ulang apa yang sudah jelas dari kode.
- Tanpa stub kosong / TODO bohongan / placeholder `throw UnimplementedError()` yang ditinggal.
- Tanpa dead code, import tak terpakai, variabel tak terpakai.
- Komentar hanya menjelaskan "kenapa", bukan "apa".

### 4. Offline-First & Data Lokal
- Fitur inti dilarang memanggil jaringan. Kalau ada, itu bug.
- Semua data persisten lewat `drift` DB atau `SharedPreferences`, bukan file sembarangan / backend.

### 5. Konvensi Struktur
```
lib/
  src/
    app/                 # bootstrap, router, tema
    core/                # util, konstanta, error, kalkulasi (sholat/kiblat)
    features/
      prayer_times/      # data / domain / presentation
      prayer_tracker/
      quran_reader/
      qibla_finder/
      adhan_reminder/
test/                    # mirror struktur lib
```
Satu fitur = satu folder feature. Jangan campur logika fitur di folder core.

### 6. Konvensi Commit
Conventional Commits: `feat:`, `fix:`, `refactor:`, `test:`, `chore:` — bahasa Indonesia/Inggris konsisten, spesifik ke slice.

---

## Definisi Selesai (Done)

Sebuah slice dianggap selesai hanya bila:
- [ ] Acceptance criteria di `docs/uat-checklist.md` terpenuhi semua.
- [ ] `flutter analyze` 0 error, `flutter test` hijau.
- [ ] Fitur terverifikasi jalan manual di device.
- [ ] Tidak ada kode slop / stubs kosong.
- [ ] Commit tertulis sesuai konvensi.

Lihat `docs/scope.md` untuk batas fitur (In-Scope vs Out-of-Scope). Jangan kerjakan yang Out-of-Scope.