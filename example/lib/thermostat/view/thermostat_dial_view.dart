import 'package:example/thermostat/bloc/thermostat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rainbow_glow_dial/rainbow_glow_dial.dart';

/// Renders the [RainbowGlowDial] for the active thermostat state along with a
/// per-dial save status line.
class ThermostatDialView extends StatelessWidget {
  const ThermostatDialView({required this.roomName, super.key});

  final String roomName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThermostatBloc, ThermostatState>(
      builder: (context, state) {
        return switch (state) {
          ThermostatInitial() => const SizedBox.shrink(),
          ThermostatReady(:final temperature, :final saveStatus) => _ReadyDial(
            roomName: roomName,
            temperature: temperature,
            saveStatus: saveStatus,
          ),
        };
      },
    );
  }
}

class _ReadyDial extends StatelessWidget {
  const _ReadyDial({
    required this.roomName,
    required this.temperature,
    required this.saveStatus,
  });

  final String roomName;
  final double temperature;
  final ThermostatSaveStatus saveStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: RainbowGlowDial(
            initialValue: temperature,
            min: 0,
            max: 40,
            step: 1,
            unit: '°C',
            label: roomName,
            onChanged: (value) => context.read<ThermostatBloc>().add(
              ThermostatTemperatureChanged(value),
            ),
            onChangeEnd: (value) => context.read<ThermostatBloc>().add(
              ThermostatTemperatureSaveRequested(value),
            ),
          ),
        ),
        _SaveStatusText(saveStatus: saveStatus),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SaveStatusText extends StatelessWidget {
  const _SaveStatusText({required this.saveStatus});

  final ThermostatSaveStatus saveStatus;

  @override
  Widget build(BuildContext context) {
    final label = switch (saveStatus) {
      ThermostatSaveStatus.idle => '',
      ThermostatSaveStatus.saving => 'Saving…',
      ThermostatSaveStatus.saved => 'Saved',
    };
    final theme = Theme.of(context);
    return SizedBox(
      height: 20,
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
    );
  }
}
