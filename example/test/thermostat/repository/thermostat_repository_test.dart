import 'package:example/thermostat/data/thermostat_local_storage.dart';
import 'package:example/thermostat/repository/thermostat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockThermostatLocalStorage extends Mock
    implements ThermostatLocalStorage {}

void main() {
  group('ThermostatRepository', () {
    const roomId = 'living_room';
    late ThermostatLocalStorage localStorage;
    late ThermostatRepository repository;

    setUp(() {
      localStorage = _MockThermostatLocalStorage();
      repository = ThermostatRepository(localStorage: localStorage);
    });

    test('readTemperature delegates to local storage', () async {
      when(() => localStorage.readTemperature(roomId)).thenReturn(22.5);

      final result = await repository.readTemperature(roomId);

      expect(result, 22.5);
      verify(() => localStorage.readTemperature(roomId)).called(1);
    });

    test(
      'readTemperature returns null when local storage has no value',
      () async {
        when(() => localStorage.readTemperature(roomId)).thenReturn(null);

        final result = await repository.readTemperature(roomId);

        expect(result, isNull);
      },
    );

    test('saveTemperature forwards arguments to local storage', () async {
      when(
        () => localStorage.writeTemperature(roomId, 18),
      ).thenAnswer((_) async {});

      await repository.saveTemperature(roomId, 18);

      verify(() => localStorage.writeTemperature(roomId, 18)).called(1);
    });
  });
}
