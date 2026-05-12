part of 'thermostat_bloc.dart';

sealed class ThermostatEvent extends Equatable {
  const ThermostatEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Triggers loading the persisted temperature for the bloc's room and seeds a
/// default value when nothing is stored.
final class ThermostatStarted extends ThermostatEvent {
  const ThermostatStarted();
}

/// Reports an in-progress temperature change from the dial.
final class ThermostatTemperatureChanged extends ThermostatEvent {
  const ThermostatTemperatureChanged(this.temperature);

  final double temperature;

  @override
  List<Object?> get props => <Object?>[temperature];
}

/// Requests that [temperature] be persisted to storage.
final class ThermostatTemperatureSaveRequested extends ThermostatEvent {
  const ThermostatTemperatureSaveRequested(this.temperature);

  final double temperature;

  @override
  List<Object?> get props => <Object?>[temperature];
}
