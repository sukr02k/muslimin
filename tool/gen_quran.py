#!/usr/bin/env python3
"""Generate bundled Quran assets from AlQuran Cloud (offline, one-time).

Sources:
- Arabic (Uthmani):  https://api.alquran.cloud/v1/quran/quran-uthmani
- Indonesian:        https://api.alquran.cloud/v1/quran/id.indonesian  (Kemenag)

Output:
- assets/quran/surah_list.json
- assets/quran/surah/1.json .. 114.json
"""
import json
import os
import urllib.request

BASE = "https://api.alquran.cloud/v1/quran"
OUT_DIR = os.path.join(
    os.path.dirname(__file__), "..", "assets", "quran"
)
SURAH_DIR = os.path.join(OUT_DIR, "surah")


def fetch(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def clean_text(text: str) -> str:
    return text.replace("\ufeff", "").strip()


def clean_arabic_name(name: str) -> str:
    name = clean_text(name)
    # "سُورَةُ ٱلْفَاتِحَةِ" -> "ٱلْفَاتِحَةِ"
    if " " in name:
        name = name.split(" ", 1)[1].strip()
    return name


def main() -> None:
    os.makedirs(SURAH_DIR, exist_ok=True)

    arabic = fetch(f"{BASE}/quran-uthmani")["data"]
    indonesian = fetch(f"{BASE}/id.indonesian")["data"]

    # Map global ayah number -> Indonesian translation.
    id_by_ayah: dict[int, str] = {}
    for s in indonesian["surahs"]:
        for a in s["ayahs"]:
            id_by_ayah[a["number"]] = a["text"]

    surah_list = []
    total_ayahs = 0

    for s in arabic["surahs"]:
        number = s["number"]
        name = clean_arabic_name(s["name"])
        latin = s["englishName"]
        ayahs = []
        for a in s["ayahs"]:
            ayahs.append(
                {
                    "number": a["numberInSurah"],
                    "arabic": clean_text(a["text"]),
                    "translation": clean_text(id_by_ayah[a["number"]]),
                }
            )
        total_ayahs += len(ayahs)

        surah_obj = {
            "number": number,
            "name": name,
            "latin": latin,
            "ayahs": ayahs,
        }
        with open(os.path.join(SURAH_DIR, f"{number}.json"), "w", encoding="utf-8") as f:
            json.dump(surah_obj, f, ensure_ascii=False, separators=(",", ":"))

        surah_list.append(
            {
                "number": number,
                "name": name,
                "latin": latin,
                "ayahs": len(ayahs),
                "place": s["revelationType"],
            }
        )

    with open(
        os.path.join(OUT_DIR, "surah_list.json"), "w", encoding="utf-8"
    ) as f:
        json.dump(surah_list, f, ensure_ascii=False, separators=(",", ":"))

    print(f"OK surahs={len(surah_list)} total_ayahs={total_ayahs}")


if __name__ == "__main__":
    main()