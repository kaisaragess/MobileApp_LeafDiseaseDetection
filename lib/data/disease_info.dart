class DiseaseInfo {
  final String nama;
  final String penyebab;
  final String gejala;
  final List<String> saran;

  const DiseaseInfo({
    required this.nama,
    required this.penyebab,
    required this.gejala,
    required this.saran,
  });

  static const String disclaimer =
      'Keterangan ini bersifat umum. Untuk tindakan di lapangan, konsultasikan dengan penyuluh pertanian setempat.';

  static const Map<String, DiseaseInfo> _data = {
    'bacterial leaf blight': DiseaseInfo(
      nama: 'Hawar Daun Bakteri',
      penyebab:
          'Bakteri Xanthomonas oryzae pv. oryzae. Dikenal juga sebagai penyakit kresek.',
      gejala:
          'Garis atau bercak basah berwarna kuning keabu-abuan mulai dari tepi daun, lalu menjalar memanjang dan mengering.',
      saran: [
        'Gunakan varietas padi yang tahan hawar daun bakteri.',
        'Hindari pemupukan nitrogen yang berlebihan.',
        'Atur irigasi dan jangan biarkan sawah tergenang terlalu lama.',
        'Bersihkan sisa tanaman yang terinfeksi.',
        'Gunakan bakterisida sesuai anjuran dan rekomendasi penyuluh.',
      ],
    ),
    'brown spot': DiseaseInfo(
      nama: 'Bercak Coklat',
      penyebab:
          'Jamur Bipolaris oryzae. Sering muncul di lahan yang kekurangan hara.',
      gejala:
          'Bercak oval berwarna coklat dengan tepi lebih gelap atau kekuningan, muncul di daun dan pelepah.',
      saran: [
        'Lakukan pemupukan berimbang, termasuk kalium dan silika.',
        'Gunakan benih sehat dan lakukan perlakuan benih.',
        'Atur jarak tanam agar kelembapan di sekitar tanaman tidak terlalu tinggi.',
        'Gunakan fungisida hanya bila diperlukan dan sesuai anjuran.',
      ],
    ),
    'leaf smut': DiseaseInfo(
      nama: 'Gosong Daun',
      penyebab: 'Jamur Entyloma oryzae.',
      gejala:
          'Bercak kecil kekuningan hingga coklat pada daun. Pada permukaan bercak terdapat butiran spora hitam seperti bubuk.',
      saran: [
        'Bersihkan sisa tanaman dari lahan.',
        'Gunakan varietas yang tahan terhadap penyakit ini.',
        'Atur jarak tanam dan drainase agar lahan tidak terlalu lembap.',
        'Gunakan fungisida hanya bila diperlukan dan sesuai anjuran.',
      ],
    ),
  };

  /// Mencocokkan label dari backend tanpa membedakan huruf besar-kecil.
  static DiseaseInfo? forClass(String label) =>
      _data[label.toLowerCase().trim()];
}
