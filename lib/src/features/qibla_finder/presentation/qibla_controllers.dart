import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prayer_times/presentation/prayer_times_controllers.dart';
import '../domain/qibla_calculator.dart';

/// Provider kalkulasi bearing kiblat berdasarkan lokasi aktif (GPS atau kota pilihan).
final qiblaBearingProvider = Provider<double?>((ref) {
  final locationAsync = ref.watch(locationProvider);
  final loc = locationAsync.value;
  if (loc == null) return null;
  return QiblaCalculator.calculateBearing(loc.latitude, loc.longitude);
});

/// State kompas sensor perangkat.
class CompassState {
  const CompassState({
    this.heading,
    this.accuracy,
    this.sensorAvailable = true,
  });

  final double? heading;
  final double? accuracy;
  final bool sensorAvailable;

  CompassState copyWith({
    double? heading,
    double? accuracy,
    bool? sensorAvailable,
  }) {
    return CompassState(
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      sensorAvailable: sensorAvailable ?? this.sensorAvailable,
    );
  }
}

/// Provider stream sensor kompas magnetik secara real-time.
final compassStreamProvider = StreamProvider.autoDispose<CompassState>((ref) {
  final events = FlutterCompass.events;
  if (events == null) {
    return Stream.value(const CompassState(sensorAvailable: false));
  }

  return events.map((event) {
    final heading = event.heading;
    return CompassState(
      heading: heading,
      accuracy: event.accuracy,
      sensorAvailable: heading != null,
    );
  }).handleError((Object _) {
    return const CompassState(sensorAvailable: false);
  });
});