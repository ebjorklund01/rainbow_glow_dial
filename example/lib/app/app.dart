import 'package:example/thermostat/thermostat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Root widget for the example app.
///
/// Provides a single [ThermostatRepository] to the widget tree and renders the
/// thermostat home with a dial per room.
class ExampleApp extends StatelessWidget {
  const ExampleApp({required this.thermostatRepository, super.key});

  final ThermostatRepository thermostatRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ThermostatRepository>.value(
      value: thermostatRepository,
      child: MaterialApp(
        title: 'Rainbow Glow Dial',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          useMaterial3: true,
        ),
        home: const _ThermostatHome(),
      ),
    );
  }
}

class _ThermostatHome extends StatelessWidget {
  const _ThermostatHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ThermostatDialPage(
                roomId: 'living_room',
                roomName: 'Living Room',
              ),
            ),
            Expanded(
              child: ThermostatDialPage(roomId: 'bedroom', roomName: 'Bedroom'),
            ),
          ],
        ),
      ),
    );
  }
}
