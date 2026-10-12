import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';
import '../services/api_service.dart';
import 'form_page.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({required this.mahasiswa, super.key});
  final Mahasiswa mahasiswa;
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final api = ApiService();
  late Future<Mahasiswa> future;
  @override
  void initState() {
    super.initState();
    future = api.getById(widget.mahasiswa.id!);
  }

  Future<void> edit(Mahasiswa m) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FormPage(mahasiswa: m)),
    );
    if (changed == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail Mahasiswa')),
    body: FutureBuilder<Mahasiswa>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text(snap.error.toString()));
        final m = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(
              radius: 42,
              child: Text(
                m.nama.isEmpty ? '?' : m.nama[0].toUpperCase(),
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              m.nama,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(m.prodi, textAlign: TextAlign.center),
            const SizedBox(height: 22),
            _info('NIM', m.nim),
            _info('Email', m.email),
            _info('Angkatan', '${m.angkatan}'),
            _info('Nomor HP', m.noHp),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => edit(m),
              icon: const Icon(Icons.edit),
              label: const Text('Edit data'),
            ),
          ],
        );
      },
    ),
  );
  Widget _info(String label, String value) => Card(
    child: ListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
