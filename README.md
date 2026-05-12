# Rainbow Glow Dial

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A glowing 270° arc dial widget for Flutter — interactive, value‑driven, with a
thumb that shifts hue from blue through red as the value rises.

The widget renders a custom‑painted arc tube with an inner glow, a halo around
the thumb, an optional value/unit readout, and an optional pill label. Tap and
drag map cleanly to the arc; values can be discretized via `step`.

## Usage

### Minimal

```dart
import 'package:flutter/material.dart';
import 'package:rainbow_glow_dial/rainbow_glow_dial.dart';

class MyDial extends StatelessWidget {
  const MyDial({super.key});

  @override
  Widget build(BuildContext context) {
    return const RainbowGlowDial(
      initialValue: 0.5,
    );
  }
}
```

### Custom range, units, and label

```dart
RainbowGlowDial(
  initialValue: 22,
  min: 0,
  max: 40,
  step: 0.5,
  unit: '°C',
  label: 'Living Room',
);
```

`step` controls the granularity of the displayed and emitted value while
keeping the underlying arc progress smooth. Decimal steps (`0.1`, `0.25`, …)
are snapped to the precision implied by `step` and `min` so callbacks and the
readout stay free of floating‑point noise.

### Reading values

`RainbowGlowDial` is uncontrolled — `initialValue` seeds the dial and the
widget owns its own progress after that. Use the callbacks to observe changes
and to persist the final value:

```dart
RainbowGlowDial(
  initialValue: temperature,
  min: 0,
  max: 40,
  step: 1,
  unit: '°C',
  onChangeStart: (value) => print('start: $value'),
  onChanged: (value) => print('changed: $value'),
  onChangeEnd: (value) => repository.save(value),
);
```

`onChanged` fires for every tap and drag update. `onChangeStart` /
`onChangeEnd` bracket each interaction, which makes `onChangeEnd` the right
hook for committing the value to storage.

### Sizing

The dial is square. By default it prefers `300×300` but yields to tighter
parent constraints and expands to fill tight ones.

```dart
RainbowGlowDial(size: 240);            // preferred 240×240
SizedBox.square(                       // forced 180×180
  dimension: 180,
  child: RainbowGlowDial(),
);
```

`padding` (defaults to `EdgeInsets.all(24)`) controls the gap between the
widget bounds and the painted arc.

## API

| Parameter | Type | Default | Notes |
| --- | --- | --- | --- |
| `size` | `double?` | `300` | Preferred square side; constrained by parent. |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(24)` | Inset between bounds and arc. |
| `initialValue` | `double` | `0` | Seeds internal progress; clamped to `[min, max]`. |
| `min` / `max` | `double` | `0` / `1` | Asserts `min <= max`. |
| `step` | `double?` | `null` | If set, snaps display + callback values; asserts `step > 0`. |
| `label` | `String?` | `null` | Shown in a rounded pill below the value. |
| `unit` | `String?` | `null` | Appended directly after the value (e.g. `°C`). |
| `onChangeStart` | `ValueChanged<double>?` | `null` | Fires when a tap or drag begins. |
| `onChanged` | `ValueChanged<double>?` | `null` | Fires for every tap and drag update. |
| `onChangeEnd` | `ValueChanged<double>?` | `null` | Fires when interaction ends or cancels. |

## Example

The repository ships with a thermostat demo under [`example/`](example/) that
wires two `RainbowGlowDial`s to a `bloc`‑backed thermostat feature with
`shared_preferences` persistence.

```sh
cd example
flutter run
```

## Running tests

```sh
flutter test
```

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
