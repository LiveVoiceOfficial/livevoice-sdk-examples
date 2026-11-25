// Default interface
//
// The smallest integration: LiveVoiceView lists the joined event's channels
// and plays the one a listener taps. It also shows loading, reconnecting,
// errors, an event without channels and the LiveVoice branding by itself.
//
// In Flutter, `initialize` must have completed before the first LiveVoiceView
// is built and before `joinEvent`; this app awaits it in `main` (see
// main.dart). LiveVoiceView follows the platform's light or dark appearance,
// not your app's ThemeMode; pass `isDarkMode` to force one.
//
// Uses: LiveVoiceView
// See also: Joining an event (how the event is joined), Filtering channels,
// Custom channel cell, Subtitles, Audio output.

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_screen.dart';

class DefaultInterfaceScreen extends StatelessWidget {
  const DefaultInterfaceScreen({super.key});

  @override
  Widget build(BuildContext context) => const DemoScreen(
    title: 'Default interface',
    caption: 'Tap a channel to listen.',
    children: [
      DemoSection('Channels', children: [LiveVoiceView()]),
    ],
  );
}
