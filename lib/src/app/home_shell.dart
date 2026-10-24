import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../features/adhan_reminder/presentation/reminder_controllers.dart';
import '../features/dhikr_tasbih/presentation/dhikr_tasbih_screen.dart';
import '../features/prayer_times/presentation/prayer_times_controllers.dart';
import '../features/prayer_times/presentation/prayer_times_screen.dart';
import '../features/prayer_tracker/presentation/prayer_tracker_screen.dart';
import '../features/qibla_finder/presentation/qibla_finder_screen.dart';
import '../features/quran_reader/presentation/quran_reader_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;
  DateTime? _lastBackPressTime;

  static const _screens = <Widget>[
    PrayerTimesScreen(),
    PrayerTrackerScreen(),
    QuranReaderScreen(),
    QiblaFinderScreen(),
    DhikrTasbihScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestInitialPermissions();
    });
  }

  Future<void> _requestInitialPermissions() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.whileInUse || req == LocationPermission.always) {
          ref.read(locationProvider.notifier).useGps();
        }
      } else if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        ref.read(locationProvider.notifier).useGps();
      }
    } catch (_) {}

    try {
      final notifService = ref.read(localNotificationServiceProvider);
      await notifService.requestPermission();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Jika sedang di tab selain tab pertama (Jadwal), kembalikan ke tab Jadwal dulu
        if (_index != 0) {
          setState(() => _index = 0);
          return;
        }

        // Deteksi double-tap back dalam rentang 2 detik untuk keluar aplikasi
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tekan sekali lagi untuk keluar dari Muslimin'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        // Keluar aplikasi
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.schedule_outlined),
              selectedIcon: Icon(Icons.schedule),
              label: 'Jadwal',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'Tracker',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Quran',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Kiblat',
            ),
            NavigationDestination(
              icon: Icon(Icons.fingerprint_rounded),
              selectedIcon: Icon(Icons.fingerprint_rounded),
              label: 'Tasbih',
            ),
          ],
        ),
      ),
    );
  }
}