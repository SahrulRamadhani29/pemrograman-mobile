import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';
import '../services/api_service.dart';

class FormPage extends StatefulWidget {
  const FormPage({this.mahasiswa, super.key});
  final Mahasiswa? mahasiswa;
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final keyForm = GlobalKey<FormState>();
  final api = ApiService();
  late final List<TextEditingController> c;
  bool loading = false;
  bool get edit => widget.mahasiswa != null;

  @override
  void initState() {
    super.initState();
    final m = widget.mahasiswa;
    c = [
      TextEditingController(text: m?.nim),
      TextEditingController(text: m?.nama),
      TextEditingController(text: m?.prodi),
      TextEditingController(text: m?.email),
      TextEditingController(text: m == null ? '' : '${m.angkatan}'),
      TextEditingController(text: m?.noHp),
    ];
  }

  @override
  void dispose() {
    for (final x in c) {
      x.dispose();
    }
    super.dispose();
  }

  String? requiredValue(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;

  Future<void> save() async {
    if (!keyForm.currentState!.validate()) return;
    setState(() => loading = true);
    final m = Mahasiswa(
      id: widget.mahasiswa?.id,
      nim: c[0].text.trim(),
      nama: c[1].text.trim(),
      prodi: c[2].text.trim(),
      email: c[3].text.trim(),
      angkatan: int.parse(c[4].text),
      noHp: c[5].text.trim(),
    );
    try {
      if (edit) {
        await api.update(m);
      } else {
        await api.create(m);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(edit ? 'Edit Mahasiswa' : 'Tambah Mahasiswa')),
      body: Form(
        key: keyForm,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _input('NIM', c[0], validator: requiredValue),
            _input('Nama', c[1], validator: requiredValue),
            _input('Program Studi', c[2], validator: requiredValue),
            _input(
              'Email',
              c[3],
              validator: (v) =>
                  requiredValue(v) ??
                  (v!.contains('@') ? null : 'Email tidak valid'),
            ),
            _input(
              'Angkatan',
              c[4],
              keyboard: TextInputType.number,
              validator: (v) =>
                  requiredValue(v) ??
                  (int.tryParse(v!) == null ? 'Harus angka' : null),
            ),
            _input(
              'Nomor HP',
              c[5],
              keyboard: TextInputType.phone,
              validator: requiredValue,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: loading ? null : save,
              icon: loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(loading ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    FormFieldValidator<String>? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
