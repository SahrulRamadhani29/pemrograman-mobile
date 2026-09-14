import 'package:flutter/material.dart';

import 'lirik.dart';
import 'mahasiswa.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: AplikasiLirik()),
  );
}

class AplikasiLirik extends StatelessWidget {
  const AplikasiLirik({super.key});

  @override
  Widget build(BuildContext context) {
    const mahasiswa = Mahasiswa(
      nama: 'Sahrul Ramadhani',
      nim: '244107020058',
      kelas: 'TI-3C',
    );
    final lagu = Lirik(
      judul: "I'm Yours",
      penyanyi: "Jason Mraz",
      lirik: "Well, you done done me in, you bet I felt it\nI tried to be chill, but you're so hot that I melted\nI fell right through the cracks\nNow I'm trying to get back\nBefore the cool done run out\nI'll be giving it my bestest\nAnd nothing's gonna stop me but divine intervention\nI reckon it's again my turn\nTo win some or learn some\nBut I won't hesitate no more, no more\nIt cannot wait, I'm yours\n\nHmm (hey, hey)\nWell, open up your mind and see like me\nOpen up your plans and, damn, you're free\nLook into your heart and you'll find love, love, love, love\nListen to the music of the moment, people dance and sing\nWe're just one big family\nAnd it's our God-forsaken right to be loved, loved, loved, loved, loved\nSo I won't hesitate no more, no more\nIt cannot wait, I'm sure\nThere's no need to complicate\nOur time is short\nThis is our fate, I'm yours",
    );
    final bagianLirik = lagu.lirik.split('\n\n');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          lagu.judul,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${lagu.penyanyi}\n\n',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '${bagianLirik.first}\n\n',
                  style: const TextStyle(color: Colors.blue),
                ),
                TextSpan(
                  text: bagianLirik.last,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 15, height: 1.35),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'created by ${mahasiswa.nama}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
          const Divider(height: 1),
          Container(
            decoration: BoxDecoration(border: Border.all()),
            child: Row(
              children: [
                tombol(Icons.skip_previous, 'Sebelumnya'),
                tombol(Icons.pause, 'Jeda'),
                tombol(Icons.skip_next, 'Berikutnya'),
                tombol(Icons.fast_forward, 'Maju cepat'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tombol(IconData icon, String tooltip) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(border: Border(right: BorderSide())),
        child: IconButton(onPressed: () {}, tooltip: tooltip, icon: Icon(icon)),
      ),
    );
  }
}
