# LeafScan: Deteksi Penyakit Daun Padi (Frontend Flutter)

Aplikasi mobile Flutter untuk mendiagnosis penyakit daun padi (*Bacterial Leaf Blight*, *Brown Spot*, dan *Leaf Smut*) dari foto. Backend-nya berada di repo terpisah.

Tugas kelompok Mobile Programming / Pengolahan Citra Digital.

## Fitur

- Diagnosis dari foto kamera atau galeri (JPG atau PNG, maksimal 10 MB)
- Pilihan pipeline pengolahan citra (B0, B1, B2, P1) dan model klasifikasi (KNN, SVM, RandomForest, ExtraTrees, Ensemble_Voting)
- Visualisasi enam tahap pemrosesan citra
- Komparasi 4 pipeline pada kondisi citra bersih dan terganggu
- Keterangan penyakit dan saran penanganan
- Riwayat diagnosis yang tersimpan di perangkat
- Bagikan hasil lewat aplikasi berbagi
- Profil lokal (login belum tersedia)

## Persyaratan

- Flutter SDK channel stable. Gunakan versi yang sama dengan tim.
- Android Studio atau VS Code dengan extension Flutter
- Backend API yang sedang berjalan (lihat bagian [Backend](#backend))

## Instalasi

```bash
git clone https://github.com/kaisaragess/MobileApp_LeafDiseaseDetection.git
cd MobileApp_LeafDiseaseDetection
flutter pub get
flutter analyze
```

## Konfigurasi alamat server

Atur `baseUrl` di `lib/config.dart` sesuai tempat backend berjalan:

| Target | baseUrl |
|---|---|
| Android emulator | `http://10.0.2.2:8000/api/v1` |
| Chrome di laptop yang sama | `http://localhost:8000/api/v1` |
| HP fisik (satu Wi-Fi dengan laptop) | `http://IP-LAPTOP:8000/api/v1` |
| Server deploy | `https://NAMA-SPACE.hf.space/api/v1` |

## Menjalankan aplikasi

```bash
flutter run             # HP atau emulator
flutter run -d chrome   # tampilan di browser (upload foto hanya berfungsi di HP)
```

## Struktur folder

```
lib/
├── main.dart          # Titik awal aplikasi
├── config.dart        # Alamat server
├── theme.dart         # Warna dan gaya tampilan
├── data/              # Keterangan penyakit dan saran penanganan
├── models/            # Model data (respons API, riwayat, komparasi)
├── screens/           # Halaman: diagnosis, hasil, komparasi, riwayat, bagikan, profil, pengaturan
├── services/          # Pemanggilan API, riwayat, profil, validasi unggahan
└── widgets/           # Komponen UI yang dipakai ulang
assets/images/         # Logo aplikasi
```

## Backend

Repo backend: https://github.com/kaisaragess/API_LeafDiseaseDetection

Panduan integrasi untuk Flutter ada di `FLUTTER_INTEGRATION_GUIDE.md` pada repo tersebut.

## Kontribusi

Baca [CONTRIBUTING.md](CONTRIBUTING.md) sebelum membuat perubahan. Jangan commit langsung ke `main`.

## Catatan

- Hasil diagnosis adalah purwarupa akademik, bukan alat diagnosis lapangan.
- Keterangan penyakit bersifat umum. Konsultasikan tindakan di lapangan dengan penyuluh pertanian setempat.

## Anggota kelompok

- kaisaragess: backend API
- RanggaDT: frontend Flutter

## Lisensi

Belum ditentukan.
