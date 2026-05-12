part of 'thermostat_bloc.dart';

sealed class ThermostatState extends Equatable {
  const ThermostatState({
    required this.roomName,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.step,
  });

  final String roomName;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final double step;

  @override
  List<Object> get props => [
    roomName,
    temperature,
    minTemperature,
    maxTemperature,
    step,
  ];
}

final class ThermostatSaveInProgress extends ThermostatState {
  const ThermostatSaveInProgress({
    required super.roomName,
    required super.temperature,
    required super.minTemperature,
    required super.maxTemperature,
    required super.step,
  });
}

final class ThermostatTemperatureUpdateInProgress extends ThermostatState {
  const ThermostatTemperatureUpdateInProgress({
    required super.roomName,
    required super.temperature,
    required super.minTemperature,
    required super.maxTemperature,
    required super.step,
  });
}

final class ThermostatSaveSuccess extends ThermostatState {
  const ThermostatSaveSuccess({
    required super.roomName,
    required super.temperature,
    required super.minTemperature,
    required super.maxTemperature,
    required super.step,
  });
}
