# Week 2 — Declarative UI & Responsive Design

Nama: Abim Must
NIM: 244107020078
Kelas: TI 3D

Laporan ini isinya progres dari codelab #02, mulai dari demo/warm-up sampai testing dan refleksi.

## Warm-up: ProfileCard

Sebelum bikin dashboard, latihan dulu bikin kartu profil pakai `Container`, `Row`, `Column`, `Expanded`.

![ProfileCard](Screenshots/Screenshot%20(795).png)

Waktu eksperimen (disuruh hapus `Expanded` terus lihat efeknya), sempat kena error karena salah taruh kurung di `Expanded(child: Column(...))` — error-nya `A value of type '({Column child})' can't be assigned to a variable of type 'Widget'`.

![error waktu eksperimen](Screenshots/Screenshot%20(793).png)

Setelah dibenerin strukturnya, jalan normal lagi:

![sudah fix](Screenshots/Screenshot%20(794).png)

Terus nambahin baris "Email" pakai pola yang sama kayak NIM/Kelas (`Row` + `Expanded`), berhasil tanpa masalah.

## Dashboard responsif

Project `responsive_dashboard` dibuat sesuai codelab: `DashboardApp` diubah dari `StatelessWidget` jadi `StatefulWidget` biar bisa toggle dark mode manual pakai `CupertinoSwitch`, dan `LayoutBuilder` dipakai buat nentuin jumlah kolom grid.

Layar lebar (≥700px), 2 kolom, dark mode nyala:

![dashboard 2 kolom dark](Screenshots/Screenshot%20(796).png)

Layar sempit (<700px), 1 kolom, light mode:

![dashboard 1 kolom light](Screenshots/Screenshot%20(797).png)

Toggle switch-nya berfungsi, keliatan dari dua screenshot di atas temanya beda tanpa perlu ganti kode widget satu-satu — cuma `setState` doang, jadi kelihatan bedanya sama cara imperative.

## AI Prompt Challenge

Setelah dashboard jalan sendiri, baru coba tiga prompt yang diminta codelab ke Claude buat bandingin alternatif desain.

**Prompt 1 — bandingin GridView vs LayoutBuilder+Column.** Intinya: GridView.count enak karena ringkas, tapi `childAspectRatio` yang di-set tetap bisa bikin masalah kalau user gedein ukuran font di HP-nya (aksesibilitas), soalnya tinggi kartu dikunci rasio. Kalau pakai Column manual, tinggi kartu bisa ngikutin konten jadi lebih aman, tapi kodenya lebih panjang.

**Prompt 2 — kapan Expanded bikin overflow.** Ternyata Expanded itu cuma ngatur jatah ruang di level Row-nya sendiri, bukan otomatis bikin konten di dalamnya menyusut. Jadi kalau di dalam Expanded ada Text panjang tanpa `overflow: ellipsis`, tetep bisa overflow walau udah "dibungkus" Expanded.

**Prompt 3 — audit ulang.** Diminta Claude cek lagi apakah rekomendasinya masih aman di bawah 600px, apakah ngurangin aksesibilitas, dan apakah ada widget yang gak stable. Hasilnya: tetep aman di bawah 600px (breakpoint 700 udah nyakup), gak ngurangin aksesibilitas malah nambah, cuma `useMaterial3: true` yang ternyata udah gak perlu lagi ditulis manual sejak Flutter 3.16 (defaultnya udah true) — tapi bukan error, cuma redundan.

Dari situ, yang beneran dipakai ke kode:

- `DashboardCard` dibungkus `MergeSemantics` + `Semantics(label: '$title: $value')`, biar screen reader bacanya "Assignments: 8" jadi satu, bukan dua elemen kepisah.
- `Text(title)` dan `Text(value)` dikasih `overflow: TextOverflow.ellipsis` biar gak overflow kalau teksnya panjang atau font di-scale gede.
- Toggle dark mode dikasih `Semantics(label:, toggled:)` biar gak diumumin cuma "switch" doang sama screen reader.

![kode DashboardCard dengan semantics](Screenshots/Screenshot%20(799).png)

Semua saran di atas udah dicek jalan beneran (bukan asal disalin), lewat `flutter test` dan `flutter analyze` di bagian bawah.

## Refactoring

- DashboardCard dibuat reusable dengan menerima title dan value, kemudian digunakan sebanyak 4 kali tanpa perlu membuat kode yang sama berulang
- Text(value) menggunakan Theme.of(context).textTheme.headlineSmall agar mengikuti tema aplikasi tanpa perlu menggunakan style secara hardcode.
- Breakpoint 700 sebaiknya dipindahkan ke konstanta seperti const kWideBreakpoint = 700 agar hanya didefinisikan satu kali dan lebih mudah dikelola.
- flutter analyze sudah dijalankan dan hasilnya bersih tanpa error.

## Testing

Hasil akhir, semua lulus:

![test passed dan analyze bersih](Screenshots/Screenshot%20(801).png)

## Checklist

- `flutter analyze` bersih, gak ada error.
- `flutter test` lulus 2/2.
- Jalan normal di layar sempit (1 kolom) dan lebar (2 kolom).
- Dark mode kontrasnya masih enak dibaca.
- Screenshot, folder test, dan README udah tersimpan.

## Refleksi

**Imperative vs declarative:** pada pendekatan imperative, setiap perubahan biasanya perlu mengatur UI yang ingin diubah secara manual. pada pendekatan declarative di flutter, cukup mengubah state (isDark), kemudian build() akan dijalankan kembali dan UI menyesuaikan dengan kondisi terbaru.

**Expanded kadang malah error:** expanded membantu dalam membagi ruang pada row atau column. namun, penggunaannya tidak selalu mencegah overflow. overflow masih dapat terjadi jika parent memberikan constraint yang tidak terbatas.

**Breakpoint & theme ke UX:** breakpoint membuat dashboard tetap nyaman digunakan pada berbagai ukuran layar. pada layar yang lebih kecil digunakan 1 kolo,, sedangkan pada layar yang lebih lebar digunakan 2 kolom. theme juga membantu konsistensi tampilak light dan dark mode tanpa perlu menentukan warna secara manual.

**Yang diverifikasi dari saran AI:** ada 3 hal yang diperiksa, yaitu apakah solusi masih responsif di bawah 600px, apakah perubahan tersebut memengaruhi aksesibilitas, dan apakah widget yang digunakan masih valid. Hasilnya, breakpoint 700 sudah mencakup layar di bawah 600px, penambahan Semantics dapat membantu aksesibilitas, dan tidak ditemukan widget yang tidak stabil.
