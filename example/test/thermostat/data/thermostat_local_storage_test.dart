import 'package:example/thermostat/data/thermostat_local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThermostatLocalStorage', () {
    const roomId = 'living_room';
    const expectedKey = '__thermostat_temperature_living_room';

    Future<ThermostatLocalStorage> buildStorage([
      Map<String, Object> initialValues = const <String, Object>{},
    ]) async {
      SharedPreferences.setMockInitialValues(initialValues);
      final preferences = await SharedPreferences.getInstance();
      return ThermostatLocalStorage(preferences: preferences);
    }

    test('readTemperature returns null when nothing is stored', () async {
      final storage = await buildStorage();

      expect(storage.readTemperature(roomId), isNull);
    });

    test('readTemperature returns the persisted value', () async {
      final storage = await buildStorage(<String, Object>{expectedKey: 21.5});

      expect(storage.readTemperature(roomId), 21.5);
    });

    test(
      'writeTemperature persists the value under the namespaced key',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final preferences = await SharedPreferences.getInstance();
        final storage = ThermostatLocalStorage(preferences: preferences);

        await storage.writeTemperature(roomId, 19);

        expect(preferences.getDouble(expectedKey), 19);
      },
    );
  });
}
