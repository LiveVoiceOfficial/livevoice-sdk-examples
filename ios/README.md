# LiveVoice SDK Sample App — iOS

A SwiftUI sample app showing how to integrate the LiveVoice SDK on iOS 15+. See the [top-level
README](../README.md) for the list of demos and how the samples are organized.

## Run the sample

Open [`SDKSampleApp.xcodeproj`](SDKSampleApp.xcodeproj) in Xcode and run the `SDKSampleApp`
scheme on a simulator or device.

> [!NOTE]
> **iOS signing:** running on a **physical device** needs your Apple Developer team. The Xcode
> project ships with no team — first create `signing/Signing.local.xcconfig` with yours (see
> [Signing](../README.md#signing) in the top-level README). Simulators don't need it.

## Integrating the SDK into your app

The SDK is distributed as a Swift package.

### 1. Add the package

In Xcode choose `File > Add Package Dependencies…`, enter the package URL, and add the
`LiveVoiceSDK` product to your app target:

```
https://github.com/LiveVoiceOfficial/livevoice-sdk-swift
```

### 2. Join an event and show the channels

There is no separate initialization step on iOS. Join an event once — for example when your
view appears — and render a `LiveVoiceView` to show its channels.

```swift
import SwiftUI
import LiveVoiceSDK

struct ContentView: View {
    var body: some View {
        LiveVoiceView()
            .task {
                await LiveVoice.shared.joinEvent(
                    joinCode: "123456",
                    password: nil,
                    apiKey: "s09WEG5y3caQ6R2PDaG4i8R1aTooTd"
                )
            }
    }
}
```

`LiveVoiceView` handles loading, errors, reconnecting, audio, and branding for you. To observe
subtitles or build a custom channel list, see the demos in this sample and the SDK repository.

## iOS-specific configuration

### Background audio

To keep audio playing while the app is backgrounded or the screen is locked, enable the
**Audio, AirPlay, and Picture in Picture** background mode under
`Signing & Capabilities > Background Modes` in your app target.

For more, explore the other demos in this sample and the
[livevoice-sdk-swift](https://github.com/LiveVoiceOfficial/livevoice-sdk-swift) package; the
SDK's API carries inline documentation (Quick Help in Xcode).
