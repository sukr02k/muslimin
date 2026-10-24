# Scope — Aplikasi Muslimin (Android Offline)

> Dokumen ini adalah **batas legal ruang lingkup** antara developer dan klien.
> Fitur di luar "In-Scope" TIDAK termasuk dalam biaya/MVP ini. Permintaan tambahan = change request berbayar atau fase berikutnya.

## Project Summary

**Nama:** Muslimin
**Package / bundle id:** `id.muslimin.app`

**Tujuan bisnis:** Aplikasi Android mirip Muslim Pro yang berjalan **full offline** — seluruh data tersimpan lokal di perangkat pengguna, tanpa server, tanpa akun, tanpa cloud sync.

**Persona pengguna utama:** Muslim Indonesia (Bahasa Indonesia) yang butuh panduan ibadah harian tanpa koneksi internet — jadwal sholat akurat lokasi, pencatat sholat, baca Al-Qur'an, dan penunjuk arah kiblat.

**Prinsip inti (non-negotiable):**

1. Full offline — semua fitur inti bekerja tanpa internet.
2. Data hanya di device user — tidak ada backend, tidak ada akun, tidak ada telemetri pribadi.

---

## In-Scope (MVP — wajib rilis)

1. **Jadwal Sholat (Prayer Times)**
   - Hitung waktu sholat 5 waktu (Subuh, Dzuhur, Ashar, Maghrib, Isya) secara offline (kalkulasi astronomis lokal, bukan API).
   - Deteksi lokasi otomatis via GPS + fallback pilihan kota manual (daftar kota Indonesia dibundel).
   - Navigasi antar-tanggal (hari ini, besok, kemarin).
   - Pengaturan metode kalkulasi & mazhab (opsi standar).

2. **Tracker Sholat (Prayer Tracker)**
   - Tandai status tiap sholat per hari: `done` / `missed` / `qada`.
   - Lihat riwayat harian & progres (streak, jumlah, persentase).
   - Data tersimpan lokal, bisa diedit koreksi.

3. **Baca Al-Qur'an (Quran Reader)**
   - Daftar 114 surah + navigasi.
   - Baca ayat per surah (teks Arab).
   - Terjemahan Bahasa Indonesia (bundel, offline).
   - Bookmark ayat & lanjut baca terakhir (last read).

4. **Pencari Kiblat (Qibla Finder)**
   - Hitung arah kiblat dari lokasi (bearing) secara offline.
   - Kompas visual menunjuk arah Ka'bah.
   - Pakai lokasi GPS atau kota manual.

5. **Pengaturan Dasar**
   - Pilih lokasi (manual), metode kalkulasi, mazhab.

6. **Adhan Reminder (Notifikasi Lokal)**
   - Notifikasi pengingat azan per sholat secara lokal (tanpa server).
   - Toggle per sholat + offset menit sebelum azan.
   - Dijadwalkan offline (`flutter_local_notifications` + `timezone`), butuh izin notifikasi.

---

## Out-of-Scope (CRITICAL — DITOLAK / ditangguhkan)

Fitur berikut **BUKAN bagian dari MVP** dan tidak akan dikerjakan tanpa kesepakatan biaya baru:

| Kategori | Item yang ditolak/ditunda |
|---|---|
| **Backend / Cloud** | Server, REST API, akun/login, sync antar-device, backup cloud, sinkronisasi multi-perangkat. |
| **Akun & Sosial** | Registrasi, profil user, feed sosial, berbagi konten, komunitas. |
| **Push notifikasi server** | Push notification berbasis server/FCM (butuh internet). Adhan reminder **lokal** justru In-Scope (lihat poin 6). |
| **Konten premium** | Audio murottal/recitation penuh (lisensi & ukuran besar), video, kursus, khutbah streaming. |
| **Quran lanjutan** | Tajwid berwarna, mode mushaf full halaman (gambar), pencarian semantik, tafsir lengkap multi-jilid, terjemahan multi-bahasa (selain ID). |
| **Fitur Muslim Pro lainnya** | Kalender Hijriah penuh, jadwal puasa/ramadan khusus, zakat calculator, halal food scanner, grup doa. |
| **Platform lain** | iOS, versi web, tablet layout khusus. **(Hanya Android untuk MVP ini.)** |
| **Monetisasi** | Langganan (subscription), paywall, IAP, iklan. |
| **Non-fungsional berat** | Multi-bahasa selain ID/EN optional, dark mode *(nice-to-have, bukan wajib)*, animasi premium. |

**Catatan legal:** Fitur apa pun di atas belum termasuk harga yang disepakati. Setiap permintaan naik ke In-Scope = **change request** dengan estimasi waktu & biaya terpisah.

---

## Assumptions

1. **Platform:** Android saja (min SDK 24 / Android 7.0), Flutter stable.
2. **Bahasa UI:** Indonesia (default). Arab untuk teks Al-Qur'an.
3. **Sumber data:** teks Al-Qur'an & terjemahan dibundel sebagai asset lokal (format JSON/SQLite ringkas). Quran complex (Uthmani) opsional agar ukuran APK tetap wajar.
4. **Akurasi jadwal:** memakai kalkulasi astronomis standar (metode Kemenag/standar + pilihan mazhab). Tidak ada jaminan sinkron dengan lembaga tertentu; user wajib menyetujui persetujuan lokasi.
5. **Lokasi:** butuh izin akses lokasi (GPS) saat pertama; user bisa menolak & memilih kota manual.
6. **Adhan reminder (notifikasi lokal):** termasuk MVP. Pakai `flutter_local_notifications` + `timezone`, jadwal lokal per sholat. Butuh izin notifikasi & kalkulasi waktu akurat (dari Slice 1).

---

## Deliverables & Timeline (estimasi)

| Fase | Deliverable | Estimasi |
|---|---|---|
| Slice 0 | Setup proyek + DB baseline + arsitektur | 1–2 hari |
| Slice 1 | Jadwal Sholat | 2–3 hari |
| Slice 2 | Tracker Sholat | 2–3 hari |
| Slice 3 | Quran Reader | 3–5 hari |
| Slice 4 | Qibla Finder | 2–3 hari |
| Slice 5 | Adhan Reminder (notifikasi lokal) | 1–2 hari |
| Slice 6 | Polish + pengaturan + hardening | 1–2 hari |
| **Total MVP** | APK Android siap uji | **~13–20 hari kerja** |

**Batas revisi:** 2 iterasi revisi per slice setelah serah terima. Revisi struktural yang mengubah arsitektur / menambah fitur di luar In-Scope = change request.