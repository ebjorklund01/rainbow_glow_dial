import 'package:example/thermostat/data/thermostat_local_storage.dart';

/// Coordinates thermostat persistence on top of [ThermostatLocalStorage].
class ThermostatRepository {
  const ThermostatRepository({required ThermostatLocalStorage localStorage})
    : _localStorage = localStorage;

  final ThermostatLocalStorage _localStorage;

  /// Reads the stored temperature for [roomId]. Returns `null` when no value
  /// has been saved yet.
  Future<double?> readTemperature(String roomId) async =>
      _localStorage.readTemperature(roomId);

  /// Persists [temperature] for [roomId].
  Future<void> saveTemperature(String roomId, double temperature) =>
      _localStorage.writeTemperature(roomId, temperature);
}
