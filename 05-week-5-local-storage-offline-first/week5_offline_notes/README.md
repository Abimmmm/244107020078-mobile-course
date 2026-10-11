# Offline Notes App — Local Storage & Offline First (Week 5)

## Tujuan
Menerapkan penyimpanan lokal dan konsep **offline-first** pada Flutter menggunakan **SharedPreferences**, **SQLite (sqflite)**, **Riverpod**, dan cache API.

## Fitur
- CRUD catatan lokal dengan SQLite.
- Catatan baru memiliki `dirty = true`.
- Sinkronisasi catatan dengan `syncNotes()`.
- Mode **Force Offline** untuk simulasi tanpa internet.
- Cache-first untuk data `GET /posts` JSONPlaceholder.
- `NoteTile` sebagai widget terpisah.
- Unit test memakai `FakeNoteRepository`.

## Teknologi
- Flutter
- `flutter_riverpod`
- `shared_preferences`
- `sqflite`
- `dio`
- `go_router`

## Cara Menjalankan
```bash
flutter pub get
flutter run
```

Verifikasi:
```bash
flutter analyze
flutter test
```

## Hasil

### Offline Notes
![Offline Notes](Screenshots/hsl1.jpeg)

### Dirty / belum tersinkron
![Dirty](Screenshots/hsl2.jpeg)

### Proses sinkronisasi
![Sync](Screenshots/hsl4.jpeg)

### Setelah sinkronisasi
![Synced](Screenshots/hsl3.jpeg)

### Analyze & Test
![Analyze dan Test](Screenshots/sss4.png)

```text
No issues found!
All tests passed!
```

## Perbandingan Penyimpanan

| Teknologi | Kelebihan | Kekurangan | Penggunaan |
|---|---|---|---|
| SharedPreferences | Sederhana, ringan | Tidak cocok untuk koleksi/query | Preferensi tema |
| Hive | Ringkas, cepat | Relasi/query terbatas | Object lokal sederhana |
| sqflite | SQL fleksibel, cocok CRUD | Mapping manual | **Catatan** |
| Drift | Type-safe, reactive stream | Setup lebih banyak | App lebih kompleks |

## Keputusan
**SharedPreferences** dipilih untuk preferensi karena cocok untuk key-value sederhana.

**SQLite/sqflite** dipilih untuk catatan karena mendukung CRUD, query, `dirty`, `updated_at`, dan sinkronisasi offline.

## AI Verification
- Catatan tidak disimpan di SharedPreferences.
- Skema memakai `dirty` dan `updated_at` untuk mendukung sinkronisasi.
- sqflite tidak otomatis real-time; UI diperbarui melalui provider.
- Drift lebih reactive dan type-safe, tetapi boilerplate lebih besar.
- Repository diuji menggunakan `FakeNoteRepository` tanpa SQLite sungguhan.

## Refleksi
SharedPreferences cukup untuk data sederhana seperti tema, sedangkan SQLite lebih cocok untuk koleksi catatan. `dirty` dipakai untuk menandai data yang belum tersinkron. Cache-first membuat data tetap bisa ditampilkan saat offline. Logika cache dan sinkronisasi dipisahkan ke `sync.dart` agar repository tetap fokus pada CRUD.


# Week 7 - Clean Architecture

## Tujuan

Melakukan refactor project **Week 5 - Offline Notes** menjadi Clean Architecture berbasis feature-first tanpa mengubah fungsi utama aplikasi.

## Fitur yang Direfactor

Fitur `notes` dipisahkan menjadi:

```text
lib/
├── core/
│   ├── failures.dart
│   └── format.dart
└── features/
    └── notes/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        ├── data/
        │   ├── models/
        │   └── repositories/
        └── presentation/
            ├── providers/
            └── pages/
```

### Audit awal presentation

![Audit awal](screenshots/ss1_week7.png)

### Presentation dan domain setelah refactor

Presentation diperiksa agar tidak mengakses Dio, SQLite, secure storage, SharedPreferences, atau parsing JSON secara langsung. Domain juga diperiksa agar tidak mengimpor Flutter, Dio, SQLite, atau Firebase.

![Grep sterilitas](screenshots/ss2_week7.png)

## Testing

Pengujian use case menggunakan repository palsu sehingga test domain tidak membutuhkan SQLite, Dio, maupun Firebase.

Hasil:

```text
flutter analyze : No issues found
flutter test    : All tests passed
```

![Analyze dan test](screenshots/ss3_week7.png)

Pengujian akhir juga tetap berhasil setelah refactor:

![Pengujian akhir](screenshots/ss4_week7.png)

## AI Challenge

AI digunakan untuk membantu menyusun struktur feature-first, pemisahan repository interface dan implementasi, serta wiring dependency menggunakan Riverpod.

### Keputusan Final

| Usulan AI | Keputusan |
|---|---|
| Repository interface di domain | Diterima |
| Repository implementation di data | Diterima |
| Entity tanpa mapping | Diterima |
| Riverpod sebagai dependency injection | Diterima |
| Use case untuk setiap CRUD sederhana | Disederhanakan |
| Menambah fitur baru ke Week 5 | Ditolak |

Use case tidak perlu dibuat untuk setiap operasi CRUD satu-baris karena dapat menambah boilerplate. Use case lebih berguna saat terdapat validasi, sinkronisasi, penggabungan beberapa repository, atau aturan bisnis lain.

## Stack Teknologi

- Flutter
- Dart
- Riverpod
- SQLite / sqflite

## Cara Menjalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Hasil

Refactor berhasil memisahkan fitur `notes` menjadi layer domain, data, dan presentation. Dependency rule telah diverifikasi, `flutter analyze` tidak menemukan issue, dan seluruh test berhasil dijalankan.

## Refleksi

### Mengapa repository interface berada di domain?

Karena domain harus menentukan kebutuhan bisnis tanpa bergantung pada detail penyimpanan data. Jika interface diletakkan di data, domain akan ikut bergantung pada implementasi luar dan arah dependency menjadi tidak sesuai Clean Architecture.

### Kapan use case dibutuhkan?

Use case diperlukan ketika terdapat aturan bisnis, validasi, sinkronisasi, atau penggunaan lebih dari satu repository. Untuk CRUD sederhana, repository dapat langsung digunakan oleh notifier agar struktur tidak terlalu rumit.

### Apa biaya over-engineering?

Terlalu banyak use case dan file untuk operasi sederhana dapat menambah boilerplate, memperlambat pengembangan, dan membuat navigasi kode lebih sulit. Pola tersebut lebih sepadan pada aplikasi besar atau logika bisnis yang kompleks.

### Apa yang disederhanakan dari hasil AI?

Usulan use case untuk setiap CRUD tidak diterapkan seluruhnya. Refactor juga tetap difokuskan pada fitur `notes` yang sudah ada agar tidak menambah fitur baru di luar tujuan praktikum.
