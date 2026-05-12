import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainbow_glow_dial/rainbow_glow_dial.dart';

void main() {
  group(RainbowGlowDial, () {
    test('uses the default value range', () {
      const dial = RainbowGlowDial();

      expect(dial.initialValue, 0);
      expect(dial.min, 0);
      expect(dial.max, 1);
    });

    test('asserts when min is greater than max', () {
      expect(
        () => RainbowGlowDial(min: 1, max: 0),
        throwsAssertionError,
      );
    });

    test('asserts when step is not greater than zero', () {
      expect(
        () => RainbowGlowDial(step: 0),
        throwsAssertionError,
      );
    });

    test('allows min to equal max', () {
      expect(
        () => const RainbowGlowDial(min: 2, max: 2),
        returnsNormally,
      );
    });

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

    testWidgets('builds when initial value is clamped to the range', (
      tester,
    ) async {
      for (final initialValue in <double>[-10, 5, 20]) {
        await _pumpDial(
          tester,
          RainbowGlowDial(
            initialValue: initialValue,
            max: 10,
          ),
        );

        expect(find.byType(RainbowGlowDial), findsOneWidget);
      }
    });

    testWidgets('renders progress for a non-default value range', (
      tester,
    ) async {
      await _pumpDial(
        tester,
        const RainbowGlowDial(
          initialValue: 75,
          min: 50,
          max: 100,
        ),
      );

      expect(
        find.descendant(
          of: find.byType(RainbowGlowDial),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows the default center value', (tester) async {
      await _pumpDial(tester, const RainbowGlowDial());

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('formats whole values with a directly appended unit', (
      tester,
    ) async {
      await _pumpDial(
        tester,
        const RainbowGlowDial(
          initialValue: 40,
          max: 100,
          unit: '°C',
        ),
      );

      expect(find.text('40°C'), findsOneWidget);
    });

    testWidgets('formats non-whole values with decimals', (tester) async {
      await _pumpDial(
        tester,
        const RainbowGlowDial(
          initialValue: 40.5,
          max: 100,
        ),
      );

      expect(find.text('40.5'), findsOneWidget);
    });

    testWidgets(
      'rounds floating-point noise from decimal step values',
      (tester) async {
        await _pumpDial(
          tester,
          const RainbowGlowDial(
            initialValue: 24.4,
            max: 40,
            step: 0.1,
            unit: '°C',
          ),
        );

        expect(find.text('24.4°C'), findsOneWidget);
      },
    );

    testWidgets('shows clamped values below and above the range', (
      tester,
    ) async {
      await _pumpDial(
        tester,
        const RainbowGlowDial(
          initialValue: -10,
          min: 10,
          max: 20,
        ),
      );

      expect(find.text('10'), findsOneWidget);

      await _pumpDial(
        tester,
        const RainbowGlowDial(
          key: Key('above-range'),
          initialValue: 30,
          min: 10,
          max: 20,
        ),
      );

      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('shows a label pill when label is provided', (tester) async {
      await _pumpDial(
        tester,
        const RainbowGlowDial(label: 'Living room'),
      );

      expect(find.text('Living room'), findsOneWidget);
    });

    testWidgets('hides the label pill when label is null', (tester) async {
      await _pumpDial(tester, const RainbowGlowDial());

      expect(find.text('Living room'), findsNothing);
    });

    testWidgets('builds thumb states for zero, mid, and full progress', (
      tester,
    ) async {
      const dials = <RainbowGlowDial>[
        RainbowGlowDial(),
        RainbowGlowDial(initialValue: 0.5),
        RainbowGlowDial(initialValue: 1),
      ];

      for (final dial in dials) {
        await _pumpDial(tester, dial);

        expect(
          find.descendant(
            of: find.byType(RainbowGlowDial),
            matching: find.byType(CustomPaint),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('updates its displayed value after a tap', (tester) async {
      await _pumpDial(
        tester,
        const RainbowGlowDial(max: 100),
      );

      await tester.tapAt(_pointForProgress(tester, 1));
      await tester.pump();

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('updates its displayed value during a drag', (tester) async {
      await _pumpDial(
        tester,
        const RainbowGlowDial(max: 100),
      );

      final start = _pointForProgress(tester, 0);
      final middle = _pointForProgress(tester, 0.5);
      await tester.dragFrom(start, middle - start);
      await tester.pump();

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('calls change callbacks with range values for taps', (
      tester,
    ) async {
      final starts = <double>[];
      final changes = <double>[];
      final ends = <double>[];

      await _pumpDial(
        tester,
        RainbowGlowDial(
          max: 100,
          onChangeStart: starts.add,
          onChanged: changes.add,
          onChangeEnd: ends.add,
        ),
      );

      await tester.tapAt(_pointForProgress(tester, 1));
      await tester.pump();

      expect(starts, equals(<double>[100]));
      expect(changes, equals(<double>[100]));
      expect(ends, equals(<double>[100]));
    });

    testWidgets('calls change start and end callbacks for pans', (
      tester,
    ) async {
      final starts = <double>[];
      final ends = <double>[];

      await _pumpDial(
        tester,
        RainbowGlowDial(
          max: 100,
          onChangeStart: starts.add,
          onChangeEnd: ends.add,
        ),
      );

      final start = _pointForProgress(tester, 0);
      final middle = _pointForProgress(tester, 0.5);
      await tester.dragFrom(start, middle - start);
      await tester.pump();

      expect(starts, isNotEmpty);
      expect(ends, isNotEmpty);
    });

    testWidgets('applies step to displayed and callback values', (
      tester,
    ) async {
      final changes = <double>[];

      await _pumpDial(
        tester,
        RainbowGlowDial(
          max: 10,
          step: 2,
          onChanged: changes.add,
        ),
      );

      await tester.tapAt(_pointForProgress(tester, 0.35));
      await tester.pump();

      expect(find.text('4'), findsOneWidget);
      expect(changes, equals(<double>[4]));
    });

    testWidgets('maps a lower-left gap tap to the minimum value', (
      tester,
    ) async {
      await _pumpDial(
        tester,
        const RainbowGlowDial(
          initialValue: 100,
          max: 100,
        ),
      );

      await tester.tapAt(_pointForAngle(tester, 0.70 * pi));
      await tester.pump();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('100'), findsNothing);
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

Offset _pointForProgress(WidgetTester tester, double progress) {
  return _pointForAngle(tester, (0.75 * pi) + ((1.5 * pi) * progress));
}

Offset _pointForAngle(WidgetTester tester, double angle) {
  final paintFinder = find.descendant(
    of: find.byType(RainbowGlowDial),
    matching: find.byType(CustomPaint),
  );
  final topLeft = tester.getTopLeft(paintFinder);
  final size = tester.getSize(paintFinder);
  final center = topLeft + Offset(size.width / 2, size.height / 2);
  final radius = ((size.shortestSide - 1) / 2) - (35 / 2);

  return center + Offset(cos(angle) * radius, sin(angle) * radius);
}
