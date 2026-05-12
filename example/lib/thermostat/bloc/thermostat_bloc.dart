import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:example/thermostat/repository/thermostat_repository.dart';

part 'thermostat_event.dart';
part 'thermostat_state.dart';

/// Manages the temperature for a single room, loading and persisting through
/// [ThermostatRepository].
class ThermostatBloc extends Bloc<ThermostatEvent, ThermostatState> {
  ThermostatBloc({
    required this.roomId,
    required ThermostatRepository repository,
  }) : _repository = repository,
       super(const ThermostatInitial()) {
    on<ThermostatStarted>(_onStarted);
    on<ThermostatTemperatureChanged>(_onTemperatureChanged);
    on<ThermostatTemperatureSaveRequested>(_onTemperatureSaveRequested);
  }

  static const double _defaultTemperature = 20;

  final String roomId;
  final ThermostatRepository _repository;

  Future<void> _onStarted(
    ThermostatStarted event,
    Emitter<ThermostatState> emit,
  ) async {
    final stored = await _repository.readTemperature(roomId);
    if (stored != null) {
      emit(
        ThermostatReady(
          temperature: stored,
          saveStatus: ThermostatSaveStatus.idle,
        ),
      );
      return;
    }

    emit(
      const ThermostatReady(
        temperature: _defaultTemperature,
        saveStatus: ThermostatSaveStatus.saving,
      ),
    );
    await _repository.saveTemperature(roomId, _defaultTemperature);
    emit(
      const ThermostatReady(
        temperature: _defaultTemperature,
        saveStatus: ThermostatSaveStatus.saved,
      ),
    );
  }

  void _onTemperatureChanged(
    ThermostatTemperatureChanged event,
    Emitter<ThermostatState> emit,
  ) {
    final current = state;
    if (current is! ThermostatReady) return;
    emit(
      current.copyWith(
        temperature: event.temperature,
        saveStatus: ThermostatSaveStatus.idle,
      ),
    );
  }

  Future<void> _onTemperatureSaveRequested(
    ThermostatTemperatureSaveRequested event,
    Emitter<ThermostatState> emit,
  ) async {
    emit(
      ThermostatReady(
        temperature: event.temperature,
        saveStatus: ThermostatSaveStatus.saving,
      ),
    );
    await _repository.saveTemperature(roomId, event.temperature);
    emit(
      ThermostatReady(
        temperature: event.temperature,
        saveStatus: ThermostatSaveStatus.saved,
      ),
    );
  }
}
