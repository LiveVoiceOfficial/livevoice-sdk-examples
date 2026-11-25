// Lock screen and audio sharing
//
// `audioFocus` decides what happens to other audio while a channel plays.
// With `exclusive`, the default, the playing channel appears on the Lock
// Screen and in Control Center, unless `showsSystemMediaControls` is off;
// `setNowPlayingArtwork` replaces the event's logo there. Best tried on a
// device: play a channel, then lock the phone. The settings are the SDK's,
// so they apply to the whole app, not just this screen.
//
// As on iOS, `audioFocus` and `showsSystemMediaControls` are arguments of
// `initialize`: there is no getter, so the app keeps what it passed, and
// only another `initialize` changes them, and only while no
// event is joined (otherwise it fails with `invalidArgument`). This screen
// therefore leaves the event, initializes again with the same
// `androidServiceConfig` as main.dart and joins again, which stops a
// playing channel. On Android, the foreground service's media notification
// shows the playing channel instead; `showsSystemMediaControls` is ignored
// there, and the artwork shows in the notification. `setNowPlayingArtwork`
// takes the name of an asset declared in pubspec.yaml, not an image; it
// works at any time, also before `initialize`.
//
// Uses: initialize(audioFocus:, showsSystemMediaControls:,
// androidServiceConfig:), LiveVoiceAudioFocus, setNowPlayingArtwork()
// See also: Audio output.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';
import '../../demo/demo_session.dart';

class LockScreenScreen extends StatefulWidget {
  const LockScreenScreen({super.key});

  @override
  State<LockScreenScreen> createState() => _LockScreenScreenState();
}

class _LockScreenScreenState extends State<LockScreenScreen> {
  LiveVoiceException? _failure;
  bool _applying = false;

  @override
  Widget build(BuildContext context) {
    // What the app last passed to `initialize`.
    final settings = DemoSessionScope.of(context).audioSettings;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    return DemoScreen(
      title: 'Lock screen and audio sharing',
      caption:
          'Share the audio with other apps, and show the playing channel on the Lock Screen.',
      error: _failure,
      children: [
        DemoSection(
          'Other audio',
          children: [
            const DemoNote.info(
              'These settings apply to the whole app: every demo screen plays with them, and a playing channel keeps playing when you switch screens.',
            ),
            // `hostManaged` leaves the audio session (iOS) or audio focus
            // (Android) to your app: it sets them up before a channel starts,
            // and picks the route.
            DemoSegmentedPicker<LiveVoiceAudioFocus>(
              options: const {
                LiveVoiceAudioFocus.exclusive: 'Pause',
                LiveVoiceAudioFocus.duckOthers: 'Duck',
              },
              selected: settings.audioFocus,
              onChanged: _applying
                  ? null
                  : (focus) => _initialize(
                      DemoAudioSettings(
                        audioFocus: focus,
                        showsSystemMediaControls:
                            settings.showsSystemMediaControls,
                      ),
                    ),
            ),
            const DemoNote.info(
              'A change initializes the SDK again, which leaves the event and joins it again: a playing channel stops.',
            ),
          ],
        ),
        DemoSection(
          isAndroid ? 'Media notification' : 'Lock Screen and Control Center',
          children: [
            // Turn them off if your app shows its own media controls. Only
            // `exclusive` shows them: the system has none for mixed audio.
            if (isAndroid)
              const DemoNote.info(
                "On Android, the foreground service's notification shows the playing channel.",
              )
            else ...[
              DemoToggle(
                'System media controls',
                value: settings.showsSystemMediaControls,
                onChanged:
                    _applying ||
                        settings.audioFocus != LiveVoiceAudioFocus.exclusive
                    ? null
                    : (shows) => _initialize(
                        DemoAudioSettings(
                          audioFocus: settings.audioFocus,
                          showsSystemMediaControls: shows,
                        ),
                      ),
              ),
              if (settings.audioFocus != LiveVoiceAudioFocus.exclusive)
                const DemoNote.info(
                  "With Duck, iOS shows no system controls: it shows them only for audio that doesn't mix with other apps.",
                ),
            ],
            DemoButtonRow([
              // The SDK draws it fitted, with a margin, on a white square.
              DemoButton(
                'App image',
                onPressed: () => _setArtwork('assets/demo_artwork.png'),
              ),
              // `null` shows the event's logo from the dashboard, or none.
              DemoButton('Event logo', onPressed: () => _setArtwork(null)),
            ]),
          ],
        ),
        const DemoSection('Channels', children: [LiveVoiceView()]),
      ],
    );
  }

  /// Applies [settings]: `initialize` takes a changed configuration only
  /// while no event is joined, so leave first and join again after.
  Future<void> _initialize(DemoAudioSettings settings) async {
    final session = DemoSessionScope.read(context);
    final event = session.selectedPreset;
    setState(() {
      _failure = null;
      _applying = true;
    });
    try {
      final wasJoined = switch (connection.value) {
        LiveVoiceConnectionIdle() || LiveVoiceConnectionFailed() => false,
        LiveVoiceConnectionJoining() ||
        LiveVoiceConnectionReady() ||
        LiveVoiceConnectionReconnecting() ||
        LiveVoiceConnectionLeaving() => true,
      };
      if (wasJoined) await leaveEvent();
      await initialize(
        audioFocus: settings.audioFocus,
        showsSystemMediaControls: settings.showsSystemMediaControls,
        // The same as in main.dart: a different one counts as a change too.
        androidServiceConfig: const LiveVoiceForegroundServiceConfigEnabled(),
      );
      await session.rememberAudioSettings(settings);
      if (wasJoined) {
        await joinEvent(
          joinCode: event.joinCode,
          password: event.password,
          apiKey: event.apiKey,
        );
      }
    } on LiveVoiceException catch (error) {
      // A newer join, such as from the toolbar, took over.
      if (error.code != LiveVoiceErrorCode.cancelled &&
          error.code != LiveVoiceErrorCode.superseded &&
          mounted) {
        setState(() => _failure = error);
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  /// A change shows at once. Fails with `invalidArgument` for an asset that
  /// can't be loaded or decoded, and keeps the previous image then.
  Future<void> _setArtwork(String? assetName) async {
    setState(() => _failure = null);
    try {
      await setNowPlayingArtwork(assetName);
    } on LiveVoiceException catch (error) {
      if (mounted) setState(() => _failure = error);
    }
  }
}
