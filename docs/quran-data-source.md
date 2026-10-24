# Sumber Data Quran

Data Quran Slice 3 dibundel offline sebagai asset lokal, di-generate satu kali
dari [AlQuran Cloud](https://alquran.cloud/). Tidak ada fetch saat runtime.

## Edisi

| Asset | Edisi API | Isi |
|---|---|---|
| `assets/quran/surah/{n}.json` | `quran-uthmani` | Teks Arab (Uthmani, dari Tanzil) |
| `assets/quran/surah/{n}.json` | `id.indonesian` | Terjemahan Indonesia (Kemenag) gabungan |
| `assets/quran/surah_list.json` | metadata | Nama Arab, transliterasi Latin, jumlah ayat, tempat turun |

Total: 114 surah, 6236 ayat, ~2.9 MB.

## Lisensi

- Teks Arab Uthmani: Tanzil.net — teks Al-Qur'an tersedia bebas untuk distribusi.
- Terjemahan Indonesia: Kementerian Agama Republik Indonesia (Kemenag), via
  Tanzil `id.indonesian`.

Sumber asli tetap dapat ditelusuri di https://alquran.cloud/ dan
https://tanzil.net/.

## Regenerasi

```sh
python3 tool/gen_quran.py
```

Script ini mengunduh dua edisi penuh lalu menggabungkannya ke
`assets/quran/`. Jalankan ulang hanya bila data Quran ingin diperbarui dari
sumber.