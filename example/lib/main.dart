import 'package:example/app/app.dart';
import 'package:example/thermostat/thermostat.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final localStorage = ThermostatLocalStorage(preferences: preferences);
  final repository = ThermostatRepository(localStorage: localStorage);

  runApp(ExampleApp(thermostatRepository: repository));
}
