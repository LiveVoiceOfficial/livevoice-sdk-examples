# Migrating from SDK 2.x to 3.0 (Flutter)

## At a glance

- Every call that changes something is awaited and throws one error type, `LiveVoiceException`.
- `joinEvent` completes when the event is ready, with a `LiveVoiceJoinedEvent`.
- Playback starts from a channel cell: `cellBuilder` became `channelCellBuilder`, whose cell has
  `togglePlayback()` instead of `onAudioPressed`.
- State is read from `ValueListenable`s (`connection`, `subtitles`, `features`, …); the
  `getCurrent…()` functions and `on…Changed` streams are removed.
- The Android foreground service is now on by default and has no message.
- Flutter 3.44 is required, and iOS builds through Swift Package Manager.
- No 2.x symbol is kept as a deprecated alias: each one is a compile error until changed.

## 1. Requirements and installation

New requirements: Flutter 3.44 or newer (was 3.41; building with Xcode 27 needs 3.44.8 or newer),
Xcode 26.5 or newer (Swift 6.3), `compileSdk` 36 or newer and JDK 21. Raise the package's version
to 3.

The iOS part now builds with Swift Package Manager, which Flutter enables by default. An app that
still uses CocoaPods for its runner moves to Swift Package Manager, as the sample did when it
deleted `ios/Podfile` and the `Pods` includes in `ios/Flutter/Debug.xcconfig` and
`Release.xcconfig`.

## 2. Initialization

```dart
// 2.x
await initialize(androidServiceConfig: const LiveVoiceServiceEnabled(message: 'Channel %s is playing!'));

// 3.0
try {
  await initialize();
} on LiveVoiceException catch (error) { … }
```

Calls that need it throw `notInitialized` until it completed. Options: `androidServiceConfig`
(`const LiveVoiceForegroundServiceConfigEnabled()` by default; it was disabled by default in
2.x), `audioFocus`, `showsSystemMediaControls`. The same options again change nothing; changed
ones apply only while the connection is idle or failed and throw `invalidArgument` otherwise.

## 3. Joining and leaving

```dart
// 2.x
joinEvent(joinCode: code, password: password, apiKey: key);        // not awaited
await leaveEvent();

// 3.0
try {
  joined = await joinEvent(joinCode: code, password: password, apiKey: key);
} on LiveVoiceException catch (error) {
  if (error.code == LiveVoiceErrorCode.cancelled || error.code == LiveVoiceErrorCode.superseded) return;
  setState(() => failure = error);
}
await joined.leave();                    // or: await leaveEvent()
```

- `joinEvent` completes when the event is ready: authenticated, its state loaded, commands
  accepted. It does not wait for audio. Await it; do not watch the view to learn that it completed.
- An awaited join, leave, reconnect and switch wait for five observed values only: `connection`,
  `currentEvent`, `linkedEvents`, `requestableLanguages`, `availableSubtitles`. `features`,
  `subtitles` and the channel list follow shortly: listen to them. After every other call the
  observed value follows shortly too.
- A join replaces the current event, also when it then fails: the earlier event is left and the
  connection ends failed. Only a join refused with `invalidArgument` leaves the current event
  untouched. A pending earlier join throws `superseded`. A join never retries by itself.
- `joined.leave()` leaves only that join and does nothing once a newer join replaced it, so a
  screen's `dispose` cannot leave the next screen's event. `leaveEvent()` leaves whatever is
  joined or joining, any number of times, and ends a pending join with `cancelled`.
- Limits: a join throws `timedOut` after 30 seconds, counted from the call and including the
  cleanup of the previous event, but not the time a password is entered. A leave throws
  `leaveIncomplete` after 5 seconds: the event is left all the same, the connection is idle, the
  cleanup continues and the next join waits for it.
- A pending call cannot be cancelled by its caller; leave, or join again, to end a join.

## 4. Starting and stopping playback

Playback starts only from a channel cell's toggle or the system media controls; there is no call
that starts a channel by its id. `stopChannel()` is new and stops whatever plays.

```dart
// 2.x
LiveVoiceView(cellBuilder: (context, channel, cell) => MyRow(channel: channel, onTap: cell.onAudioPressed))

// 3.0
LiveVoiceView(channelCellBuilder: (context, cell) => MyRow(
  channel: cell.channel,
  onTap: cell.isEnabled ? () => cell.togglePlayback().catchError(showError) : null,
))
```

- `togglePlayback()` completes when local playback is confirmed or has stopped; the channel's
  `playingState` follows shortly. It throws `timedOut` after 10 seconds and `cancelled` when
  another start, a stop, a leave or a new join took over.
- `cell.isEnabled` is `false` while the channel is offline, has no audio, or the connection
  recovers. A start then throws `channelOffline` or `channelUnavailable`.
- `stopChannel()` completes when local playback has stopped (10-second limit) and is also allowed
  while joining, reconnecting or failed. A stopped channel is not restored by a later reconnect.

## 5. Connection and reconnect

2.x had no connection value. 3.0 has `connection`, and `reconnect()` completes when the new connection is ready:

```dart
ValueListenableBuilder<LiveVoiceConnection>(
  valueListenable: connection,
  builder: (context, connection, _) => switch (connection) {
    LiveVoiceConnectionIdle() || LiveVoiceConnectionJoining() || LiveVoiceConnectionLeaving() => …,
    LiveVoiceConnectionReady(:final eventId) => …,
    LiveVoiceConnectionReconnecting() => …,
    LiveVoiceConnectionFailed(:final error) => …,      // stays until a leave or a new join
  },
);
await reconnect();
```

The SDK reconnects by itself; `reconnect()` tries at once. It is allowed while ready,
reconnecting, or failed with a retryable error (it then retries the join); from failed with
another error it throws that error again, otherwise `notJoined`. When it completes, the
connection is ready, or reconnecting again if it dropped meanwhile; the playing channel and
subtitle choice are restored unless you stopped them. After 30 seconds it throws `timedOut`, with
two outcomes: on an established connection only the call fails and the event stays joined and
keeps recovering; a retried failed join ends failed.

## 6. Errors

```dart
// 2.x
try { … } catch (_) {}

// 3.0
try { await reconnect(); } on LiveVoiceException catch (error) {
  if (error.code == LiveVoiceErrorCode.timedOut && error.isRetryable) { … } else { show(error.message); }
}
```

`LiveVoiceException` has a `code` (`LiveVoiceErrorCode`), `isRetryable`, a localized `message` to
show as it is, and `detail`. Decide by `code`, never by the text. Do not show `superseded` and
`cancelled` to users: a newer call or a leave ended the call, nothing went wrong. A missing
custom-UI permission shows as `apiKeyInvalid`.

## 7. Passwords

A `password` passed to `joinEvent` is final: if it is wrong the call fails and the SDK does not
ask. Without one, the SDK looks in its memory, then in your password store, then asks your
password provider or, without a provider, shows its own prompt. The prompt needs a
`LiveVoiceView` on screen; without one the call fails with the password error.

```dart
setPasswordProvider((request) async => myPrompt(request));   // return null to give up
setPasswordStore(myStore);                                   // extends LiveVoicePasswordStore
```

## 8. Subtitles

```dart
// 2.x
final state = await getCurrentSubtitleState();     // LiveVoiceSubtitlesDisabled, …Automatic, …Specific
onSubtitleStateChanged.listen(…); onAvailableSubtitleConfigsChanged.listen(…);
startSubtitles(channelId: id);                     // not awaited; subtitle.id, subtitle.parent

// 3.0
final fragments = switch (subtitles.value) {       // a ValueListenable<LiveVoiceSubtitleState>
  LiveVoiceSubtitleStateAutomatic(:final fragments) => fragments,
  LiveVoiceSubtitleStateSpecific(:final fragments) => fragments,
  LiveVoiceSubtitleStateDisabled() => null,
};
await startSubtitles(channelId: id);               // subtitle.channelId, subtitle.parentChannelId
```

- `startSubtitles()` without a channel is automatic mode: it follows whichever channel plays, is
  on from the call (it completes at once when nothing plays) and never asks for a password.
- `startSubtitles(channelId:, password:)` completes when the server accepted it (10-second
  limit). One subtitle stream at a time; neither call starts or stops playback.
- `availableSubtitles.value` is `null` when not joined and a list once a join completed, empty
  when the event has none.

## 9. Custom UI

`cellBuilder` was the only custom part; there are five now. Leave one out to keep the SDK's
design.

```dart
LiveVoiceView(
  channelCellBuilder: (context, cell) => …,
  loadingBuilder: (context) => …,
  reconnectingBuilder: (context, retry) => …,      // LiveVoiceRetryInProgress, LiveVoiceRetryScheduled(at)
  errorBuilder: (context, error, retry) => …,      // retry: Future<void> Function()?
  emptyBuilder: (context, reason) => …,            // LiveVoiceEmptyReason.noChannels, .noMatches
  onCommandError: (error) => …,
)
```

All parts but `loadingBuilder` need an API key that permits custom UI. While reconnecting, the
channel list stays, drawn disabled, for the first seconds before the reconnecting part shows.
`onCommandError` receives the errors of the SDK's own controls, never `cancelled` or
`superseded`; your own cell gets its errors from `togglePlayback()`.

## 10. Audio and background

The output is a preference: `setLiveVoiceUseSpeaker(true)` is now
`await setAudioOutput(LiveVoiceAudioOutput.speaker)` (`system` or `speaker`), read from the
`audioOutput` listenable. New: `audioFocus` in `initialize`, `LiveVoiceAudioFocus.exclusive`
(default), `duckOthers` or `hostManaged`. The system media controls show the playing channel,
and `setNowPlayingArtwork(assetName)` replaces their image.

Unchanged from 2.x: for playback in the background, the iOS runner needs the **Audio, AirPlay, and
Picture in Picture** background mode.

## 11. Renamed and removed

Each 2.x name is a compile error in 3.0.

| 2.x | 3.0 |
| --- | --- |
| `cellBuilder: (context, channel, cell)`, `cell.onAudioPressed` | `channelCellBuilder: (context, cell)`, `cell.channel`, `cell.togglePlayback()` |
| `getCurrentAudioState()`, `onAudioOutputChanged`, `setLiveVoiceUseSpeaker(bool)` | `audioOutput`, `setAudioOutput(LiveVoiceAudioOutput)` |
| `getCurrentFeatures()`, `onFeaturesChanged` | `features` |
| `getCurrentSubtitleConfiguration()`, `onAvailableSubtitleConfigsChanged` | `availableSubtitles` |
| `getCurrentSubtitleState()`, `onSubtitleStateChanged` | `subtitles` |
| `LiveVoiceAvailableSubtitle.id`, `parent` | `channelId`, `parentChannelId` |
| `LiveVoiceServiceDisabled()` | `LiveVoiceForegroundServiceConfigDisabled()` |
| `LiveVoiceServiceEnabled(message:)` | `LiveVoiceForegroundServiceConfigEnabled()`, the default |
| `LiveVoiceSubtitlesDisabled`, `LiveVoiceSubtitlesAutomatic`, `LiveVoiceSubtitlesSpecific` | `LiveVoiceSubtitleStateDisabled`, `LiveVoiceSubtitleStateAutomatic`, `LiveVoiceSubtitleStateSpecific` |
| `LiveVoiceUiState` and its subclasses | removed: `connection`, `LiveVoiceConnection` |
| `LiveVoiceAudioOutputSwitch`, `LiveVoiceColors` and the other widgets beside `LiveVoiceView` | removed: build on `audioOutput` and the parts of section 9 |
| `translations.sdkError…()` | removed: the caught error's `message` |

## 12. Checklist

- [ ] Flutter 3.44 or newer; package version 3; the iOS runner builds through Swift Package Manager.
- [ ] `initialize()` awaited inside `try`; the foreground service option reviewed.
- [ ] Every `joinEvent` is awaited, its result kept, its error caught.
- [ ] Cleanup uses `joined.leave()`; no leave before a join.
- [ ] No code reads the UI state; `connection`, `features` and `subtitles` are listened to.
- [ ] Custom cells call `togglePlayback()` and honour `isEnabled`.
- [ ] `cancelled` and `superseded` are not shown to users.
- [ ] Getters and streams replaced by the listenables; subtitle and audio code updated.
