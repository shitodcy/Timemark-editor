# Timemark Editor

Aplikasi mobile berbasis **Flutter** untuk menambahkan *watermark* waktu, tanggal, dan lokasi secara kustom pada foto. Sangat cocok digunakan untuk kebutuhan dokumentasi lapangan, absensi, atau laporan kegiatan harian di tempat yang membutuhkan bukti koordinat dan waktu yang akurat.

---

## Fitur Utama

- **Ambil Foto Fleksibel:** Mengambil gambar langsung dari Kamera atau memilih dari Galeri HP.
- **Kustomisasi Waktu:** Otomatis mendeteksi waktu saat ini, namun pengguna juga bebas mengedit format waktu dan tanggal secara manual.
- **Integrasi Peta Global:** Dilengkapi fitur pencarian lokasi akurat menggunakan *Google Maps Tile* untuk menghasilkan teks detail alamat dan koordinat (DMS).
- **Kustomisasi Watermark:** - Atur ukuran teks (*Size*)
  - Atur tingkat transparansi latar belakang teks (*Opacity*)
  - Atur posisi rata kanan/kiri (*Mirroring*)
  - Geser teks *watermark* sesuka hati di atas foto (*Drag & Drop*)
- **Simpan ke Galeri:** Hasil editan foto langsung tersimpan ke dalam galeri perangkat dengan kualitas tinggi dan tanpa *watermark* bawaan aplikasi lain.

---

## Tampilan Aplikasi

> **Catatan:** Berikut adalah cuplikan tampilan dari aplikasi Timemark Editor saat dijalankan.

<p align="center">
  <img src="https://github.com/shitodcy/Timemark-editor/blob/main/assets/screenshoot/splashscreen.jpeg" width="250" alt="splashsceen">
  <img src="https://github.com/shitodcy/Timemark-editor/blob/main/assets/screenshoot/home.jpeg" width="250" alt="Layar Utama">
  <img src="https://github.com/shitodcy/Timemark-editor/blob/main/assets/screenshoot/maps.jpeg" width="250" alt="Layar Peta">
  <img src="https://github.com/shitodcy/Timemark-editor/blob/main/assets/screenshoot/editor.jpeg" width="250" alt="editor">
  <img src="https://github.com/shitodcy/Timemark-editor/blob/main/assets/screenshoot/hasil.jpeg" width="500" alt="Hasil Foto">
</p>

---

## Teknologi yang Digunakan

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Maps & Location:** `flutter_map`, `latlong2`, `geocoding`
- **Image & File Handling:** `image_picker`, `gal`
- **UI Processing:** `screenshot`, `intl`

---
