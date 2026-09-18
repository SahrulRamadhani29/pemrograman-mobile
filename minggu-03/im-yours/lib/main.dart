import 'package:flutter/material.dart';

import 'lirik.dart';
import 'mahasiswa.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: AplikasiLirik()),
);

class AplikasiLirik extends StatelessWidget {
  const AplikasiLirik({super.key});

  static const mahasiswa = Mahasiswa(
    nama: 'Sahrul Ramadhani',
    nim: '244107020058',
    kelas: 'TI-3C',
  );

  static const halamanPertama = '''Well, you done done me in, you bet I felt it
I tried to be chill, but you're so hot that I melted
I fell right through the cracks
Now I'm trying to get back
Before the cool done run out
I'll be giving it my bestest
And nothing's gonna stop me but divine intervention
I reckon it's again my turn
To win some or learn some
But I won't hesitate no more, no more
It cannot wait, I'm yours
Hmm (hey, hey)
Well, open up your mind and see like me
Open up your plans and, damn, you're free
Look into your heart and you'll find love, love, love, love
Listen to the music of the moment, people dance and sing
We're just one big family
And it's our God-forsaken right to be loved, loved, loved, loved, loved
So I won't hesitate no more, no more
It cannot wait, I'm sure
There's no need to complicate
Our time is short
This is our fate, I'm yours
Do, do, do, do you, but do you, do you, do, do, but do you want to come on
Scooch on over closer, dear?
And I will nibble your ear
A-soo-da-ba-ba-ba-ba-bum
Whoa-oh-oh
Whoa-oh-oh-oh-oh-whoa-whoa-whoa
Uh-huh, mmm-hmm''';
  static const halamanKedua =
      '''I've been spending way too long checking my tongue in the mirror
And bending over backwards just to try to see it clearer
But my breath fogged up the glass
And so I drew a new face and I laughed
I guess what I be saying is there ain't no better reason
To rid yourself of vanities and just go with the seasons
It's what we aim to do
Our name is our virtue
But I won't hesitate no more, no more
It cannot wait, I'm yours
Well, open up your mind and see like me (I won't hesitate)
Open up your plans and, damn, you're free (no more, no more)
And look into your heart, and you'll find (it cannot wait)
That the sky is yours (I'm sure)
So please don't, please don't, please don't (no need to complicate)
There's no need to complicate (our time is short)
'Cause our time is short (this is)
This, oh this, this is our fate (our fate)
I'm yours
Bra-bop-mm, da-bap-bop-mm-day
Do-do-do-do, do-do-do-do, do-do-do, mm-mm-mm-mm (hey, hey)
Oh, I'm yours
Oh, I'm yours
Oh, whoa, baby, do you believe I'm yours?
You best believe, you best believe I'm yours, mmm-hmm''';

  @override
  Widget build(BuildContext context) {
    const lagu = Lirik(
      judul: "I'm Yours",
      penyanyi: 'Jason Mraz',
      lirik: halamanPertama,
    );

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Image.asset(
                'assets/images/cover.jpg',
                key: const Key('cover-lagu'),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lagu.penyanyi,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: PageView(
                      key: const Key('halaman-lirik'),
                      children: const [
                        HalamanLirik(teks: halamanPertama, warna: Colors.blue),
                        HalamanLirik(teks: halamanKedua, warna: Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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

class HalamanLirik extends StatelessWidget {
  const HalamanLirik({required this.teks, required this.warna, super.key});

  final String teks;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        teks,
        softWrap: true,
        style: TextStyle(color: warna, fontSize: 16, height: 1.3),
      ),
    );
  }
}
