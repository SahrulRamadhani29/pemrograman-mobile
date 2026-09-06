import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF12312B);
    const cream = Color(0xFFF5F0E6);
    const orange = Color(0xFFF26B38);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profil Mahasiswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ink,
          primary: ink,
          secondary: orange,
          surface: cream,
        ),
        scaffoldBackgroundColor: cream,
        useMaterial3: true,
      ),
      home: const ProfilMahasiswaPage(),
    );
  }
}

class ProfilMahasiswaPage extends StatelessWidget {
  const ProfilMahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF12312B);
    const cream = Color(0xFFF5F0E6);
    const orange = Color(0xFFF26B38);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 700
                ? 620.0
                : double.infinity;

            return Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -70,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: const BoxDecoration(
                      color: orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -110,
                  left: -80,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: ink.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: SizedBox(
                      width: cardWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            'PEMROGRAMAN MOBILE / WEEK 01',
                            style: TextStyle(
                              color: orange,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Profil\nMahasiswa',
                            style: TextStyle(
                              color: ink,
                              fontSize: 48,
                              height: 0.95,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: ink,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33202C28),
                                  blurRadius: 28,
                                  offset: Offset(0, 14),
                                ),
                              ],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: orange,
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: cream,
                                    size: 40,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Sahrul Ramadhani',
                                  style: TextStyle(
                                    color: cream,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Mahasiswa D4 Teknik Informatika',
                                  style: TextStyle(
                                    color: Color(0xFFB8C7C2),
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 28),
                                Divider(color: Color(0xFF315149)),
                                SizedBox(height: 16),
                                _InfoRow(
                                  icon: Icons.badge_outlined,
                                  label: 'NIM',
                                  value: '244107020058',
                                ),
                                SizedBox(height: 16),
                                _InfoRow(
                                  icon: Icons.groups_2_outlined,
                                  label: 'Kelas',
                                  value: 'TI-3C',
                                ),
                                SizedBox(height: 16),
                                _InfoRow(
                                  icon: Icons.apartment_rounded,
                                  label: 'Kampus',
                                  value: 'Politeknik Negeri Malang',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Dibuat dengan Dart + Flutter',
                            style: TextStyle(
                              color: ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFF26B38), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF8FA9A1),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFF5F0E6),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
