import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatItem {
  final String label;
  final int value;
  StatItem(this.label, this.value);
}

class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  // Konstruktor menerima random & delay opsional supaya bisa di-override
  // saat testing (delay Duration.zero + random yang hasilnya bisa diprediksi).
  StatsNotifier({
    Random? random,
    this.delay = const Duration(seconds: 2),
  }) : _random = random ?? Random();

  final Random _random;
  final Duration delay;

  @override
  Future<List<StatItem>> build() => _fetchStats();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchStats);
  }

  Future<List<StatItem>> _fetchStats() async {
    await Future.delayed(delay);
    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik dari server');
    }
    return [
      StatItem('Pengguna Aktif', 1240),
      StatItem('Total Transaksi', 356),
      StatItem('Pendapatan (Rp)', 8750000),
    ];
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);