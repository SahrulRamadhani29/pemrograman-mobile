import 'package:flutter_test/flutter_test.dart';
import 'package:profil_mahasiswa/main.dart';

void main() {
  testWidgets('menampilkan identitas mahasiswa', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Sahrul Ramadhani'), findsOneWidget);
    expect(find.text('244107020058'), findsOneWidget);
    expect(find.text('TI-3C'), findsOneWidget);
    expect(find.text('Politeknik Negeri Malang'), findsOneWidget);
  });
}
