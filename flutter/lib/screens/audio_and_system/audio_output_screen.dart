// Audio output
//
// `audioOutput` is a preference, not the current route: `system`, the
// default, lets the system choose, such as connected headphones or the
// receiver; `speaker` prefers the loudspeaker. Set it any time, also before
// joining; setting it never fails. The setting is the SDK's, so it applies
// to the whole app, not just this screen.
//
// In Flutter, `audioOutput` is a read-only ValueListenable and
// `setAudioOutput` changes it; both work before `initialize` too. The
// preference applies on Android as well, where `system` follows the
// device's audio routing.
//
// Uses: audioOutput, setAudioOutput(), LiveVoiceAudioOutput
// See also: Lock screen and audio sharing (with `hostManaged` audio focus,
// your app picks the route and this preference has no effect).

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';

class AudioOutputScreen extends StatelessWidget {
  const AudioOutputScreen({super.key});

  @override
  Widget build(BuildContext context) => DemoScreen(
    title: 'Audio output',
    caption: 'Prefer the loudspeaker, or let the system choose.',
    children: [
      DemoSection(
        'Output',
        children: [
          const DemoNote.info(
            'These settings apply to the whole app: every demo screen plays with them, and a playing channel keeps playing when you switch screens.',
          ),
          ValueListenableBuilder<LiveVoiceAudioOutput>(
            valueListenable: audioOutput,
            builder: (context, output, _) => DemoSegmentedPicker(
              options: const {
                LiveVoiceAudioOutput.system: 'System',
                LiveVoiceAudioOutput.speaker: 'Speaker',
              },
              selected: output,
              onChanged: setAudioOutput,
            ),
          ),
        ],
      ),
      const DemoSection('Channels', children: [LiveVoiceView()]),
    ],
  );
}
