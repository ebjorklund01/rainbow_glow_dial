import 'package:example/thermostat/bloc/thermostat_bloc.dart';
import 'package:example/thermostat/repository/thermostat_repository.dart';
import 'package:example/thermostat/view/thermostat_dial_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Provides a [ThermostatBloc] for the given room and renders its dial view.
class ThermostatDialPage extends StatelessWidget {
  const ThermostatDialPage({
    required this.roomId,
    required this.roomName,
    super.key,
  });

  final String roomId;
  final String roomName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThermostatBloc>(
      create: (context) => ThermostatBloc(
        roomId: roomId,
        repository: context.read<ThermostatRepository>(),
      )..add(const ThermostatStarted()),
      child: ThermostatDialView(roomName: roomName),
    );
  }
}
