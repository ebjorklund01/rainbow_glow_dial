import 'package:flutter/material.dart';
import 'package:rainbow_glow_dial/rainbow_glow_dial.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rainbow Glow Dial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const _DialPreview(),
    );
  }
}

class _DialPreview extends StatelessWidget {
  const _DialPreview();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: RainbowGlowDial(
          initialValue: 30,
          min: 0,
          max: 40,
          unit: '°C',
          label: 'Living Room',
        ),
      ),
    );
  }
}
