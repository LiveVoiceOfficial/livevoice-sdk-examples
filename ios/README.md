# LiveVoice SDK Sample App — iOS

A SwiftUI sample app showing how to integrate the LiveVoice SDK on iOS 15+. See the [top-level
README](../README.md) for the list of demos and how the samples are organized.

Coming from SDK 2.x? See the [migration guide](MIGRATION.md).

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

Requires iOS 15 or newer and Xcode 26.5 or newer (Swift 6.3). Choose the dependency rule
*Up to Next Major Version* from `3.0.0`.

### 2. Join an event and show the channels

Initialization is optional on iOS. Call
`try LiveVoice.shared.initialize(audioFocus:showsSystemMediaControls:)` before joining only to
change how LiveVoice shares the audio with other apps or to hide the system media controls. Then
join an event and show a `LiveVoiceView`.

```swift
import SwiftUI
import LiveVoiceSDK

struct ContentView: View {
    @State private var joined: LiveVoiceJoinedEvent?

    var body: some View {
        LiveVoiceView()
            .task {
                do throws(LiveVoiceError) {
                    joined = try await LiveVoice.shared.joinEvent(
                        joinCode: "123456", apiKey: "YOUR_API_KEY"
                    )
                } catch {
                    // error.code says what went wrong; the view shows connection failures itself.
                }
            }
            .onDisappear {
                Task { try? await joined?.leave() }
            }
    }
}
```

If the view goes away while the join is pending, `.task` cancels it and the event is left.
`joined.leave()` leaves only this join, never a newer one.

`LiveVoiceView` handles loading, errors, reconnecting, audio, and branding for you. To observe
subtitles or build a custom channel list, see the demos in this sample and the SDK repository.

### How playback starts

Playback starts only from a channel cell: a listener taps a channel in the view, or your custom
cell calls `togglePlayback()` (a custom cell needs an API key that permits custom UI). There is no
call that starts a channel by its id. The system media controls pause and resume the playing
channel, and `LiveVoice.shared.stopChannel()` stops it.

### Passwords

Protected events and channels need no code of yours: a `LiveVoiceView` on screen asks for the
password, and the SDK remembers an accepted one until the app quits. A password you pass to
`joinEvent` is final: a wrong one fails without a prompt. To ask with your own UI
(`passwordProvider`) or keep passwords longer (`passwordStore`), see the Password-protected
channels screen.

### What a completed call guarantees

Joining, leaving, switching and reconnecting finish only when their result is final, so the next
line of your code can rely on it:

| Call | Finishes when | What is true then |
|---|---|---|
| `joinEvent(joinCode:password:apiKey:)` | The event is ready | `connection` is `.ready`, and `currentEvent` and the channels show the joined event |
| `switchToLinkedEvent(_:)` | The linked event is ready | The same, for the linked event. The previous event was left when the switch began. Needs an API key that permits custom UI and a ready connection |
| `reconnect()` | A new connection is ready | `connection` is `.ready`, or `.reconnecting` again if it dropped meanwhile. The playing channel and the subtitle choice are restored unless you stopped them; that audio plays again is not promised |
| `joined.leave()` | That join is left | Nothing of that event plays or changes any more. Once a newer join exists it does nothing |
| `leaveEvent()` | Whatever was joined or joining is left | `connection` is `.idle` and `currentEvent` is `nil` |

Each row holds unless your app made a newer call in the meantime. A call that does not get there
throws a `LiveVoiceError`:

- `.superseded`: a newer join, switch or reconnect replaced it.
- `.cancelled`: a leave, or cancelling the calling task, ended it. Show neither of these two to the
  listener.
- `.timedOut`: the event was not ready 30 seconds after the call, not counting the time a password
  is entered. A `reconnect()` that times out on an established connection fails only the call: the
  event stays joined and keeps recovering.
- `.leaveIncomplete`: cleanup took longer than 5 seconds. The event is left all the same, and the
  next join waits for the cleanup.

Leaving one event and joining another therefore needs no waiting of your own:

```swift
try await LiveVoice.shared.leaveEvent()
let joined = try await LiveVoice.shared.joinEvent(joinCode: next, apiKey: "YOUR_API_KEY")
```

A join replaces the current event by itself, also when it then fails: the earlier event is left
and `connection` is `.failed`. Only a join refused for an invalid argument leaves the current event
untouched. Leave first only to be sure the earlier event's cleanup has finished before you join. To
move to an event linked to the current one, call `switchToLinkedEvent(_:)`: it leaves and joins in
one call.

## iOS-specific configuration

### Background audio

To keep audio playing while the app is backgrounded or the screen is locked, select your app
target in Xcode, open **Signing & Capabilities**, add **Background Modes** and check **Audio,
AirPlay, and Picture in Picture**.

By default LiveVoice takes the audio exclusively and shows the playing channel on the Lock Screen
and in Control Center. `initialize(audioFocus:showsSystemMediaControls:)` changes both
(`.duckOthers`, `.hostManaged`), and `nowPlayingArtwork` replaces the event's logo there; see the
Lock screen and audio sharing screen.

For more, explore the other demos in this sample and the
[livevoice-sdk-swift](https://github.com/LiveVoiceOfficial/livevoice-sdk-swift) package; the
SDK's API carries inline documentation (Quick Help in Xcode).
