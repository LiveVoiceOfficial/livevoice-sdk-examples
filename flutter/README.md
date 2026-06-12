# LiveVoice SDK Sample App — Flutter

A Flutter sample app showing how to integrate the LiveVoice SDK on Flutter 3.41+. See the
[top-level README](../README.md) for the list of demos and how the samples are organized.

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

### 1. Add the dependency

Install the SDK package from pub.dev:

```sh
flutter pub add livevoice_sdk_flutter
```

### 2. Initialize the SDK

Initialize the SDK once before running your app. On Android this also configures the foreground
service used while audio is playing (see below); on iOS it is ignored.

```dart
import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize(
    androidServiceConfig: const LiveVoiceServiceEnabled(
      message: 'Channel %s is playing!',
    ),
  );

  runApp(const MyApp());
}
```

### 3. Join an event and show the channels

Join an event once, then render a `LiveVoiceView` to show its channels.

```dart
joinEvent(
  joinCode: '123456',
  password: null,
  apiKey: 's09WEG5y3caQ6R2PDaG4i8R1aTooTd',
);

// ...somewhere in your widget tree:
const LiveVoiceView();
```

`LiveVoiceView` handles loading, errors, reconnecting, audio, and branding for you. To observe
subtitles or build a custom channel list, see the demos in this sample.

## Flutter-specific configuration

### Background audio

The `androidServiceConfig` passed to `initialize` configures an Android foreground service so
audio keeps playing while the app is backgrounded or the screen is locked. The service shows a
notification for its duration; on Android 13+ you must request the notification permission at
runtime.

On iOS, enable the **Audio, AirPlay, and Picture in Picture** background mode under
`Signing & Capabilities > Background Modes` in the iOS runner to keep audio playing in the
background.

### Sizing views

`LiveVoiceView` lays out like a normal Flutter widget. Constrain its height with the usual
widgets (`SizedBox`, `ConstrainedBox`, `Expanded`) and make the surrounding content scrollable
if it might exceed the screen.

