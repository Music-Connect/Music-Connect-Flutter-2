import 'package:flutter_test/flutter_test.dart';
import 'package:music_connect_mobile/main.dart';

void main() {
  testWidgets('App smoke test — splash screen monta', (WidgetTester tester) async {
    await tester.pumpWidget(const MusicConnectApp());
    expect(find.text('Music Connect'), findsOneWidget);
  });
}
