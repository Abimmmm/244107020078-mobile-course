import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

/// Random palsu yang selalu mengembalikan nilai tetap,
/// supaya hasil sukses/gagal bisa dipastikan di test (bukan acak).
class _FixedRandom implements Random {
  _FixedRandom(this.value);
  final double value;
  @override
  double nextDouble() => value;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

/// Helper: tunggu sampai state provider bukan loading lagi,
/// lalu kembalikan state akhirnya. Lebih stabil daripada
/// container.read(provider.future) untuk kasus provider yang error.
Future<AsyncValue<List<StatItem>>> _waitUntilSettled(
  ProviderContainer container,
) async {
  AsyncValue<List<StatItem>> state = container.read(statsProvider);
  var attempts = 0;
  while (state.isLoading && attempts < 100) {
    await Future.delayed(const Duration(milliseconds: 10));
    state = container.read(statsProvider);
    attempts++;
  }
  return state;
}

void main() {
  group('StatsNotifier', () {
    test('build() menghasilkan data saat random di atas ambang gagal (sukses)', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(random: _FixedRandom(0.9), delay: Duration.zero),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Subscribe supaya provider tidak ke-dispose sebelum selesai loading.
      final sub = container.listen(statsProvider, (_, _) {});
      addTearDown(sub.close);

      final state = await _waitUntilSettled(container);

      expect(state.hasValue, isTrue);
      expect(state.value!.length, 3);
      expect(state.value![0].label, 'Pengguna Aktif');
    });

    test('build() menghasilkan AsyncError saat random di bawah ambang gagal', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(random: _FixedRandom(0.1), delay: Duration.zero),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(statsProvider, (_, _) {});
      addTearDown(sub.close);

      final state = await _waitUntilSettled(container);

      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
      expect(state.error.toString(), contains('Gagal mengambil data statistik'));
    });

    test('refresh() mengubah state ke loading lalu ke data', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(random: _FixedRandom(0.9), delay: Duration.zero),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(statsProvider, (_, _) {});
      addTearDown(sub.close);

      // Tunggu build() awal selesai dulu.
      await _waitUntilSettled(container);

      final states = <AsyncValue<List<StatItem>>>[];
      container.listen<AsyncValue<List<StatItem>>>(
        statsProvider,
        (previous, next) => states.add(next),
      );

      await container.read(statsProvider.notifier).refresh();

      expect(states.first, isA<AsyncLoading<List<StatItem>>>());
      expect(states.last, isA<AsyncData<List<StatItem>>>());
    });
  });
}