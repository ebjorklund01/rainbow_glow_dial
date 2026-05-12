import 'package:flutter/material.dart';

import 'thermostat_view.dart';

class ThermostatPage extends StatelessWidget {
  const ThermostatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: ThermostatView(),
    );
  }
}
