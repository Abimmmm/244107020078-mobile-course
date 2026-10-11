# Week 6 — Campus Notification App

## Tujuan

Project ini dibuat untuk menerapkan autentikasi, penyimpanan token yang aman, refresh token menggunakan Dio, serta Firebase Cloud Messaging (FCM) pada aplikasi Flutter. Aplikasi dapat menerima notifikasi kampus dan membuka halaman pengumuman tertentu melalui deep link `/pengumuman/:id`.

## Fitur Utama

- Login dengan route guard menuju `/login` ketika pengguna belum memiliki sesi.
- Access token dan refresh token disimpan menggunakan `flutter_secure_storage`.
- Dio menambahkan access token pada request dan mencoba refresh satu kali ketika menerima status `401`.
- Jika refresh token gagal, sesi dibersihkan dan pengguna harus login kembali.
- FCM permission, `getToken`, dan `onTokenRefresh`.
- Subscribe topic `pengumuman-kampus`.
- Foreground notification ditampilkan menggunakan `flutter_local_notifications`.
- Notifikasi membawa payload `route` dan `id` untuk membuka `/pengumuman/:id`.
- Penanganan notifikasi pada kondisi foreground, background, dan terminated.
- Unit test untuk parsing route dan logika sesi/refresh.

## Stack Teknologi

- Flutter
- Dart
- Firebase Core
- Firebase Messaging
- Flutter Local Notifications
- Flutter Secure Storage
- Dio
- GoRouter
- Flutter Riverpod


## Cara Menjalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Firebase sudah dikonfigurasi menggunakan FlutterFire dan aplikasi Android terhubung ke project Firebase `campus-notify`.

## Implementasi FCM

Aplikasi meminta izin notifikasi, mengambil FCM token, memantau perubahan token melalui `onTokenRefresh`, dan melakukan subscribe ke topic:

```text
pengumuman-kampus
```

Token tidak disimpan atau ditampilkan penuh pada dokumentasi. Endpoint yang digunakan/didokumentasikan untuk registrasi token perangkat adalah:

```text
POST /devices
```

Payload notifikasi yang diuji menggunakan custom data:

```text
route = /pengumuman/3
id = 3
```

### Konfigurasi custom data di Firebase Console

![Firebase Additional Options](screenshots/ss1.png)

![Firebase Custom Data](screenshots/ss2.png)

## Pengujian Notifikasi

| State | Hasil yang diharapkan | Hasil pengujian |
|---|---|---|
| Foreground | Banner lokal muncul saat aplikasi sedang terbuka | Berhasil |
| Background | Banner muncul dan ketika diklik membuka `/pengumuman/3` | Berhasil |
| Terminated | Aplikasi yang sudah ditutup tetap menerima notifikasi dan ketika diklik membuka `/pengumuman/3` | Berhasil |

### Foreground

Saat aplikasi berada di foreground, notifikasi ditampilkan secara manual menggunakan `flutter_local_notifications`.

![Foreground Notification](screenshots/hslmotif1.jpeg)

### Banner notifikasi dengan payload pengumuman

![Notification Route](screenshots/hslnotifroute.jpeg)

### Background

Ketika aplikasi berada di background, notifikasi dapat diklik dan mengarahkan pengguna ke halaman detail pengumuman ID 3.

![Background Deep Link](screenshots/hslflutterrun.jpeg)

### Terminated

Ketika aplikasi telah dihentikan, notifikasi tetap diterima. Saat notifikasi diklik, aplikasi terbuka dan menuju halaman pengumuman ID 3 melalui initial message.

![Terminated Deep Link](screenshots/hslflutter-nonrun.jpeg)

### Tampilan awal aplikasi

![Home Campus Notify](screenshots/hslawal.jpeg)

## Hasil Analyze dan Test

Project telah diperiksa menggunakan:

```bash
flutter analyze
flutter test
```

Hasil akhir menunjukkan `No issues found!` dan seluruh test berhasil.

![Flutter Test and Analyze](screenshots/sstest.png)

Test yang dibuat mencakup:

1. Parsing route notifikasi, termasuk route kosong dan route tanpa `/`.
2. Validasi payload `id` pengumuman.
3. Logika status login berdasarkan keberadaan access token.
4. Logika ketika refresh token kosong/gagal sehingga pengguna harus login ulang.

## AI Challenge

AI digunakan untuk membantu membuat draf awal implementasi `PushService`, background handler, routing FCM, dan test. Hasil AI tidak langsung digunakan seluruhnya dan dilakukan pemeriksaan manual sebelum diterapkan.

Perbaikan manual yang dilakukan antara lain:

- Memastikan background handler berada pada fungsi top-level dan menggunakan `@pragma('vm:entry-point')`.
- Menyesuaikan API `flutter_local_notifications` dengan versi package yang digunakan.
- Menampilkan local notification secara manual ketika pesan diterima saat foreground.
- Memastikan `onMessageOpenedApp` dan `getInitialMessage()` membaca `data.route`.
- Menambahkan payload `route = /pengumuman/3` dan `id = 3` pada Firebase Console.
- Tidak menampilkan FCM token secara penuh pada dokumentasi.
- Menghapus test bawaan counter Flutter yang tidak relevan dan menggantinya dengan test sesuai kebutuhan project.

Prompt, output awal AI, perbaikan manual, dan alasan teknis didokumentasikan lebih lanjut di folder `docs/`.

## Refleksi

### Mengapa refresh token tidak boleh disimpan di SharedPreferences?

Refresh token memiliki akses yang lebih sensitif karena dapat digunakan untuk mendapatkan access token baru. `SharedPreferences` bukan penyimpanan yang dirancang untuk data rahasia. Jika refresh token bocor, pihak lain dapat mencoba mempertahankan sesi pengguna dengan membuat access token baru. Karena itu token disimpan menggunakan `flutter_secure_storage`.

### Apa yang terjadi jika `onTokenRefresh` diabaikan selama satu semester?

FCM token dapat berubah, misalnya setelah reinstall aplikasi, clear data, atau rotasi token oleh Firebase. Jika backend masih menyimpan token lama, notifikasi kampus dapat gagal dikirim ke perangkat mahasiswa. Karena itu token baru perlu dikirim kembali ke endpoint `POST /devices` melalui `onTokenRefresh`.

### Kapan memakai topic dan kapan memakai token perangkat?

Topic digunakan untuk pesan yang ditujukan kepada banyak pengguna sekaligus. Contohnya adalah pengumuman perubahan jadwal kuliah untuk mahasiswa kampus melalui topic `pengumuman-kampus`.

Token perangkat digunakan untuk pesan yang sifatnya khusus kepada satu perangkat atau pengguna tertentu. Contohnya adalah pemberitahuan pribadi mengenai status pembayaran atau informasi akun mahasiswa.

### Bagian draf AI yang ditolak atau diperbaiki

Beberapa bagian draf AI diperbaiki karena belum sepenuhnya sesuai dengan lifecycle FCM dan versi package yang digunakan. Background handler harus berada di top-level dan tidak boleh mengakses `BuildContext`. Penanganan foreground juga diperbaiki agar notifikasi lokal benar-benar muncul, sedangkan navigasi background dan terminated disesuaikan menggunakan `onMessageOpenedApp` dan `getInitialMessage()`.

## Hasil yang Dicapai

Campus Notification App berhasil menerima notifikasi FCM, menampilkan notifikasi pada tiga state aplikasi, dan membuka deep link `/pengumuman/3` berdasarkan payload. Project juga telah melewati `flutter analyze` tanpa issue dan seluruh test yang dibuat berhasil dijalankan.

> Catatan: tugas meminta bukti screenshot token FCM yang dipotong. Screenshot tersebut belum terdapat di file screenshot yang diberikan, sehingga sebaiknya tambahkan satu gambar token terpotong ke folder `screenshots/` sebelum final push.
