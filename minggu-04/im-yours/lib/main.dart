import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'lirik.dart';
import 'mahasiswa.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: AplikasiLirik()),
);

class AplikasiLirik extends StatefulWidget {
  const AplikasiLirik({super.key});

  @override
  State<AplikasiLirik> createState() => _AplikasiLirikState();
}

class _AplikasiLirikState extends State<AplikasiLirik> {
  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(false);
  late final Future<void> _persiapanAudio;
  StreamSubscription<PlayerState>? _statusSubscription;

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
  void initState() {
    super.initState();
    _persiapanAudio = _player.setAsset("assets/I'm Yours.mp3");
    _statusSubscription = _player.playerStateStream.listen((state) {
      _isPlaying.value = state.playing;
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _isPlaying.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _putarJeda() async {
    if (_isPlaying.value) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _mundur() async {
    final posisi = _player.position - const Duration(seconds: 10);
    await _player.seek(posisi < Duration.zero ? Duration.zero : posisi);
  }

  Future<void> _maju() async {
    final durasi = _player.duration ?? Duration.zero;
    final posisi = _player.position + const Duration(seconds: 10);
    await _player.seek(posisi > durasi ? durasi : posisi);
  }

  Future<void> _keAkhir() async {
    final durasi = _player.duration;
    if (durasi != null) {
      await _player.seek(durasi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _halamanUtama();
  }

  Widget _halamanUtama() {
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
      bottomNavigationBar: _kontrolBawah(),
    );
  }

  Widget _kontrolBawah() {
    return FutureBuilder<void>(
      future: _persiapanAudio,
      builder: (context, snapshot) => _kontrolAudio(),
    );
  }

  Widget _kontrolAudio() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<Duration>(
          stream: _player.positionStream,
          builder: (context, snapshot) {
            final posisi = snapshot.data ?? Duration.zero;
            final durasi = _player.duration ?? Duration.zero;
            final nilai = durasi.inMilliseconds == 0
                ? 0.0
                : (posisi.inMilliseconds / durasi.inMilliseconds).clamp(
                    0.0,
                    1.0,
                  );
            return Column(
              children: [
                Slider(
                  value: nilai,
                  onChanged: durasi == Duration.zero
                      ? null
                      : (value) => _player.seek(
                          Duration(
                            milliseconds: (durasi.inMilliseconds * value)
                                .round(),
                          ),
                        ),
                ),
                Text(
                  '${_formatWaktu(posisi)} / ${_formatWaktu(durasi)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            );
          },
        ),
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
              tombol(Icons.skip_previous, 'Mundur 10 detik', _mundur),
              ValueListenableBuilder<bool>(
                valueListenable: _isPlaying,
                builder: (context, sedangDiputar, child) {
                  return tombol(
                    sedangDiputar ? Icons.pause : Icons.play_arrow,
                    sedangDiputar ? 'Jeda' : 'Putar',
                    _putarJeda,
                  );
                },
              ),
              tombol(Icons.skip_next, 'Maju 10 detik', _maju),
              tombol(Icons.fast_forward, 'Ke akhir lagu', _keAkhir),
            ],
          ),
        ),
      ],
    );
  }

  Widget tombol(IconData icon, String tooltip, VoidCallback aksi) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(border: Border(right: BorderSide())),
        child: IconButton(onPressed: aksi, tooltip: tooltip, icon: Icon(icon)),
      ),
    );
  }

  String _formatWaktu(Duration waktu) {
    final menit = waktu.inMinutes.remainder(60).toString().padLeft(2, '0');
    final detik = waktu.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$menit:$detik';
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
