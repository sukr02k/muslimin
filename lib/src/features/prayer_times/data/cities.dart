import '../domain/geo_location.dart';

/// Daftar kota Indonesia yang dibundel (nama, koordinat, zona waktu).
/// Zona: WIB +420, WITA +480, WIT +540.
const List<GeoLocation> indonesianCities = [
  // WIB (+420)
  GeoLocation(
      label: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Bandung',
      latitude: -6.9175,
      longitude: 107.6191,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Surabaya',
      latitude: -7.2575,
      longitude: 112.7521,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Semarang',
      latitude: -6.9667,
      longitude: 110.4167,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Yogyakarta',
      latitude: -7.7956,
      longitude: 110.3695,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Medan', latitude: 3.5952, longitude: 98.6722, utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Palembang',
      latitude: -2.9761,
      longitude: 104.7754,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Bandar Lampung',
      latitude: -5.4500,
      longitude: 105.2667,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Padang',
      latitude: -0.9500,
      longitude: 100.3531,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Pekanbaru',
      latitude: 0.5071,
      longitude: 101.4478,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Batam', latitude: 1.0456, longitude: 104.0305, utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Banda Aceh',
      latitude: 5.5483,
      longitude: 95.3238,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Pontianak',
      latitude: 0.0263,
      longitude: 109.3425,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Jambi',
      latitude: -1.5900,
      longitude: 103.6100,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Bengkulu',
      latitude: -3.7928,
      longitude: 102.2608,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Bogor',
      latitude: -6.5971,
      longitude: 106.8060,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Depok',
      latitude: -6.4025,
      longitude: 106.7942,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Bekasi',
      latitude: -6.2383,
      longitude: 106.9756,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Tangerang',
      latitude: -6.1783,
      longitude: 106.6319,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Cirebon',
      latitude: -6.7061,
      longitude: 108.5571,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Malang',
      latitude: -7.9839,
      longitude: 112.6214,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Solo',
      latitude: -7.5667,
      longitude: 110.8167,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Pangkal Pinang',
      latitude: -2.1299,
      longitude: 106.1136,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Tasikmalaya',
      latitude: -7.3274,
      longitude: 108.2207,
      utcOffsetMinutes: 420),
  GeoLocation(
      label: 'Purwokerto',
      latitude: -7.4246,
      longitude: 109.2392,
      utcOffsetMinutes: 420),
  // WITA (+480)
  GeoLocation(
      label: 'Denpasar',
      latitude: -8.6705,
      longitude: 115.2126,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Makassar',
      latitude: -5.1477,
      longitude: 119.4327,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Mataram',
      latitude: -8.5833,
      longitude: 116.1167,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Manado',
      latitude: 1.4748,
      longitude: 124.8421,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Balikpapan',
      latitude: -1.2379,
      longitude: 116.8529,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Samarinda',
      latitude: -0.5022,
      longitude: 117.1536,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Banjarmasin',
      latitude: -3.3186,
      longitude: 114.5944,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Kupang',
      latitude: -10.1772,
      longitude: 123.6070,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Palu',
      latitude: -0.8951,
      longitude: 119.8592,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Kendari',
      latitude: -3.9985,
      longitude: 122.5129,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Gorontalo',
      latitude: 0.5436,
      longitude: 123.0568,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Sumbawa Besar',
      latitude: -8.4992,
      longitude: 117.4203,
      utcOffsetMinutes: 480),
  GeoLocation(
      label: 'Palangkaraya',
      latitude: -2.2073,
      longitude: 113.9127,
      utcOffsetMinutes: 480),
  // WIT (+540)
  GeoLocation(
      label: 'Jayapura',
      latitude: -2.5916,
      longitude: 140.6690,
      utcOffsetMinutes: 540),
  GeoLocation(
      label: 'Ambon',
      latitude: -3.6954,
      longitude: 128.1821,
      utcOffsetMinutes: 540),
  GeoLocation(
      label: 'Ternate',
      latitude: 0.7909,
      longitude: 127.3848,
      utcOffsetMinutes: 540),
  GeoLocation(
      label: 'Sorong',
      latitude: -0.8765,
      longitude: 131.2616,
      utcOffsetMinutes: 540),
  GeoLocation(
      label: 'Manokwari',
      latitude: -0.8626,
      longitude: 134.0642,
      utcOffsetMinutes: 540),
  GeoLocation(
      label: 'Merauke',
      latitude: -8.4992,
      longitude: 140.4023,
      utcOffsetMinutes: 540),
];