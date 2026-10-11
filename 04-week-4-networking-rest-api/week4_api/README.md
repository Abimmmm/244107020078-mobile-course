# Week 4 - Networking & REST API

## Tujuan

Project ini dibuat untuk mempraktikkan integrasi REST API pada Flutter menggunakan **Dio** dan **Flutter Riverpod**. API yang digunakan adalah **JSONPlaceholder**. Implementasi mencakup repository layer, model `fromJson` yang aman terhadap nilai null, penanganan state asynchronous, error handling, pagination, serta pengujian tanpa request HTTP sungguhan.

## Fitur Utama

- Mengambil data post dari endpoint `GET /posts`.
- Menggunakan Dio dengan konfigurasi terpusat.
- Model `Post` dan `Comment` menggunakan parsing yang aman terhadap nilai null.
- Semua akses data dilakukan melalui repository dan provider, bukan langsung dari widget.
- Menampilkan empat state UI: loading, error, empty, dan success.
- Menampilkan pesan error yang lebih ramah pengguna.
- Menyediakan tombol **Coba lagi** saat request gagal.
- Pagination server menggunakan `_page` dan `_limit` dengan 10 item per halaman.
- Infinite scroll dengan guard untuk mencegah request ganda.
- AI Challenge untuk endpoint `GET /comments?postId={id}`.
- Unit test model, error mapping, dan provider menggunakan repository palsu.

## Stack Teknologi

- Flutter
- Dart
- Dio
- Flutter Riverpod
- JSONPlaceholder REST API

## Konfigurasi API

Dio dikonfigurasi secara terpusat agar `baseUrl`, timeout, header, dan interceptor tidak tersebar di banyak file.

```text
Base URL: https://jsonplaceholder.typicode.com
Connect timeout: 10 detik
Receive timeout: 10 detik
```

Alur data yang digunakan:

```text
UI -> Riverpod Provider -> Repository -> Dio -> REST API
```

Dengan pola ini, widget hanya bertugas menampilkan state dan tidak menangani request jaringan secara langsung.

## Model Data dan Null Safety

Model menggunakan cast defensif agar field yang hilang atau bernilai null tidak langsung menyebabkan aplikasi crash.

Contoh:

```dart
title: json['title'] as String? ?? '',
```

Pendekatan ini digunakan pada model `Post` dan juga diterapkan pada model `Comment` pada AI Challenge.

## Error Handling

Exception dari repository diteruskan ke provider sehingga Riverpod dapat mengubahnya menjadi `AsyncError`. Error jaringan kemudian diterjemahkan menjadi pesan yang lebih ramah pengguna, termasuk:

- connection timeout
- send timeout
- receive timeout
- connection error
- HTTP 404
- HTTP 401/403
- server error

## State UI

| State | Tampilan |
|---|---|
| Loading | `CircularProgressIndicator` |
| Error | Pesan error + tombol `Coba lagi` |
| Empty | Pesan data belum tersedia |
| Success | Daftar post dari API |

## Pagination

Pagination menggunakan query:

```text
/posts?_page=N&_limit=10
```

Setiap halaman mengambil 10 item. Halaman berikutnya dimuat ketika posisi scroll mendekati bagian bawah list.

Guard berikut digunakan untuk mencegah request ganda dan menghentikan request saat data sudah habis:

```dart
if (state.isLoadingMore || !state.hasMore) return;
```

Data yang sudah tampil tetap dipertahankan apabila request halaman berikutnya gagal.

## AI Challenge

Prompt yang digunakan:

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error,
  404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

### Hasil Verifikasi AI

| Pemeriksaan | Hasil |
|---|---|
| UI tidak memanggil Dio langsung | Sesuai |
| Akses API melalui repository/provider | Sesuai |
| `fromJson` aman terhadap field null/hilang | Sesuai |
| Timeout dipetakan ke pesan pengguna | Sesuai |
| Connection error ditangani | Sesuai |
| HTTP 404/500 ditangani | Sesuai |
| Base URL dan timeout terpusat | Sesuai |
| Test mencakup field yang hilang | Sesuai |

### Perbaikan Manual

Hasil AI tidak langsung diterima seluruhnya. Beberapa bagian disesuaikan kembali dengan struktur project:

1. Parsing model dibuat lebih defensif agar aman terhadap nilai null dan perubahan tipe data.
2. Timeout dan `baseUrl` tetap diletakkan pada client Dio terpusat agar tidak diduplikasi di setiap repository.
3. Exception repository tidak ditelan dengan `catch` kosong agar dapat diteruskan menjadi `AsyncError`.
4. Retry otomatis Riverpod dinonaktifkan pada provider yang diuji agar unit test tidak menggantung.
5. Test provider menggunakan repository palsu sehingga tidak melakukan request HTTP sungguhan.

## Pengujian dan Bukti Screenshot

### 1. Success State

Data post berhasil diambil dari JSONPlaceholder dan ditampilkan pada aplikasi.

![Success state](screenshots/ss1.png)

### 2. Loading State

Saat request sedang diproses, aplikasi menampilkan indikator loading.

![Loading state](screenshots/ss2.png)

### 3. Error State dan Retry

Saat koneksi gagal, aplikasi menampilkan pesan error yang ramah pengguna beserta tombol **Coba lagi**.

![Error state](screenshots/ss3.png)

### 4. Koneksi Kembali Normal

Setelah koneksi tersedia kembali dan request diulang, data dapat dimuat kembali.

![Retry success](screenshots/ss4.png)

### 5. Pengujian URL/Koneksi Salah

Pengujian dilakukan dengan kondisi request gagal untuk memastikan error handling tidak menampilkan exception teknis mentah kepada pengguna.

![Invalid connection test](screenshots/ss5.png)

### 6. Pagination / Infinite Scroll

Saat pengguna mendekati bagian akhir daftar, halaman berikutnya dimuat tanpa menghapus data sebelumnya.

![Pagination](screenshots/ss6.png)

### 7. AI Challenge - Comments

Endpoint komentar berdasarkan `postId` berhasil diintegrasikan melalui repository dan provider.

![Comments API](screenshots/ss7.png)

## Testing

Pengujian mencakup:

- parsing `Post.fromJson` dengan field yang hilang;
- pemetaan `DioException` menjadi pesan pengguna;
- provider sukses menggunakan `FakePostRepository`;
- provider error menggunakan `FakePostRepository`;
- model `Comment` pada kasus field yang hilang.

Jalankan:

```bash
flutter analyze
flutter test
```

Tidak ada request HTTP sungguhan di dalam test provider karena dependency repository dioverride menggunakan repository palsu.

## Cara Menjalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Hasil
Aplikasi berhasil mengambil data REST API, menangani state UI, menampilkan pesan error, melakukan pagination, dan menggunakan repository + Riverpod sebagai pemisah antara UI dan jaringan.

# Refleksi

### 1. Mengapa UI tidak boleh memanggil Dio langsung?
Agar logika jaringan tidak bercampur dengan tampilan. Dengan repository, kode lebih mudah dirawat, digunakan ulang, dan diuji.

### 2. Kapan memakai pagination client-side dan server-side?
Client-side cukup untuk data kecil yang sudah dimuat seluruhnya. Server-side lebih tepat untuk data besar karena hanya mengambil data yang dibutuhkan per halaman.

### 3. Bagaimana exception menjadi `AsyncError`?
Exception dari repository yang dilempar pada `AsyncNotifier` otomatis menjadi `AsyncError`. `try/catch` tetap diperlukan saat perlu mengatur state tertentu, misalnya refresh atau mempertahankan data lama saat pagination gagal.

### 4. Apa yang diperbaiki dari hasil AI?
Parsing dibuat lebih aman, konfigurasi Dio tetap terpusat, exception tidak ditelan, dan test diperbaiki agar menggunakan repository palsu tanpa request internet.
