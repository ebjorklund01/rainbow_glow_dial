import 'package:bloc_test/bloc_test.dart';
import 'package:example/thermostat/bloc/thermostat_bloc.dart';
import 'package:example/thermostat/view/thermostat_dial_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rainbow_glow_dial/rainbow_glow_dial.dart';

class _MockThermostatBloc extends MockBloc<ThermostatEvent, ThermostatState>
    implements ThermostatBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ThermostatStarted());
    registerFallbackValue(const ThermostatInitial());
  });

  group('ThermostatDialView', () {
    const roomName = 'Living Room';
    late ThermostatBloc bloc;

    setUp(() {
      bloc = _MockThermostatBloc();
    });

    Future<void> pumpView(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<ThermostatBloc>.value(
              value: bloc,
              child: const ThermostatDialView(roomName: roomName),
            ),
          ),
        ),
      );
    }

    testWidgets('renders dial and room name when ready and idle', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const ThermostatReady(
          temperature: 20,
          saveStatus: ThermostatSaveStatus.idle,
        ),
      );

      await pumpView(tester);

      expect(find.byType(RainbowGlowDial), findsOneWidget);
      expect(find.text(roomName), findsOneWidget);
      expect(find.text('Saving…'), findsNothing);
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('shows "Saving…" when save status is saving', (tester) async {
      when(() => bloc.state).thenReturn(
        const ThermostatReady(
          temperature: 20,
          saveStatus: ThermostatSaveStatus.saving,
        ),
      );

      await pumpView(tester);

      expect(find.text('Saving…'), findsOneWidget);
    });

    testWidgets('shows "Saved" when save status is saved', (tester) async {
      when(() => bloc.state).thenReturn(
        const ThermostatReady(
          temperature: 20,
          saveStatus: ThermostatSaveStatus.saved,
        ),
      );

      await pumpView(tester);

      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('renders nothing visible when state is initial', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(const ThermostatInitial());

      await pumpView(tester);

      expect(find.byType(RainbowGlowDial), findsNothing);
      expect(find.text(roomName), findsNothing);
    });
  });
}
