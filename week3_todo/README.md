# ToDo & Stats App — Riverpod State Management (Week 3)

## Tujuan
Melatih pengelolaan state dengan **Riverpod** (`Notifier`/`AsyncNotifier`) dan
penanganan tiga kondisi state asinkron (loading, error, success) memakai
`AsyncValue`.

## Fitur utama
- Halaman **ToDo** — tambah tugas, tandai selesai, hapus. State dikelola
  `NotifierProvider`.
- Halaman **Statistik** — simulasi pengambilan data async (delay + kadang
  gagal), ditangani `AsyncNotifierProvider` dengan `AsyncValue.when()` untuk
  loading/error/success.
- Tombol **Coba lagi** pada state error yang memanggil ulang provider.

## Stack teknologi
- Flutter (Web)
- `flutter_riverpod` — `Notifier`, `AsyncNotifier`, `AsyncValue`

## Cara menjalankan
```bash
flutter pub get
flutter run
```
Verifikasi:
```bash
flutter analyze
flutter test
```

## Hasil yang dicapai

**State kosong (ToDo)**
![ToDo kosong](screenshots/ScreenShot (802).png)

**AsyncValue — state success**
![Data berhasil dimuat](screenshots/ScreenShot (803).png)

**AsyncValue — state loading**
![Loading spinner](screenshots/ScreenShot (804).png)

**AsyncValue — state error + tombol retry**
![Error dan tombol coba lagi](screenshots/ScreenShot (805).png)

**Halaman Statistik — success**
![Statistik berhasil dimuat](screenshots/ScreenShot (806).png)

**`flutter analyze` & `flutter test` lolos**
![Analyze dan test lolos](screenshots/analyze.png)

```
Analyzing week3_todo...
No issues found! (ran in 2.5s)

00:03 +7: All tests passed!
```

## AI Verification Checklist
- Apakah state diubah secara immutable (tidak ada state.add() atau mutasi list langsung)?

Awalnya ada state.add(), lalu diperbaiki menjadi membuat list baru seperti state = [...state, newTodo].

- Apakah ref.watch hanya dipakai di dalam build, dan ref.read di callback?

Awalnya ref.watch ada di callback, lalu diperbaiki. ref.watch digunakan di build, sedangkan ref.read digunakan di callback.

- Apakah ketiga state AsyncValue benar-benar ditangani (bukan hanya success)?

Sudah. Loading, error, dan success ditangani menggunakan AsyncValue.when().

- Apakah provider dideklarasikan dengan tipe eksplisit dan tidak duplikat dengan provider lain?

Sudah, semua provider menggunakan tipe yang jelas dan tidak ada provider yang duplikat.

- Apakah kode AI memakai API Riverpod versi lama (StateProvider antipattern, StateNotifierProvider usang, atau Consumer bertingkat yang tidak perlu)? Perbaiki ke pola Notifier/ConsumerWidget.

Awalnya menggunakan StateNotifier, lalu diperbaiki menjadi Notifier dan AsyncNotifier dengan ConsumerWidget.

- Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?

Setelah diperbaiki, flutter analyze tidak menemukan error dan semua test berhasil.


## Refleksi
- Kapan setState masih cukup, dan kapan state harus naik ke Riverpod?

setState cukup untuk state kecil yang hanya dipakai satu widget. Riverpod lebih cocok untuk state yang dipakai banyak widget, perlu bertahan saat navigasi, atau punya logic bisnis.

- Apa perbedaan context.go dan context.push, dan kapan masing-masing tepat digunakan?

context.go() cocok untuk pindah halaman atau tab utama, sedangkan context.push() digunakan untuk membuka halaman baru yang masih bisa kembali dengan tombol back.

- Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?

AsyncValue membuat state loading, error, dan success lebih teratur sehingga tidak ada kombinasi state yang membingungkan seperti beberapa boolean yang aktif bersamaan.

- Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
Saya memperbaiki penggunaan StateNotifier, state.add(), penggunaan ref.watch, test pump(), dan dependency Random. Perbaikan dilakukan supaya kode lebih modern, stabil, dan mudah di-test.