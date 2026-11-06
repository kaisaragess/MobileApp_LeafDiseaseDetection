# Panduan Kontribusi

## Aturan utama

1. Jangan commit langsung ke `main`.
2. Setiap fitur atau perbaikan dikerjakan di branch sendiri.
3. Semua perubahan masuk lewat Pull Request dan ditinjau sebelum digabung (merge).

## Alur kerja

**1. Ambil versi terbaru dari `main`**

```bash
git checkout main
git pull origin main
```

**2. Buat branch baru**

```bash
git checkout -b feature/nama-singkat
```

Konvensi nama branch:
- `feature/` untuk fitur baru, misalnya `feature/riwayat-filter`
- `fix/` untuk perbaikan bug, misalnya `fix/dialog-422`
- `docs/` untuk dokumentasi, misalnya `docs/readme`

**3. Kerjakan perubahan, lalu cek kode**

```bash
flutter analyze
```

Hasilnya harus `No issues found` sebelum commit.

**4. Commit**

```bash
git add <file-yang-berubah>
git commit -m "Ringkasan perubahan"
```

Tulis pesan commit dalam kalimat singkat yang menjelaskan isi perubahan, misalnya `Tambah halaman komparasi pipeline` atau `Perbaiki ukuran gambar tahapan`.

**5. Push**

```bash
git push --set-upstream origin feature/nama-singkat
```

Setelah push pertama, cukup `git push`.

**6. Buat Pull Request**

- Base: `main`
- Compare: branch kamu
- Isi template PR yang muncul otomatis, lalu minta minimal satu anggota lain untuk meninjau.

**7. Setelah PR digabung**

```bash
git checkout main
git pull origin main
git branch -d feature/nama-singkat
```

## Yang tidak boleh di-commit

- Folder hasil build: `build/`, `.dart_tool/` (sudah diatur di `.gitignore`)
- Kunci dan keystore: `*.jks`, `*.keystore`, `key.properties`
- Kredensial, token, atau file `.env`
- Alamat IP laptop pribadi di `lib/config.dart`. Kembalikan ke nilai yang sudah disepakati sebelum commit.

## Menjaga kontrak API

- Jangan mengubah nama field JSON di model tanpa koordinasi dengan pengurus backend.
- Jika backend berubah, catat di deskripsi PR dan beri tahu anggota lain.

## Review

Pemberi review memeriksa:
- `flutter analyze` tidak menampilkan error
- Perubahan sesuai deskripsi PR
- Tidak ada file yang tidak relevan ikut ter-commit
