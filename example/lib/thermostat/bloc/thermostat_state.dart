part of 'thermostat_bloc.dart';

/// Persistence status for the current temperature.
enum ThermostatSaveStatus { idle, saving, saved }

sealed class ThermostatState extends Equatable {
  const ThermostatState();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Initial state before the stored temperature has been loaded.
final class ThermostatInitial extends ThermostatState {
  const ThermostatInitial();
}

/// Loaded state with the active [temperature] and persistence [saveStatus].
final class ThermostatReady extends ThermostatState {
  const ThermostatReady({required this.temperature, required this.saveStatus});

  final double temperature;
  final ThermostatSaveStatus saveStatus;

  ThermostatReady copyWith({
    double? temperature,
    ThermostatSaveStatus? saveStatus,
  }) {
    return ThermostatReady(
      temperature: temperature ?? this.temperature,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  List<Object?> get props => <Object?>[temperature, saveStatus];
}
