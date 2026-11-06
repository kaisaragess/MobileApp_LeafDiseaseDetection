import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _nim = TextEditingController();
  final _kampus = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nama.dispose();
    _nim.dispose();
    _kampus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await ProfileService.load();
    if (!mounted) return;
    _nama.text = p.nama;
    _nim.text = p.nim;
    _kampus.text = p.kampus;
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ProfileService.save(
      UserProfile(
        nama: _nama.text.trim(),
        nim: _nim.text.trim(),
        kampus: _kampus.text.trim(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil disimpan di perangkat ini.')),
    );
  }

  Future<void> _clear() async {
    await ProfileService.clear();
    if (!mounted) return;
    _nama.clear();
    _nim.clear();
    _kampus.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data profil dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final namaTrim = _nama.text.trim();
    final initial = namaTrim.isEmpty ? '?' : namaTrim[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    child: const Text(
                      'Login belum tersedia. Data profil hanya disimpan di perangkat ini dan tidak dikirim ke server.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle('Data Diri'),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nama,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nama lengkap',
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nim,
                          decoration: const InputDecoration(labelText: 'NIM'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _kampus,
                          decoration: const InputDecoration(
                            labelText: 'Kampus / Universitas',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Simpan Profil'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _clear,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                    child: const Text('Hapus data profil'),
                  ),
                ],
              ),
            ),
    );
  }
}
