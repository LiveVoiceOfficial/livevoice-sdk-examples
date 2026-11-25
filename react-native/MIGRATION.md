# Migrating from SDK 2.x to 3.0 (React Native)

## At a glance

- Every call that changes something returns a promise: await it, and catch a `LiveVoiceError`.
- `initialize()` is awaited before the first join; the Android foreground service is now on by
  default and has no message.
- `joinEvent` takes one object and resolves when the event is ready, with a
  `LiveVoiceJoinedEvent`.
- `startChannel(id)` is removed: playback starts from a channel cell. `renderChannel` became
  `renderChannelCell`, whose cell has `togglePlayback()`.
- Every `onXChanged(cb)` is now `addXListener(cb)`, with a `useLiveVoiceX()` hook beside it.
- The connection is a value of its own (`useLiveVoiceConnection()`); the UI state is removed.
- No 2.x symbol is kept as a deprecated alias: each one is a type error in TypeScript.

## 1. Requirements and installation

New requirements: React Native 0.81 or newer, Xcode 26.5 or newer (Swift 6.3) and JDK 21 for
Android builds. Raise the package's version to 3 and run `pod install` again.

The wrapper is still installed with CocoaPods, but it now brings the native iOS SDK as a Swift
package; the `LiveVoiceSDK` CocoaPod is no longer published. Remove any `pod 'LiveVoiceSDK'` line
from your Podfile.

## 2. Initialization

```tsx
// 2.x, at module scope
initialize(serviceEnabledWithMessage("Channel %s is playing!"));

// 3.0, awaited before screens that join are rendered
useEffect(() => {
  initialize().then(() => setReady(true), (error: LiveVoiceError) => console.warn(error.code));
}, []);
```

Calls that need it reject with `not_initialized` until it resolved; reading values and adding
listeners works before. Options: `androidServiceConfig` (`{ kind: 'enabled' }` by default; it was
disabled by default in 2.x), `audioFocus`, `showsSystemMediaControls`. The same options again
change nothing; changed ones apply only while the connection is `idle` or `failed` and reject
with `invalid_argument` otherwise.

## 3. Joining and leaving

```tsx
// 2.x
joinEvent(joinCode, password, apiKey);
leaveEvent();

// 3.0
try {
  joined = await joinEvent({ joinCode, password, apiKey });
} catch (error) {
  const failed = error as LiveVoiceError;
  if (failed.code === 'cancelled' || failed.code === 'superseded') return;
  setFailure(failed);
}
await joined.leave();                    // or: await leaveEvent()
```

- `joinEvent` resolves when the event is ready: authenticated, its state loaded, commands
  accepted. It does not wait for audio. Await it; do not watch the view to learn that it completed.
- An awaited join, leave, reconnect and switch wait for five observed values only: connection,
  current event, linked events, requestable languages, available subtitles. The features, the
  subtitle state and the channel list follow shortly: observe them. After every other call the
  observed value follows shortly too.
- A join replaces the current event, also when it then fails: the earlier event is left and the
  connection ends `failed`. Only a join refused with `invalid_argument` leaves the current event
  untouched. A pending earlier join rejects with `superseded`. A join never retries by itself.
- `joined.leave()` leaves only that join and does nothing once a newer join replaced it, so an
  effect's cleanup cannot leave the next screen's event. `leaveEvent()` leaves whatever is
  joined or joining, any number of times, and ends a pending join with `cancelled`.
- Limits: a join rejects with `timed_out` after 30 seconds, counted from the call and including
  the cleanup of the previous event, but not the time a password is entered. A leave rejects
  with `leave_incomplete` after 5 seconds: the event is left all the same, the connection is
  `idle`, the cleanup continues and the next join waits for it.
- A pending call cannot be cancelled by its caller; leave, or join again, to end a join.

## 4. Starting and stopping playback

Playback starts only from a channel cell's toggle or the system media controls; `startChannel(id)`
is removed. `stopChannel()` stays and now returns a promise.

```tsx
// 2.x
<LiveVoiceView renderChannel={(channel, { isLastInList, onAudioPress }) => <Row onPress={onAudioPress} />} />

// 3.0
<LiveVoiceView renderChannelCell={(cell) => (
  <Pressable disabled={!cell.isEnabled} onPress={() => cell.togglePlayback().catch(setFailure)}>
    <Text>{cell.channel.name}</Text>
  </Pressable>
)} />
```

- `togglePlayback()` resolves when local playback is confirmed or has stopped; the channel's
  `playingState` follows shortly. It rejects with `timed_out` after 10 seconds and with
  `cancelled` when another start, a stop, a leave or a new join took over.
- `cell.isEnabled` is `false` while the channel is offline, has no audio, or the connection
  recovers. A start then rejects with `channel_offline` or `channel_unavailable`.
- `stopChannel()` resolves when local playback has stopped (10-second limit) and is also allowed
  while joining, reconnecting or failed. A stopped channel is not restored by a later reconnect.

## 5. Connection and reconnect

`getCurrentUiState()` and `onUiStateChanged` are removed, and `reconnect()` returns a promise.

```tsx
const connection = useLiveVoiceConnection();   // or getCurrentConnection() / addConnectionListener(cb)
// connection.status: 'idle' | 'joining' | 'ready' | 'reconnecting' | 'leaving' | 'failed'
// 'ready' and 'reconnecting' carry eventId, 'reconnecting' a retry, 'failed' an error
await reconnect();
```

The SDK reconnects by itself; `reconnect()` tries at once. It is allowed while `ready`,
`reconnecting`, or `failed` with a retryable error (it then retries the join); from `failed` with
another error it rejects with that error again, otherwise with `not_joined`. When it resolves,
the connection is `ready`, or `reconnecting` again if it dropped meanwhile; the playing channel
and subtitle choice are restored unless you stopped them. After 30 seconds it rejects with
`timed_out`, with two outcomes: on an established connection only the call fails and the event
stays joined and keeps recovering; a retried failed join ends `failed`. `failed` stays until a
leave or a new join.

## 6. Errors

2.x calls returned nothing and reported no error. In 3.0 every promise rejects with a
`LiveVoiceError` only; TypeScript types a caught value as `unknown`, so cast it:

```tsx
try { await reconnect(); } catch (error) {
  const failed = error as LiveVoiceError;
  if (failed.code === 'timed_out' && failed.isRetryable) { … } else { show(failed.message); }
}
```

It has a `code` (`LiveVoiceErrorCode`, strings such as `'timed_out'`), `isRetryable`, a localized
`message` to show as it is, and `detail`. Decide by `code`, never by the text. Do not show
`superseded` and `cancelled` to users: a newer call or a leave ended the call, nothing went
wrong. A missing custom-UI permission shows as `api_key_invalid`.

## 7. Passwords

A `password` passed to `joinEvent` is final: if it is wrong the call fails and the SDK does not
ask. Without one, the SDK looks in its memory, then in your password store, then asks your
password provider or, without a provider, shows its own prompt. The prompt needs a
`<LiveVoiceView />` on screen; without one the call fails with the password error.

```tsx
setPasswordProvider(async (request) => myPrompt(request));   // resolve null to give up
setPasswordStore(myStore);                                   // LiveVoicePasswordStore
```

## 8. Subtitles

```tsx
// 2.x
const state = getCurrentSubtitleState();           // state.type === "disabled"
onSubtitleStateChanged(setState); onAvailableSubtitleConfigsChanged(setAvailable);
startSubtitles(channelId);                         // subtitle.id, subtitle.parent

// 3.0
const state = useLiveVoiceSubtitles();             // state.kind: 'disabled' | 'automatic' | 'specific'
const available = useLiveVoiceAvailableSubtitles();
await startSubtitles({ channelId });               // subtitle.channelId, subtitle.parentChannelId
```

- `getCurrentSubtitles()` kept its name but now returns the state, not the fragments; the
  fragments are in the state.
- `startSubtitles()` without a channel is automatic mode: it follows whichever channel plays, is
  on from the call (it resolves at once when nothing plays) and never asks for a password.
- `startSubtitles({ channelId, password })` resolves when the server accepted it (10-second
  limit). One subtitle stream at a time; neither call starts or stops playback.
- The available subtitles are `null` when not joined and a list once a join resolved, empty when
  the event has none.

## 9. Custom UI

`renderChannel` was the only custom part; there are five now. Leave one out to keep the SDK's
design.

```tsx
<LiveVoiceView
  renderChannelCell={(cell) => …}
  renderLoading={() => …}
  renderReconnecting={(retry) => …}       // { kind: 'inProgress' } | { kind: 'scheduled', at: Date }
  renderError={(error, retry) => …}       // retry: (() => Promise<void>) | null
  renderEmpty={(reason) => …}             // 'noChannels' | 'noMatches'
  onCommandError={(error) => …}
/>
```

All parts but `renderLoading` need an API key that permits custom UI. While reconnecting, the
channel list stays, drawn disabled, for the first seconds before the reconnecting part shows.
`onCommandError` receives the errors of the SDK's own controls, never `cancelled` or
`superseded`; your own cell gets its errors from `togglePlayback()`.

## 10. Audio and background

The output is a preference: `setLiveVoiceUseSpeaker(true)` is now `await setAudioOutput('speaker')`
(`'system'` or `'speaker'`), read with `useLiveVoiceAudioOutput()`. New: `audioFocus` in
`initialize`, `'exclusive'` (default), `'duckOthers'` or `'hostManaged'`. The system media
controls show the playing channel, and `setNowPlayingArtwork(image)` replaces their image. On
Android the foreground service's media notification needs no `POST_NOTIFICATIONS` prompt.

Unchanged from 2.x: for playback in the background, the iOS app needs the **Audio, AirPlay, and
Picture in Picture** background mode.

## 11. Renamed and removed

Each 2.x name is a type error in 3.0.

| 2.x | 3.0 |
| --- | --- |
| `AITranslationInfo.sourceID`, `DependentChannel.sourceChannelID` | `LiveVoiceAiTranslationInfo.sourceChannelId`, `LiveVoiceDependentChannel.sourceChannelId` |
| `AvailableSubtitle`, `id`, `parent` | `LiveVoiceAvailableSubtitle`, `channelId`, `parentChannelId` |
| `Channel`, `Features`, `SubtitleState` (`type`) | `LiveVoiceChannel`, `LiveVoiceFeatures`, `LiveVoiceSubtitleState` (`kind`) |
| `getCurrentAudioState()`, `onAudioOutputChanged`, `setLiveVoiceUseSpeaker(bool)` | `getCurrentAudioOutput()`, `addAudioOutputListener`, `setAudioOutput(output)` |
| `getCurrentClaims()`, `onFeaturesChanged` | `getCurrentFeatures()`, `addFeaturesListener`, `useLiveVoiceFeatures()` |
| `getCurrentSubtitleConfiguration()`, `onAvailableSubtitleConfigsChanged` | `getCurrentAvailableSubtitles()`, `addAvailableSubtitlesListener` |
| `getCurrentSubtitleState()`, `onSubtitleStateChanged`, `onSubtitlesChanged` | `getCurrentSubtitles()`, `addSubtitlesListener` |
| `getCurrentUiState()`, `onUiStateChanged`, `UiState` | `getCurrentConnection()`, `addConnectionListener`, `LiveVoiceConnection` |
| `joinEvent(joinCode, password, apiKey)` | `joinEvent({ joinCode, password, apiKey })` |
| `PlayingState.STOPPED`, `TRANSITIONING`, `PLAYING` | `'stopped'`, `'transitioning'`, `'playing'` |
| `renderChannel`, `isLastInList`, `onAudioPress` | `renderChannelCell`, `cell.isLast`, `cell.togglePlayback()` |
| `serviceDisabled` | `{ kind: 'disabled' }` |
| `serviceEnabledWithDefaultMessage`, `serviceEnabledWithMessage(…)` | `{ kind: 'enabled' }`, the default |
| `startChannel(id)` | removed: the cell's `togglePlayback()` |
| `startSubtitles(channelId)` | `startSubtitles({ channelId, password })` |
| `Translations.sdkError…()` | removed: the caught error's `message` |

## 12. Checklist

- [ ] React Native 0.81 or newer; package version 3.
- [ ] `initialize()` awaited before screens that join; the foreground service option reviewed.
- [ ] Every `joinEvent` takes an object and is awaited, its result kept, its error caught.
- [ ] Cleanup uses `joined.leave()`; no leave before a join.
- [ ] No code reads the UI state; the connection, features and subtitle state are observed.
- [ ] Custom cells call `togglePlayback()` and honour `isEnabled`.
- [ ] `cancelled` and `superseded` are not shown to users.
- [ ] Listeners renamed to `addXListener` or replaced by hooks; subtitle and audio code updated.
