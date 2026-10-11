import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

/// Halaman yang menampilkan statistik, mendemonstrasikan 3 state:
/// loading, error, dan success menggunakan AsyncValue.when().
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch membuat widget ini rebuild otomatis setiap kali
    // state statsProvider berubah (loading -> error/data).
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        // ---- STATE: LOADING ----
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // ---- STATE: ERROR ----
        error: (err, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Gagal memuat statistik:\n$err',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                // Memanggil refresh() di notifier, BUKAN ref.invalidate(),
                // supaya kita bisa kontrol logic retry sendiri kalau perlu
                // (misal: nambah counter percobaan, dsb).
                onPressed: () => ref.read(statsProvider.notifier).refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),

        // ---- STATE: SUCCESS ----
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final item = stats[index];
            return ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(item.label),
              trailing: Text(
                item.value.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}