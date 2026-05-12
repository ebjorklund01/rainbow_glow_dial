part of 'thermostat_bloc.dart';

sealed class ThermostatEvent extends Equatable {
  const ThermostatEvent();

  @override
  List<Object> get props => [];
}

final class ThermostatTemperatureUpdated extends ThermostatEvent {
  const ThermostatTemperatureUpdated({required this.temperature});

  final double temperature;

  @override
  List<Object> get props => [temperature];
}

final class ThermostatTemperatureSubmitted extends ThermostatEvent {
  const ThermostatTemperatureSubmitted({required this.temperature});

  final double temperature;

  @override
  List<Object> get props => [temperature];
}
