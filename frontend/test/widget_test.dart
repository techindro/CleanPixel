import 'package:flutter_test/flutter_test.dart';
import 'package:cleanpixel_ai/main.dart';

void main() {
  testWidgets('CleanPixel AI app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const CleanPixelApp());
    expect(find.text('CleanPixel AI'), findsWidgets);
  });
}
