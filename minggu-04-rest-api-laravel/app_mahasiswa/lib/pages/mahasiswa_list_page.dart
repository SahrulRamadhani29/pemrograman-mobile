import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import 'form_page.dart';

class MahasiswaListPage extends StatefulWidget {
  const MahasiswaListPage({super.key});
  @override
  State<MahasiswaListPage> createState() => _MahasiswaListPageState();
}

class _MahasiswaListPageState extends State<MahasiswaListPage> {
  final api = ApiService();
  final search = TextEditingController();
  late Future<List<Mahasiswa>> future;

  @override
  void initState() {
    super.initState();
    future = api.getAll();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void refresh() => setState(() => future = api.getAll(search: search.text));

  Future<void> form([Mahasiswa? m]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FormPage(mahasiswa: m)),
    );
    if (changed == true) refresh();
  }

  Future<void> remove(Mahasiswa m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text('Hapus ${m.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await api.delete(m.id!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
        refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
        actions: [
          IconButton(onPressed: refresh, icon: const Icon(Icons.refresh)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: search,
              onSubmitted: (_) => refresh(),
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIM',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    search.clear();
                    refresh();
                  },
                  icon: const Icon(Icons.clear),
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: form,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
      ),
      body: FutureBuilder<List<Mahasiswa>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return _Message(snap.error.toString(), refresh);
          final data = snap.data ?? [];
          if (data.isEmpty) {
            return _Message('Belum ada data mahasiswa.', refresh);
          }
          return RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final m = data[i];
                return Card(
                  child: ListTile(
                    onTap: () =>
                        Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(mahasiswa: m),
                          ),
                        ).then((v) {
                          if (v == true) refresh();
                        }),
                    leading: CircleAvatar(
                      child: Text(m.nama.isEmpty ? '?' : m.nama[0]),
                    ),
                    title: Text(
                      m.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${m.nim} • ${m.prodi}\nAngkatan ${m.angkatan}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) => v == 'edit' ? form(m) : remove(m),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, this.onRetry);
  final String text;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    ),
  );
}
