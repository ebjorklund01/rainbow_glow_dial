import 'package:bloc_test/bloc_test.dart';
import 'package:example/thermostat/bloc/thermostat_bloc.dart';
import 'package:example/thermostat/repository/thermostat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockThermostatRepository extends Mock implements ThermostatRepository {}

void main() {
  group('ThermostatBloc', () {
    const roomId = 'living_room';
    late ThermostatRepository repository;

    setUp(() {
      repository = _MockThermostatRepository();
    });

    ThermostatBloc buildBloc() =>
        ThermostatBloc(roomId: roomId, repository: repository);

    test('initial state is ThermostatInitial', () {
      when(
        () => repository.readTemperature(any()),
      ).thenAnswer((_) async => null);

      expect(buildBloc().state, const ThermostatInitial());
    });

    group('ThermostatStarted', () {
      blocTest<ThermostatBloc, ThermostatState>(
        'seeds the default temperature when nothing is stored',
        setUp: () {
          when(
            () => repository.readTemperature(roomId),
          ).thenAnswer((_) async => null);
          when(
            () => repository.saveTemperature(roomId, 20),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ThermostatStarted()),
        expect: () => const <ThermostatState>[
          ThermostatReady(
            temperature: 20,
            saveStatus: ThermostatSaveStatus.saving,
          ),
          ThermostatReady(
            temperature: 20,
            saveStatus: ThermostatSaveStatus.saved,
          ),
        ],
        verify: (_) {
          verify(() => repository.saveTemperature(roomId, 20)).called(1);
        },
      );

      blocTest<ThermostatBloc, ThermostatState>(
        'emits the stored temperature when one exists and never saves',
        setUp: () {
          when(
            () => repository.readTemperature(roomId),
          ).thenAnswer((_) async => 23.5);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ThermostatStarted()),
        expect: () => const <ThermostatState>[
          ThermostatReady(
            temperature: 23.5,
            saveStatus: ThermostatSaveStatus.idle,
          ),
        ],
        verify: (_) {
          verifyNever(() => repository.saveTemperature(any(), any()));
        },
      );
    });

    group('ThermostatTemperatureChanged', () {
      blocTest<ThermostatBloc, ThermostatState>(
        'emits the new temperature with idle save status when ready',
        setUp: () {
          when(
            () => repository.readTemperature(roomId),
          ).thenAnswer((_) async => 20);
        },
        build: buildBloc,
        seed: () => const ThermostatReady(
          temperature: 20,
          saveStatus: ThermostatSaveStatus.saved,
        ),
        act: (bloc) => bloc.add(const ThermostatTemperatureChanged(24)),
        expect: () => const <ThermostatState>[
          ThermostatReady(
            temperature: 24,
            saveStatus: ThermostatSaveStatus.idle,
          ),
        ],
        verify: (_) {
          verifyNever(() => repository.saveTemperature(any(), any()));
        },
      );

      blocTest<ThermostatBloc, ThermostatState>(
        'is ignored when the state is not ready',
        build: buildBloc,
        act: (bloc) => bloc.add(const ThermostatTemperatureChanged(24)),
        expect: () => const <ThermostatState>[],
      );
    });

    group('ThermostatTemperatureSaveRequested', () {
      blocTest<ThermostatBloc, ThermostatState>(
        'emits saving then saved and persists the temperature',
        setUp: () {
          when(
            () => repository.saveTemperature(roomId, 25),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () => const ThermostatReady(
          temperature: 25,
          saveStatus: ThermostatSaveStatus.idle,
        ),
        act: (bloc) => bloc.add(const ThermostatTemperatureSaveRequested(25)),
        expect: () => const <ThermostatState>[
          ThermostatReady(
            temperature: 25,
            saveStatus: ThermostatSaveStatus.saving,
          ),
          ThermostatReady(
            temperature: 25,
            saveStatus: ThermostatSaveStatus.saved,
          ),
        ],
        verify: (_) {
          verify(() => repository.saveTemperature(roomId, 25)).called(1);
        },
      );
    });
  });
}
