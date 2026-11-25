# Migrating from SDK 2.x to 3.0 (iOS)

## At a glance

- `joinEvent` now throws, returns when the event is ready, and gives you a `LiveVoiceJoinedEvent`.
- Every call throws one error type, `LiveVoiceError`; `LiveVoiceSDKError` is gone.
- The connection is a value of its own, `LiveVoice.shared.connection`, with `reconnect()`.
- `LiveVoiceView { state in … }` is replaced by modifiers; a custom cell gets a
  `LiveVoiceChannelCell` and calls its `togglePlayback()`.
- `subtitles` is a new enum, and `availableSubtitles` is optional (`nil` when not joined).
- `AudioOutput.headphones` is `LiveVoiceAudioOutput.system`.
- No 2.x symbol is kept as a deprecated alias: each one is a compile error until changed.

## 1. Requirements and installation

New requirement: Xcode 26.5 or newer (Swift 6.3). iOS 15 stays the minimum. The package is
unchanged; raise its version to 3.

## 2. Initialization

2.x had none. 3.0 has an optional call, needed only to choose other values than the defaults:

```swift
// 3.0, before joining
try LiveVoice.shared.initialize(audioFocus: .exclusive, showsSystemMediaControls: true)
```

The same configuration again changes nothing. A changed one applies only while the connection is
`.idle` or `.failed`; otherwise it throws `.invalidArgument` and changes nothing.

## 3. Joining and leaving

```swift
// 2.x
await LiveVoice.shared.joinEvent(joinCode: code, password: password, apiKey: key)
try await LiveVoice.shared.leaveEvent()

// 3.0
do throws(LiveVoiceError) {
    joined = try await LiveVoice.shared.joinEvent(joinCode: code, password: password, apiKey: key)
} catch {
    guard error.code != .cancelled, error.code != .superseded else { return }
    failure = error
}
try await joined.leave()                 // or: try await LiveVoice.shared.leaveEvent()
```

- `joinEvent` returns when the event is ready: authenticated, its state loaded, commands
  accepted. It does not wait for audio. `connection`, `currentEvent`, `linkedEvents`,
  `requestableLanguages`, `availableSubtitles`, `customUiAllowed` and `hideBranding` then show the
  joined event. Await the call; do not watch the view to learn that it completed.
- A join replaces the current event, also when it then fails: the earlier event is left and the
  connection ends `.failed`. Only a join refused with `.invalidArgument` leaves the current event
  untouched. A pending earlier join throws `.superseded`. A join never retries by itself.
- `joined.leave()` leaves only that join and does nothing once a newer join replaced it, so a
  screen's cleanup cannot leave the next screen's event. `leaveEvent()` leaves whatever is joined
  or joining, any number of times, and ends a pending join with `.cancelled`.
- Limits: a join throws `.timedOut` after 30 seconds, counted from the call and including the
  cleanup of the previous event, but not the time a password is entered. A leave throws
  `.leaveIncomplete` after 5 seconds: the event is left all the same, the connection is `.idle`,
  the cleanup continues and the next join waits for it.
- Cancelling the task of a pending join leaves the event, and the call throws `.cancelled`; mind
  `.task { }`, which cancels when the view goes away. A cancelled task does not stop a leave.

## 4. Starting and stopping playback

Playback starts only from a channel cell's toggle or the system media controls; there is no call
that starts a channel by its id. `stopChannel()` is new and stops whatever plays.

```swift
// 2.x
case let .ready(channel, isLast, onTap): Button(action: onTap) { … }

// 3.0
LiveVoiceView().channelCell { cell in
    Button { Task { try? await cell.togglePlayback() } } label: { Text(cell.channel.name) }
        .disabled(!cell.isEnabled)
}
```

- `togglePlayback()` returns when local playback is confirmed (the channel shows `.playing`) or
  has stopped. It throws `.timedOut` after 10 seconds and `.cancelled` when another start, a
  stop, a leave or a new join took over. Catch its error in your cell.
- `cell.isEnabled` is `false` while the channel is offline, has no audio, or the connection
  recovers. A start then throws `.channelOffline` or `.channelUnavailable`.
- `stopChannel()` returns when local playback has stopped (10-second limit) and is also allowed
  while joining, reconnecting or failed. A stopped channel is not restored by a later reconnect.

## 5. Connection and reconnect

2.x showed the connection only through the view's state. 3.0 publishes it:

```swift
@ObservedObject var liveVoice = LiveVoice.shared
switch liveVoice.connection {
case .idle, .joining, .leaving: …
case let .ready(eventID): …
case let .reconnecting(eventID, retry): …
case let .failed(error): …            // stays until a leave or a new join
}
try await liveVoice.reconnect()
```

The SDK reconnects by itself; `reconnect()` tries at once. It is allowed while `.ready`,
`.reconnecting`, or `.failed` with a retryable error (it then retries the join); from `.failed`
with another error it throws that error again, otherwise `.notJoined`. When it returns, the
connection is `.ready`, or `.reconnecting` again if it dropped meanwhile; the playing channel and
subtitle choice are restored unless you stopped them. After 30 seconds it throws `.timedOut`,
with two outcomes: on an established connection only the call fails and the event stays joined
and keeps recovering; a retried failed join ends `.failed`.

## 6. Errors

```swift
// 2.x
Text(error.localizedDescription, bundle: .liveVoiceSDK)      // LiveVoiceSDKError

// 3.0
Text(error.message)                                          // LiveVoiceError
if error.code == .timedOut, error.isRetryable { … }
```

`LiveVoiceError` has a `code` (`LiveVoiceErrorCode`), `isRetryable`, a localized `message` to show
as it is, and `detail`. Decide by `code`, never by the text. Do not show `.superseded` and
`.cancelled` to users: a newer call or a leave ended the call, nothing went wrong. A missing
custom-UI permission shows as `.apiKeyInvalid`. `.notInitialized` never occurs on iOS.

## 7. Passwords

`joinEvent(password:)` works as before, but a password you pass is final: if it is wrong the call
fails and the SDK does not ask. Without one, the SDK looks in its memory, then in your
`passwordStore`, then asks your `passwordProvider` or, without a provider, shows its own prompt.
The prompt needs a `LiveVoiceView` on screen; without one the call fails with the password error.

```swift
LiveVoice.shared.passwordProvider = { request in await myPrompt(request) }   // nil gives up
LiveVoice.shared.passwordStore = myStore                                     // LiveVoicePasswordStore
```

## 8. Subtitles

```swift
// 2.x
liveVoice.subtitles.fragments; liveVoice.subtitles.isEnabled      // .auto, .enabled
subtitle.id; subtitle.parent

// 3.0
switch liveVoice.subtitles {
case .disabled: …
case let .automatic(fragments), let .specific(_, fragments): …
}
subtitle.channelID; subtitle.parentChannelID
```

- `startSubtitles()` without a channel is automatic mode: it follows whichever channel plays, is
  on from the call (it returns at once when nothing plays) and never asks for a password.
- `startSubtitles(channelID:password:)` returns when the server accepted it (10-second limit).
  One subtitle stream at a time; neither call starts or stops playback.
- `availableSubtitles` is `nil` when not joined and a list once a join returned, empty when the
  event has none.

## 9. Custom UI

The single state closure became five parts. Leave one out to keep the SDK's design.

```swift
// 2.x
LiveVoiceView { state in switch state { case .loading: … case .error(let error, let retry): … } }

// 3.0
LiveVoiceView()
    .channelCell { cell in … }
    .loading { … }
    .reconnecting { retry in … }          // LiveVoiceRetry: .inProgress, .scheduled(at:)
    .error { error, retry in … }          // retry: (() async throws -> Void)?
    .empty { reason in … }                // .noChannels, .noMatches
    .onCommandError { error in … }
```

All parts but `loading` need an API key that permits custom UI. While reconnecting, the channel
list stays, drawn disabled, for the first seconds before the reconnecting part shows.
`onCommandError` receives the errors of the SDK's own controls, never `.cancelled` or
`.superseded`; your own cell gets its errors from `togglePlayback()`.

## 10. Audio and background

`audioOutput` is still a settable property, now a preference of type `LiveVoiceAudioOutput`:
`.system` (was `.headphones`) or `.speaker`. New: `initialize(audioFocus:)` with `.exclusive`
(default), `.duckOthers` or `.hostManaged`; the system media controls show the playing channel
(`showsSystemMediaControls`), and `nowPlayingArtwork` replaces their image. The background audio
capability is needed as before.

## 11. Renamed and removed

Each 2.x name is a compile error in 3.0.

| 2.x | 3.0 |
| --- | --- |
| `AudioOutput.headphones`, `.speaker` | `LiveVoiceAudioOutput.system`, `.speaker` |
| `LiveVoice.AITranslationInfo`, `sourceID` | `LiveVoiceAITranslationInfo`, `sourceChannelID` |
| `LiveVoice.AvailableSubtitle`, `id`, `parent` | `LiveVoiceAvailableSubtitle`, `channelID`, `parentChannelID` |
| `LiveVoice.DependentChannel` | `LiveVoiceDependentChannel`; its `language` is now optional (always set for a translation) |
| `LiveVoice.Subtitles`: `.auto`, `.enabled(fragments:channelID:)`, `isEnabled`, `fragments` | `LiveVoiceSubtitleState`: `.automatic(fragments:)`, `.specific(channelID:fragments:)` |
| `LiveVoice.ViewState`, `LiveVoiceView { state in }` | the modifiers of section 9 |
| `LiveVoice.ViewState.ReconnectState`: `.retrying`, `.waiting(until:)` | `LiveVoiceRetry`: `.inProgress`, `.scheduled(at:)` |
| `LiveVoiceChannel.PlayState`, `channel.playState` | `LiveVoicePlayingState`, `channel.playingState` |
| `LiveVoiceSDKError`, `localizedDescription` | `LiveVoiceError`, `message` |
| `LiveVoiceLocalization.a11y_channel_play`, `a11y_channel_stop`, `a11y_channel_status_muted` | `accessibilityChannelPlay`, `accessibilityChannelStop`, `accessibilityChannelStatusMuted` |
| `LiveVoiceLocalization.action_retry_now`, `channel_list_empty`, `channel_status_is_ai` | `errorRetryNowButton`, `noChannels`, `isAiChannelStatusMessage` |
| `LiveVoiceLocalization.channel_status_offline`, `error_screen_retrying`, `error_screen_retrying_in(_:)` | `channelStatusOffline`, `errorScreenRetrying`, `errorScreenRetryingIn(_:)` |
| `LiveVoiceLocalization.sdk_no_matching_channels`, `streaming_by_title` | `sdkNoMatchingChannels`, `streamingByTitle` |
| `LiveVoiceLocalization.sdk_error_…` | removed: `LiveVoiceError(.noNetwork).message`, or the caught error's `message` |

## 12. Checklist

- [ ] Xcode 26.5 or newer; package version 3.
- [ ] Every `joinEvent` is `try await`ed, its result kept, its error caught.
- [ ] Cleanup uses `joined.leave()`; no leave before a join.
- [ ] No code waits on view state; `connection` is observed where needed.
- [ ] Custom cells call `togglePlayback()` and honour `isEnabled`.
- [ ] `.cancelled` and `.superseded` are not shown to users.
- [ ] Subtitle, available-subtitle and audio-output code uses the new types.
- [ ] `LiveVoiceLocalization` names updated; error texts come from `error.message`.
