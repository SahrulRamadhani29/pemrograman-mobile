import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kamera dan Scanner',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilihan Kamera')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MenuButton(
              icon: Icons.camera_alt,
              title: 'Kamera Biasa',
              subtitle: 'Melihat preview kamera secara langsung',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraPage()),
              ),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.document_scanner,
              title: 'Scan Dokumen',
              subtitle: 'Memindai dan memotong dokumen otomatis',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(icon, size: 40),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: onPressed,
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late final CameraController _controller;
  Object? _error;
  bool _takingPhoto = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(_cameras.first, ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((Object error) {
      if (mounted) setState(() => _error = error);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (!_controller.value.isInitialized || _takingPhoto) return;
    setState(() => _takingPhoto = true);
    try {
      final photo = await _controller.takePicture();
      await Gal.putImage(photo.path, album: 'Praktikum Camera');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto tersimpan di galeri')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _takingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Kamera error: $_error')));
    }
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Kamera Biasa')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: FloatingActionButton(
                onPressed: _takingPhoto ? null : _takePhoto,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                tooltip: 'Ambil foto',
                child: _takingPhoto
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<String> _pictures = [];
  bool _scanning = false;

  Future<void> _scanDocument() async {
    setState(() => _scanning = true);
    try {
      final pictures = await CunningDocumentScanner.getPictures(
        scannerSource: ScannerSource.camera,
        noOfPages: 10,
      );
      if (mounted) setState(() => _pictures = pictures ?? []);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal scan dokumen: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_pictures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada hasil scan untuk disimpan')),
      );
      return;
    }

    try {
      for (final picture in _pictures) {
        await Gal.putImage(picture, album: 'Praktikum Camera');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hasil scan tersimpan di galeri')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan ke galeri: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Dokumen')),
      body: Column(
        children: [
          Expanded(
            child: _pictures.isEmpty
                ? const Center(child: Text('Belum ada dokumen yang dipindai'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _pictures.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Image.file(File(_pictures[index])),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                IconButton.filled(
                  onPressed: _saveToGallery,
                  icon: const Icon(Icons.check),
                  tooltip: 'Simpan ke galeri',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _scanning ? null : _scanDocument,
                    icon: const Icon(Icons.document_scanner),
                    label: Text(_scanning ? 'Membuka scanner...' : 'Mulai Scan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
