import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainbow_glow_dial/rainbow_glow_dial.dart';

void main() {
  group(RainbowGlowDial, () {
    testWidgets('renders the static arc tube painter at the checkpoint size', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RainbowGlowDial(),
          ),
        ),
      );

      expect(find.byType(RainbowGlowDial), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RainbowGlowDial),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );

      final size = tester.getSize(find.byType(RainbowGlowDial));
      expect(size, const Size(300, 300));
    });
  });
}
