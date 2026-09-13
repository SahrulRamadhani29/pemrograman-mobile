import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_yours/lirik-im-yours.dart';

void main() {
  testWidgets("menampilkan lagu I'm Yours", (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LirikImYours()));

    expect(find.text("I'm Yours"), findsOneWidget);
    expect(find.textContaining('Jason Mraz'), findsOneWidget);
    expect(find.text('created by Rama'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });
}
