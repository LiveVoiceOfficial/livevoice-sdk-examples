// LiveVoice SDK sample app
//
// `initialize` sets the SDK up once, before any other SDK call and before the
// first LiveVoiceView: the audio focus, whether the playing channel shows in
// the iOS system media controls, and the Android foreground service that keeps
// audio playing in the background. As on iOS, these are not properties to set
// later: only another `initialize` changes them, and only while no event is
// joined (see Lock screen and audio sharing).
//
// A hot restart runs `main` again while the native SDK keeps its event and
// configuration. `initialize` with the same values succeeds and reads the
// SDK's current state; with other values it fails with `invalidArgument`
// while an event is joined. The demo therefore saves the values it last
// initialized with.

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import 'demo/demo_session.dart';
import 'demo/demo_theme.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audio = await DemoAudioSettings.load();
  try {
    await initialize(
      audioFocus: audio.audioFocus,
      // iOS only; on Android the foreground service's notification is the
      // system media control.
      showsSystemMediaControls: audio.showsSystemMediaControls,
      // Android only: keeps playing in the background, with a media
      // notification. Enabled by default.
      androidServiceConfig: const LiveVoiceForegroundServiceConfigEnabled(),
    );
  } on LiveVoiceException catch (error) {
    runApp(_InitializeFailedApp(error: error));
    return;
  }
  runApp(SampleApp(audioSettings: audio));
}

class SampleApp extends StatefulWidget {
  const SampleApp({super.key, required this.audioSettings});

  final DemoAudioSettings audioSettings;

  @override
  State<SampleApp> createState() => _SampleAppState();
}

class _SampleAppState extends State<SampleApp> {
  // Joins the event picked in the toolbar; created after `initialize`.
  late final DemoSession _session = DemoSession(
    audioSettings: widget.audioSettings,
  );

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoSessionScope(
    session: _session,
    child: MaterialApp(
      title: 'LiveVoice SDK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: DemoTheme.light.accent,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: DemoTheme.darkTheme.accent,
      ),
      home: const HomeScreen(),
    ),
  );
}

/// What shows when `initialize` fails, for example with `unsupportedSdk`
/// when the native SDK isn't the version this package needs.
class _InitializeFailedApp extends StatelessWidget {
  const _InitializeFailedApp({required this.error});

  final LiveVoiceException error;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to initialize LiveVoice: ${error.code.value}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
