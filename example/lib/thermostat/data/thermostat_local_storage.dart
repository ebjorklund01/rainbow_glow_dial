import 'package:shared_preferences/shared_preferences.dart';

/// Persists thermostat temperatures namespaced by room id using
/// [SharedPreferences].
class ThermostatLocalStorage {
  const ThermostatLocalStorage({required SharedPreferences preferences})
    : _preferences = preferences;

  static const String _keyPrefix = '__thermostat_temperature_';

  final SharedPreferences _preferences;

  /// Returns the stored temperature for [roomId], or `null` if no value has
  /// been persisted yet.
  double? readTemperature(String roomId) =>
      _preferences.getDouble('$_keyPrefix$roomId');

  /// Persists [temperature] for [roomId].
  Future<void> writeTemperature(String roomId, double temperature) =>
      _preferences.setDouble('$_keyPrefix$roomId', temperature);
}
