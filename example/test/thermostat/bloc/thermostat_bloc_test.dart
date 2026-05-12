import 'package:bloc_test/bloc_test.dart';
import 'package:example/thermostat/thermostat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ThermostatBloc, () {
    blocTest<ThermostatBloc, ThermostatState>(
      'emits $ThermostatTemperatureUpdateInProgress '
      'when temperature updates',
      build: () =>
          ThermostatBloc(roomName: 'Living Room', initialTemperature: 30),
      act: (bloc) =>
          bloc.add(const ThermostatTemperatureUpdated(temperature: 24)),
      expect: () => const <ThermostatState>[
        ThermostatTemperatureUpdateInProgress(
          roomName: 'Living Room',
          temperature: 24,
          minTemperature: 0,
          maxTemperature: 40,
          step: 1,
        ),
      ],
    );

    blocTest<ThermostatBloc, ThermostatState>(
      'emits $ThermostatSaveInProgress and $ThermostatSaveSuccess '
      'when temperature is submitted',
      build: () =>
          ThermostatBloc(roomName: 'Living Room', initialTemperature: 30),
      act: (bloc) =>
          bloc.add(const ThermostatTemperatureSubmitted(temperature: 24)),
      wait: const Duration(milliseconds: 300),
      expect: () => const <ThermostatState>[
        ThermostatSaveInProgress(
          roomName: 'Living Room',
          temperature: 24,
          minTemperature: 0,
          maxTemperature: 40,
          step: 1,
        ),
        ThermostatSaveSuccess(
          roomName: 'Living Room',
          temperature: 24,
          minTemperature: 0,
          maxTemperature: 40,
          step: 1,
        ),
      ],
    );

    blocTest<ThermostatBloc, ThermostatState>(
      'clamps temperature before saving',
      build: () => ThermostatBloc(
        roomName: 'Bedroom',
        initialTemperature: 20,
        minTemperature: 10,
        maxTemperature: 30,
      ),
      act: (bloc) =>
          bloc.add(const ThermostatTemperatureSubmitted(temperature: 40)),
      wait: const Duration(milliseconds: 300),
      expect: () => const <ThermostatState>[
        ThermostatSaveInProgress(
          roomName: 'Bedroom',
          temperature: 30,
          minTemperature: 10,
          maxTemperature: 30,
          step: 1,
        ),
        ThermostatSaveSuccess(
          roomName: 'Bedroom',
          temperature: 30,
          minTemperature: 10,
          maxTemperature: 30,
          step: 1,
        ),
      ],
    );
  });
}
