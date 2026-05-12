import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rainbow_glow_dial/rainbow_glow_dial.dart';

import '../bloc/thermostat_bloc.dart';

class ThermostatDial extends StatelessWidget {
  const ThermostatDial({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThermostatBloc, ThermostatState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: RainbowGlowDial(
                initialValue: state.temperature,
                min: state.minTemperature,
                max: state.maxTemperature,
                step: state.step,
                unit: '°C',
                label: state.roomName,
                onChangeEnd: (temperature) {
                  context.read<ThermostatBloc>().add(
                    ThermostatTemperatureSubmitted(temperature: temperature),
                  );
                },
                onChanged: (temperature) {
                  context.read<ThermostatBloc>().add(
                    ThermostatTemperatureUpdated(temperature: temperature),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _statusText(state),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _statusText(ThermostatState state) {
    return switch (state) {
      ThermostatTemperatureUpdateInProgress() => 'updating....',
      ThermostatSaveInProgress() => 'updating....',
      ThermostatSaveSuccess() => 'saved',
    };
  }
}
