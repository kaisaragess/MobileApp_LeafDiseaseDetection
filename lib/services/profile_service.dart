import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String nama;
  final String nim;
  final String kampus;

  const UserProfile({this.nama = '', this.nim = '', this.kampus = ''});
}

class ProfileService {
  static const _kNama = 'profil_nama';
  static const _kNim = 'profil_nim';
  static const _kKampus = 'profil_kampus';

  static Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      nama: prefs.getString(_kNama) ?? '',
      nim: prefs.getString(_kNim) ?? '',
      kampus: prefs.getString(_kKampus) ?? '',
    );
  }

  static Future<void> save(UserProfile p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNama, p.nama);
    await prefs.setString(_kNim, p.nim);
    await prefs.setString(_kKampus, p.kampus);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kNama);
    await prefs.remove(_kNim);
    await prefs.remove(_kKampus);
  }
}
