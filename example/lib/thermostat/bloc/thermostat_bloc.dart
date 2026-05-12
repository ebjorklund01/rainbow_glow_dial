import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'thermostat_event.dart';
part 'thermostat_state.dart';

class ThermostatBloc extends Bloc<ThermostatEvent, ThermostatState> {
  ThermostatBloc({
    required String roomName,
    required double initialTemperature,
    double minTemperature = 0,
    double maxTemperature = 40,
    double step = 1,
  }) : super(
         ThermostatSaveSuccess(
           roomName: roomName,
           temperature: initialTemperature.clamp(
             minTemperature,
             maxTemperature,
           ),
           minTemperature: minTemperature,
           maxTemperature: maxTemperature,
           step: step,
         ),
       ) {
    on<ThermostatTemperatureUpdated>(_onTemperatureUpdated);
    on<ThermostatTemperatureSubmitted>(_onTemperatureSubmitted);
  }

  void _onTemperatureUpdated(
    ThermostatTemperatureUpdated event,
    Emitter<ThermostatState> emit,
  ) {
    final temperature = event.temperature.clamp(
      state.minTemperature,
      state.maxTemperature,
    );

    emit(
      ThermostatTemperatureUpdateInProgress(
        roomName: state.roomName,
        temperature: temperature,
        minTemperature: state.minTemperature,
        maxTemperature: state.maxTemperature,
        step: state.step,
      ),
    );
  }

  void _onTemperatureSubmitted(
    ThermostatTemperatureSubmitted event,
    Emitter<ThermostatState> emit,
  ) async {
    final temperature = event.temperature.clamp(
      state.minTemperature,
      state.maxTemperature,
    );

    emit(
      ThermostatSaveInProgress(
        roomName: state.roomName,
        temperature: temperature,
        minTemperature: state.minTemperature,
        maxTemperature: state.maxTemperature,
        step: state.step,
      ),
    );

    await _saveTemperature(temperature);

    emit(
      ThermostatSaveSuccess(
        roomName: state.roomName,
        temperature: temperature,
        minTemperature: state.minTemperature,
        maxTemperature: state.maxTemperature,
        step: state.step,
      ),
    );
  }

  Future<void> _saveTemperature(double temperature) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
