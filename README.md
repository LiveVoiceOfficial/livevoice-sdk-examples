# LiveVoice SDK Examples

Working sample apps that show how to integrate the [LiveVoice](https://livevoice.io) SDK on
iOS, Android, React Native, and Flutter. Each app implements the same set of demos so you can
compare the platforms side by side.

> [!NOTE]
> The example apps include a demo event and working API keys, so you can clone, build, and run
> them right away. For your own event you need a LiveVoice account with SDK access enabled.
>
> For more information contact [sdk-support@livevoice.io](mailto:sdk-support@livevoice.io).
> Once SDK access has been granted, you can find your personal API key in the 'API/SDK Keys' section of your
> account page at
> [livevoice.io/en/account/api](https://livevoice.io/en/account/api).

## Platform guides

Each platform has its own README with setup instructions, a minimal integration walkthrough,
and platform-specific configuration. Start with the one for your stack:

| Platform | Minimum version | Build tools | What the guide covers |
| --- | --- | --- | --- |
| [**Android**](android/README.md) | Android 6.0+ / API 23 | JDK 21, `compileSdk` 36+ | Maven setup, init, `LiveVoiceView`, background-audio service, view sizing |
| [**iOS**](ios/README.md) | iOS 15+ | Xcode 26.5+ (Swift 6.3) | Swift Package Manager, joining an event, `LiveVoiceView`, signing & background audio |
| [**React Native**](react-native/README.md) | React Native 0.81+ (iOS 15.1+, Android 7.0+ / API 24) | Xcode 26.5+, New Architecture | Install, init, `LiveVoiceView`, New Architecture, CocoaPods |
| [**Flutter**](flutter/README.md) | Flutter 3.44+ (iOS 15+, Android 6.0+ / API 23) | Dart 3.11+, Xcode 26.5+, Swift Package Manager on iOS (Xcode 27 needs Flutter 3.44.8+) | Install, init, `LiveVoiceView`, background audio, view sizing |

## What the samples demonstrate

Every platform ships the same fourteen screens in the same six sections. Each screen shows one SDK
feature, which appears on no other screen, and its source file starts with a comment saying what it
shows, what it needs, the API it uses and related screens. Where a platform integrates a feature
differently, that comment says so. Everything only the demo needs (the screen layout, the event
picker) lives in a separate demo folder (`Demo` on iOS, `demo` elsewhere), so a screen's file reads
as SDK usage.

The demo event has three channels with subtitles. Screens that need more say so on screen.

The SDKs play audio and subtitles; video will be supported in an upcoming version. Until then a
channel with video and audio plays its audio, and one with only video cannot be played; `hasVideo`
tells which channels have video.

| Section | Screen | What it shows | Works with the demo event | iOS | Android | React Native | Flutter |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Getting started | Default interface | Tap a channel to listen. | Yes | [Swift](ios/SDKSampleApp/Screens/GettingStarted/DefaultInterfaceScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/gettingstarted/DefaultInterfaceScreen.kt) | [TSX](react-native/src/screens/GettingStarted/DefaultInterfaceScreen.tsx) | [Dart](flutter/lib/screens/getting_started/default_interface_screen.dart) |
| Getting started | Joining an event | Join, reconnect and leave the event yourself. | Yes | [Swift](ios/SDKSampleApp/Screens/GettingStarted/JoiningEventScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/gettingstarted/JoiningEventScreen.kt) | [TSX](react-native/src/screens/GettingStarted/JoiningEventScreen.tsx) | [Dart](flutter/lib/screens/getting_started/joining_event_screen.dart) |
| Channels | Filtering channels | Show only the channels you want. | Yes | [Swift](ios/SDKSampleApp/Screens/Channels/FilteringChannelsScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/channels/FilteringChannelsScreen.kt) | [TSX](react-native/src/screens/Channels/FilteringChannelsScreen.tsx) | [Dart](flutter/lib/screens/channels/filtering_channels_screen.dart) |
| Channels | Custom channel cell | Draw each channel with your own view. | Needs the custom-UI key | [Swift](ios/SDKSampleApp/Screens/Channels/CustomChannelCellScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/channels/CustomChannelCellScreen.kt) | [TSX](react-native/src/screens/Channels/CustomChannelCellScreen.tsx) | [Dart](flutter/lib/screens/channels/custom_channel_cell_screen.dart) |
| Channels | Custom view states | Show loading, reconnecting, errors and no channels your way. | Needs the custom-UI key | [Swift](ios/SDKSampleApp/Screens/Channels/CustomViewStatesScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/channels/CustomViewStatesScreen.kt) | [TSX](react-native/src/screens/Channels/CustomViewStatesScreen.tsx) | [Dart](flutter/lib/screens/channels/custom_view_states_screen.dart) |
| Subtitles | Subtitles | Show a channel's live subtitles in your own view. | Yes | [Swift](ios/SDKSampleApp/Screens/Subtitles/SubtitlesScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/subtitles/SubtitlesScreen.kt) | [TSX](react-native/src/screens/Subtitles/SubtitlesScreen.tsx) | [Dart](flutter/lib/screens/subtitles/subtitles_screen.dart) |
| Audio and system | Audio output | Prefer the loudspeaker, or let the system choose. | Yes | [Swift](ios/SDKSampleApp/Screens/AudioAndSystem/AudioOutputScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/audioandsystem/AudioOutputScreen.kt) | [TSX](react-native/src/screens/AudioAndSystem/AudioOutputScreen.tsx) | [Dart](flutter/lib/screens/audio_and_system/audio_output_screen.dart) |
| Audio and system | Lock screen and audio sharing | Share the audio with other apps, and show the playing channel on the Lock Screen. | Yes, best on a device | [Swift](ios/SDKSampleApp/Screens/AudioAndSystem/LockScreenScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/audioandsystem/LockScreenScreen.kt) | [TSX](react-native/src/screens/AudioAndSystem/LockScreenScreen.tsx) | [Dart](flutter/lib/screens/audio_and_system/lock_screen_screen.dart) |
| Event features | Password-protected channels | Ask for channel passwords with your own UI, and keep them. | Needs your own event | [Swift](ios/SDKSampleApp/Screens/EventFeatures/PasswordsScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/eventfeatures/PasswordsScreen.kt) | [TSX](react-native/src/screens/EventFeatures/PasswordsScreen.tsx) | [Dart](flutter/lib/screens/event_features/passwords_screen.dart) |
| Event features | Language requests | Ask the event for a language it doesn't offer yet. | Needs your own event and the custom-UI key | [Swift](ios/SDKSampleApp/Screens/EventFeatures/LanguageRequestsScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/eventfeatures/LanguageRequestsScreen.kt) | [TSX](react-native/src/screens/EventFeatures/LanguageRequestsScreen.tsx) | [Dart](flutter/lib/screens/event_features/language_requests_screen.dart) |
| Event features | Linked events | Switch to an event linked to this one. | Needs your own event and the custom-UI key | [Swift](ios/SDKSampleApp/Screens/EventFeatures/LinkedEventsScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/eventfeatures/LinkedEventsScreen.kt) | [TSX](react-native/src/screens/EventFeatures/LinkedEventsScreen.tsx) | [Dart](flutter/lib/screens/event_features/linked_events_screen.dart) |
| Customization and diagnostics | Branding and entitlements | See what the joined event's API key permits. | Yes, with each demo key | [Swift](ios/SDKSampleApp/Screens/Customization/BrandingScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/customization/BrandingScreen.kt) | [TSX](react-native/src/screens/Customization/BrandingScreen.tsx) | [Dart](flutter/lib/screens/customization/branding_screen.dart) |
| Customization and diagnostics | Localization and accessibility | The SDK's own texts, in the app's language, for your custom parts. | Yes | [Swift](ios/SDKSampleApp/Screens/Customization/LocalizationScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/customization/LocalizationScreen.kt) | [TSX](react-native/src/screens/Customization/LocalizationScreen.tsx) | [Dart](flutter/lib/screens/customization/localization_screen.dart) |
| Customization and diagnostics | Diagnostics log | Read what the SDK did, and why a call failed. | Yes | [Swift](ios/SDKSampleApp/Screens/Customization/DiagnosticsScreen.swift) | [Kotlin](android/app/src/main/java/io/livevoice/example/screens/customization/DiagnosticsScreen.kt) | [TSX](react-native/src/screens/Customization/DiagnosticsScreen.tsx) | [Dart](flutter/lib/screens/customization/diagnostics_screen.dart) |

## How the samples are structured

A few conventions are shared across all four apps:

- **One join per session.** Each app initializes the SDK at launch and joins the event picked in
  the toolbar through a small `DemoSession` helper; every screen shows that event. In your own
  app you join an event once, then present the SDK views. The "Joining an event" screen shows the
  calls themselves.
- **API key presets.** A menu in each app switches between API keys with different permissions
  (default branding, hidden branding, full customization) so you can see how entitlements
  change the UI. The selected key is what powers the Branding and entitlements demo.

## Migrating from 2.x

SDK 3.0 changes how you join, leave and start playback. One guide per platform, in the same order:
[iOS](ios/MIGRATION.md), [Android](android/MIGRATION.md),
[React Native](react-native/MIGRATION.md), [Flutter](flutter/MIGRATION.md).

## Running with your own event

Each app runs against a built-in sample LiveVoice event. To try your own event instead, you
don't need to change any code: open the API-key menu in any app and choose **Use your own
event**, then enter your join code, API key, and optional password.

## Signing

### Android

The three Android samples (native, React Native, Flutter) all sign with a single committed
keystore, [`signing/sample-debug.keystore`](signing/sample-debug.keystore). It is the
well-known Android **debug** key (alias `androiddebugkey`, password `android`) — **not
secret**, and used here only so that local builds get a *stable* signature: you can rebuild and
reinstall a sample on any machine and it keeps updating in place instead of failing with
"signatures do not match." It is **not** a release key — sign your *own* app with your *own*
keystore before distributing it.

### iOS

Running a sample on a **physical device** requires your Apple Developer team; simulators don't
need one. The Xcode projects ship with **no team** committed; all three iOS samples instead
read a single git-ignored `signing/Signing.local.xcconfig`. Create it by duplicating the
committed template
[`signing/Signing.local.xcconfig.sample`](signing/Signing.local.xcconfig.sample) — drop the
`.sample` suffix — and set your team:

```sh
cp signing/Signing.local.xcconfig.sample signing/Signing.local.xcconfig
# then set DEVELOPMENT_TEAM = YOURTEAMID in the copy
```

## License

See [LICENSE.txt](LICENSE.txt).
