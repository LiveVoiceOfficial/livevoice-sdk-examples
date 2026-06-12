# LiveVoice SDK Examples

Working sample apps that show how to integrate the [LiveVoice](https://livevoice.io) SDK on
iOS, Android, React Native, and Flutter. Each app implements the same set of demos so you can
compare the platforms side by side.

> [!NOTE]
> The example apps include a demo event and working API keys, so you can clone, build, and run
> them right away. For your own event you need a LiveVoice account with SDK access enabled.
>
> For more information contact [sdk-support@livevoice.io](mailto:sdk-support@livevoice.io).
> Once SDK access has been granted, you can find your `api-key` on your account page at
> [livevoice.io/en/account/api](https://livevoice.io/en/account/api).

## Platform guides

Each platform has its own README with setup instructions, a minimal integration walkthrough,
and platform-specific configuration. Start with the one for your stack:

| Platform | Minimum version | What the guide covers |
| --- | --- | --- |
| [**Android**](android/README.md) | Android 6.0+ | Maven setup, init, `LiveVoiceView`, background-audio service, view sizing |
| [**iOS**](ios/README.md) | iOS 15+ | Swift Package Manager, joining an event, `LiveVoiceView`, signing & background audio |
| [**React Native**](react-native/README.md) | React Native 0.80+ (iOS 15.1+, Android 7.0+ / API 24) | Install, init, `LiveVoiceView`, New Architecture, CocoaPods |
| [**Flutter**](flutter/README.md) | Flutter 3.41+ (iOS 15+, Android 6.0+ / API 23) | Install, init, `LiveVoiceView`, background audio, view sizing |

## What the samples demonstrate

Every platform ships the same demos, grouped into two sections. The code for each lives in that
platform's source tree under similarly named screens.

### Default UI

| Demo | What it shows |
| --- | --- |
| Default participant interface | The simplest integration, with subtitles in your own view. |
| Filtered channel list | Show only the channels you want — by property, an empty result, or a source channel with its AI subtitles. |
| Audio output picker | Place the audio output picker wherever it fits in your app. |
| Subtitle only | Show subtitles without displaying any of the event channels. |

### Custom UI

| Demo | What it shows |
| --- | --- |
| Branding and entitlements | See how API key permissions affect branding and customization. |
| Custom channel cell | A richer custom channel row with status, translation, and subtitle badges. |
| Localization and accessibility | The strings and labels needed for a polished custom integration. |

## How the samples are structured

A few conventions are shared across all four apps:

- **One join per session.** Each app joins a single demo event at startup through a small
  `DemoSession` helper and renders the demos against it. In your own app you join an event
  once, then present the SDK views.
- **API key presets.** A menu in each app switches between API keys with different permissions
  (default branding, hidden branding, full customization) so you can see how entitlements
  change the UI. The selected key is what powers the Branding and entitlements demo.

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
