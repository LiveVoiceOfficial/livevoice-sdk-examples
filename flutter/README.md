# LiveVoice SDK Sample App — Flutter

A Flutter sample app showing how to integrate the LiveVoice SDK on Flutter 3.44+. See the
[top-level README](../README.md) for the list of demos and how the samples are organized.

Coming from SDK 2.x? See the [migration guide](MIGRATION.md).

## Run the sample

```sh
flutter pub get
flutter devices            # list connected devices and their ids
flutter run -d <device-id>
```

> [!NOTE]
> **iOS signing:** running on a **physical** iOS device needs your Apple Developer team. The Xcode
> runner ships with no team — first create `signing/Signing.local.xcconfig` with yours (see
> [Signing](../README.md#signing) in the top-level README). Simulators don't need it.

## Integrating the SDK into your app

Requires Flutter 3.44 or newer (Dart 3.11 or newer) with Swift Package Manager enabled for iOS
(the default), iOS 15 or newer with Xcode 26.5 or newer (Swift 6.3), and Android 6.0 (API 23) or
newer. Building with Xcode 27 needs Flutter 3.44.8 or newer.

### 1. Add the dependency

Install the SDK package from pub.dev:

```sh
flutter pub add livevoice_sdk_flutter
```

### 2. Initialize the SDK

Initialize the SDK once before running your app. `initialize()` also takes `audioFocus`,
`showsSystemMediaControls` (iOS) and `androidServiceConfig` (Android; the foreground service is
enabled by default, see below).

```dart
import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initialize();
    runApp(const MyApp());
  } on LiveVoiceException catch (error) {
    runApp(MaterialApp(home: Text('Unable to initialize: ${error.message}')));
  }
}
```

Commands called before `initialize()` completes fail with `notInitialized`. Calling it again with
the same options changes nothing. Changed options apply only while no event is joined and fail
with `invalidArgument` otherwise.

### 3. Join an event and show the channels

Join an event once, then render a `LiveVoiceView` to show its channels.

```dart
// See lib/screens/getting_started/joining_event_screen.dart for joining, reconnecting and leaving.
try {
  final joined = await joinEvent(joinCode: '123456', apiKey: 'YOUR_API_KEY');
  // Keep `joined` and call `joined.leave()` when you are done with the event.
} on LiveVoiceException catch (error) {
  // Handle error.code (a LiveVoiceErrorCode enum).
}

// ...somewhere in your widget tree:
const LiveVoiceView();
```

`LiveVoiceView` handles loading, errors, reconnecting, audio, and branding for you. To observe
subtitles or build a custom channel list, see the demos in this sample.

### How playback starts

Playback starts only from a channel cell: a listener taps a channel in the view, or your custom
cell calls `togglePlayback()` (a custom cell needs an API key that permits custom UI). There is no
call that starts a channel by its id. The system media controls pause and resume the playing
channel, and `stopChannel()` stops it.

### Passwords

Protected events and channels need no code of yours: a `LiveVoiceView` on screen asks for the
password, and the SDK remembers an accepted one until the app quits. A password you pass to
`joinEvent` is final: a wrong one fails without a prompt. To ask with your own UI
(`setPasswordProvider`) or keep passwords longer (`setPasswordStore`), see the Password-protected
channels screen.

### What an awaited call guarantees

Joining, leaving, switching and reconnecting finish only when their result is final, so the next
line of your code can rely on it:

| Call | Finishes when | What is true then |
|---|---|---|
| `joinEvent(...)` | The event is ready | `connection` is ready, and `currentEvent`, `linkedEvents`, `requestableLanguages` and `availableSubtitles` show the joined event. The channel list, `features` and `subtitles` follow shortly: listen to them instead of reading them right after the call |
| `switchToLinkedEvent(event)` | The linked event is ready | The same, for the linked event. The previous event was left when the switch began. Needs an API key that permits custom UI and a ready connection |
| `reconnect()` | A new connection is ready | `connection` is ready, or reconnecting again if it dropped meanwhile, and the same values show the event. The playing channel and the subtitle choice are restored unless you stopped them; that audio plays again is not promised |
| `joined.leave()` | That join is left | Nothing of that event plays or changes any more, and the same values show it. Once a newer join exists it does nothing |
| `leaveEvent()` | Whatever was joined or joining is left | `connection` is idle, and `currentEvent`, `linkedEvents`, `requestableLanguages` and `availableSubtitles` are `null` |

Each row holds unless your app made a newer call in the meantime. A call that does not get there
throws a `LiveVoiceException`:

- `superseded`: a newer join, switch or reconnect replaced it.
- `cancelled`: a leave ended it. Show neither of these two to the listener. An awaited call cannot
  be cancelled by its caller.
- `timedOut`: the event was not ready 30 seconds after the call, not counting the time a password
  is entered. A `reconnect()` that times out on an established connection fails only the call: the
  event stays joined and keeps recovering.
- `leaveIncomplete`: cleanup took longer than 5 seconds. The event is left all the same, and the
  next join waits for the cleanup.

Leaving one event and joining another therefore needs no waiting of your own:

```dart
await leaveEvent();
final joined = await joinEvent(joinCode: next, apiKey: 'YOUR_API_KEY');
```

A join replaces the current event by itself, also when it then fails: the earlier event is left
and `connection` is failed. Only a join refused for an invalid argument leaves the current event
untouched. Leave first only to be sure the earlier event's cleanup has finished before you join. To
move to an event linked to the current one, call `switchToLinkedEvent(event)`: it leaves and joins
in one call.

## Flutter-specific configuration

### Background audio

The `androidServiceConfig` passed to `initialize` configures an Android foreground service so
audio keeps playing while the app is backgrounded or the screen is locked. The service shows the
system's media controls, including a media notification, while a channel plays or can resume. That
notification needs no `POST_NOTIFICATIONS` prompt; other notifications of your app may still need
the permission; see
[Android's media-session exemption](https://developer.android.com/develop/ui/compose/notifications/notification-permission#media-sessions).

On iOS, to keep audio playing in the background, open `ios/Runner.xcworkspace` in Xcode, select
the Runner target, open **Signing & Capabilities**, add **Background Modes** and check **Audio,
AirPlay, and Picture in Picture**.

By default LiveVoice takes the audio exclusively and shows the playing channel in the system
media controls. `initialize(audioFocus:, showsSystemMediaControls:)` changes that
(`LiveVoiceAudioFocus.duckOthers` or `LiveVoiceAudioFocus.hostManaged`;
`showsSystemMediaControls` applies on iOS), and `setNowPlayingArtwork(assetName)` replaces the
event's logo there; see the Lock screen and audio sharing screen.

### Sizing views

`LiveVoiceView` lays out like a normal Flutter widget. Constrain its height with the usual
widgets (`SizedBox`, `ConstrainedBox`, `Expanded`) and make the surrounding content scrollable
if it might exceed the screen.

