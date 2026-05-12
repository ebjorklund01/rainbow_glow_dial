import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainbow_glow_dial/rainbow_glow_dial.dart';

void main() {
  group(RainbowGlowDial, () {
    testWidgets('renders the static arc tube painter', (tester) async {
      await _pumpDial(tester, const RainbowGlowDial());

      expect(find.byType(RainbowGlowDial), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RainbowGlowDial),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );

      expect(_dialSize(tester), const Size(300, 300));
    });

    testWidgets('uses the preferred size when constraints allow', (
      tester,
    ) async {
      await _pumpDial(
        tester,
        const RainbowGlowDial(
          size: 180,
          padding: EdgeInsets.zero,
        ),
      );

      expect(_dialSize(tester), const Size(180, 180));
    });

    testWidgets('shrinks when loose parent constraints are smaller', (
      tester,
    ) async {
      await _pumpDial(
        tester,
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 240,
            maxHeight: 180,
          ),
          child: const RainbowGlowDial(padding: EdgeInsets.zero),
        ),
      );

      expect(_dialSize(tester), const Size(180, 180));
    });

    testWidgets('expands when tight square constraints require it', (
      tester,
    ) async {
      await _pumpDial(
        tester,
        const SizedBox.square(
          dimension: 420,
          child: RainbowGlowDial(
            size: 180,
            padding: EdgeInsets.zero,
          ),
        ),
      );

      expect(_dialSize(tester), const Size(420, 420));
    });

    testWidgets('applies default padding around the paint surface', (
      tester,
    ) async {
      await _pumpDial(tester, const RainbowGlowDial());

      expect(_dialSize(tester), const Size(300, 300));
      expect(_paintSize(tester), const Size(252, 252));
    });
  });
}

Future<void> _pumpDial(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

Size _dialSize(WidgetTester tester) {
  return tester.getSize(find.byType(RainbowGlowDial));
}

Size _paintSize(WidgetTester tester) {
  final paintFinder = find.descendant(
    of: find.byType(RainbowGlowDial),
    matching: find.byType(CustomPaint),
  );

  return tester.getSize(paintFinder);
}
