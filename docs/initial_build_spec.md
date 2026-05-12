# Rainbow Glow Dial

## Initial Build Spec

I build out a Flutter package widget. The widget is located at @lib/src/rainbow_glow_dial.dart

## Features
The goal is to build a glowing arc dial. The dial should have the following features:
- Rounded track with transparent center
- Blue inner glow
- Crisp light-blue rim
- Centered value with optional unit/label
- Draggable thumb with min/max/step
- Smooth blue-to-red thumb color

### Reference: track

Target silhouette, rim, and inner glow for the rounded track (palette in the feature list still applies).

![Green track](/docs/images/track-green.png)

![Green track, alternate view](/docs/images/track-green-2.png)

![Yellow track](/docs/images/track-yellow.png)

![Red track](/docs/images/track-red.png)

## Build Sequentially

Build sequentially in small checkpoints. Don't add features from later checkpoints.

Checkpoints:
1. Straight tube (rim + inner glow)
2. Bend into arc
3. Arc fills with value
4. Center value and label
5. Thumb glow
6. Drag interaction
7. Value-driven thumb colors


