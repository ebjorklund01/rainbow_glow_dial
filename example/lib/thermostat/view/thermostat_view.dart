import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/thermostat_bloc.dart';
import 'thermostat_dial.dart';

class ThermostatView extends StatelessWidget {
  const ThermostatView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: BlocProvider(
                create: (_) => ThermostatBloc(
                  roomName: 'Living Room',
                  initialTemperature: 30,
                ),
                child: const ThermostatDial(),
              ),
            ),
            Expanded(
              child: BlocProvider(
                create: (_) =>
                    ThermostatBloc(roomName: 'Bedroom', initialTemperature: 20),
                child: const ThermostatDial(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
