
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
