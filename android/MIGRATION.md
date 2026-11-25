# Migrating from SDK 2.x to 3.0 (Android)

## At a glance

- `joinEvent` returns when the event is ready, with a `LiveVoiceJoinedEvent`; in 2.x its
  coroutine lasted as long as the event.
- `leaveEvent`, `reconnect`, `stopChannel`, `startSubtitles` and `stopSubtitles` are suspend
  functions and throw one error type, `LiveVoiceException`.
- `LiveVoice.startChannel(channelId)` is removed: playback starts from a channel cell.
- `LiveVoice.uiState` is removed; observe `LiveVoice.connection`.
- `LiveVoiceView`'s `channelDisplay`, `loadingDisplay`, `errorDisplay` and
  `noMatchingChannelsDisplay` became `channelCell`, `loading`, `reconnecting`, `error`, `empty`.
- Initialize in your `Application`, and drop the `POST_NOTIFICATIONS` request made for LiveVoice.
- No 2.x symbol is kept as a deprecated alias: each one is a compile error until changed.

## 1. Requirements and installation

New requirements: `compileSdk` 36 or newer and JDK 21 for the build. Android 6.0 (API 23) stays
the minimum. The Maven repository and artifact are unchanged; raise the version to 3.

## 2. Initialization

Initialize once per process, in `Application.onCreate`. The SDK belongs to the process: a
recreated Activity keeps the joined event and the playing channel.

```kotlin
// 2.x, in Activity.onCreate
initializeLiveVoice(foregroundServiceConfig = ForegroundServiceConfig.enabledWithDefaultMessage)

// 3.0, in Application.onCreate
LiveVoice.initializeLiveVoice(applicationContext = this)
```

Calls before it throw `NOT_INITIALIZED`. The same configuration again changes nothing. A changed
one (`foregroundServiceConfig`, `audioFocus`) applies only while the connection is `Idle` or
`Failed`; otherwise it throws `INVALID_ARGUMENT` and changes nothing.

## 3. Joining and leaving

```kotlin
// 2.x
LiveVoice.leaveEvent()
joinJob = lifecycleScope.launch { LiveVoice.joinEvent(joinCode = c, password = p, apiKey = k) }

// 3.0
applicationScope.launch {
    try {
        joined = LiveVoice.joinEvent(joinCode = c, password = p, apiKey = k)
    } catch (error: LiveVoiceException) {
        if (error.code == LiveVoiceErrorCode.CANCELLED || error.code == LiveVoiceErrorCode.SUPERSEDED) return@launch
        failure = error
    }
}
joined.leave()                           // or: LiveVoice.leaveEvent(); both suspend
```

- `joinEvent` returns when the event is ready: authenticated, its state loaded, commands
  accepted. It does not wait for audio. `connection`, `currentEvent`, `linkedEvents`,
  `requestableLanguages` and `availableSubtitles` then show the joined event. Await the call; do
  not watch the view to learn that it completed.
- A join replaces the current event, also when it then fails: the earlier event is left and the
  connection ends `Failed`. Only a join refused with `INVALID_ARGUMENT` leaves the current event
  untouched. A pending earlier join throws `SUPERSEDED`. A join never retries by itself.
- `joined.leave()` leaves only that join and does nothing once a newer join replaced it, so a
  screen's cleanup cannot leave the next screen's event. `leaveEvent()` leaves whatever is joined
  or joining, any number of times, and ends a pending join with `CANCELLED`.
- Limits: a join throws `TIMED_OUT` after 30 seconds, counted from the call and including the
  cleanup of the previous event, but not the time a password is entered. A leave throws
  `LEAVE_INCOMPLETE` after 5 seconds: the event is left all the same, the connection is `Idle`,
  the cleanup continues and the next join waits for it.
- Cancelling the coroutine of a pending join leaves the event and throws Kotlin's
  `CancellationException`, not a `LiveVoiceException`: join in a scope that outlives the screen.
  A finished join outlives its coroutine, and a cancelled caller does not stop a leave.

## 4. Starting and stopping playback

Playback starts only from a channel cell's toggle or the system media controls;
`LiveVoice.startChannel(channelId)` is removed. `stopChannel(channelId)` is now `stopChannel()`.

```kotlin
// 2.x
val MyRow: ChannelCellDisplay = { channel, isLastInList, onAudioClick -> Row(Modifier.clickable(onClick = onAudioClick)) { … } }
LiveVoiceView(channelDisplay = MyRow)

// 3.0
LiveVoiceView(channelCell = { cell ->
    Row(Modifier.clickable(enabled = cell.isEnabled) { scope.launch { cell.togglePlayback() } }) { … }
})
```

- `togglePlayback()` returns when local playback is confirmed or has stopped; the channel's
  `playingState` in the state follows. It throws `TIMED_OUT` after 10 seconds and `CANCELLED`
  when another start, a stop, a leave or a new join took over. Catch its error in your cell.
- `cell.isEnabled` is `false` while the channel is offline, has no audio, or the connection
  recovers. A start then throws `CHANNEL_OFFLINE` or `CHANNEL_UNAVAILABLE`.
- `stopChannel()` returns when local playback has stopped (10-second limit) and is also allowed
  while joining, reconnecting or failed. A stopped channel is not restored by a later reconnect.

## 5. Connection and reconnect

`LiveVoice.uiState` (`SdkUiState`) is removed, and `reconnect()` is now a suspend function.

```kotlin
val connection by LiveVoice.connection.collectAsState()
when (val c = connection) {
    LiveVoiceConnection.Idle, LiveVoiceConnection.Joining, LiveVoiceConnection.Leaving -> …
    is LiveVoiceConnection.Ready -> c.eventId
    is LiveVoiceConnection.Reconnecting -> c.retry
    is LiveVoiceConnection.Failed -> c.error      // stays until a leave or a new join
}
LiveVoice.reconnect()
```

The SDK reconnects by itself; `reconnect()` tries at once. It is allowed while `Ready`,
`Reconnecting`, or `Failed` with a retryable error (it then retries the join); from `Failed` with
another error it throws that error again, otherwise `NOT_JOINED`. When it returns, the connection
is `Ready`, or `Reconnecting` again if it dropped meanwhile; the playing channel and subtitle
choice are restored unless you stopped them. After 30 seconds it throws `TIMED_OUT`, with two
outcomes: on an established connection only the call fails and the event stays joined and keeps
recovering; a retried failed join ends `Failed`.

## 6. Errors

```kotlin
// 2.x
is SdkUiState.Error -> error.message          // also SdkUninitializedException, SdkNotConnectedException

// 3.0
catch (error: LiveVoiceException) { if (error.code == LiveVoiceErrorCode.TIMED_OUT) … else show(error.message) }
```

`LiveVoiceException` has a `code` (`LiveVoiceErrorCode`), `isRetryable`, a localized `message` to
show as it is, and `detail`. Decide by `code`, never by the text. Do not show `SUPERSEDED` and
`CANCELLED` to users: a newer call or a leave ended the call, nothing went wrong. A missing
custom-UI permission shows as `API_KEY_INVALID`.

## 7. Passwords

`joinEvent(password = …)` works as before, but a password you pass is final: if it is wrong the
call fails and the SDK does not ask. Without one, the SDK looks in its memory, then in your
`passwordStore`, then asks your `passwordProvider` or, without a provider, shows its own prompt.
The prompt needs a `LiveVoiceView` on screen; without one the call fails with the password error.

```kotlin
LiveVoice.passwordProvider = LiveVoicePasswordProvider { request -> myPrompt(request) }   // null gives up
LiveVoice.passwordStore = myStore                                                        // LiveVoicePasswordStore
```

## 8. Subtitles

```kotlin
// 2.x
val state by LiveVoice.subtitleState.collectAsState()        // SdkSubtitleState, fragments a StateFlow
LiveVoice.startSubtitles(channelId)                          // not suspending

// 3.0
val state by LiveVoice.subtitles.collectAsState()            // LiveVoiceSubtitleState
val fragments = when (val s = state) {
    is LiveVoiceSubtitleState.Automatic -> s.fragments       // a plain List<String>
    is LiveVoiceSubtitleState.Specific -> s.fragments
    LiveVoiceSubtitleState.Disabled -> null
}
scope.launch { LiveVoice.startSubtitles(channelId = id) }    // suspends and throws
```

- `startSubtitles()` without a channel is automatic mode: it follows whichever channel plays, is
  on from the call (it returns at once when nothing plays) and never asks for a password.
- `startSubtitles(channelId, password)` returns when the server accepted it (10-second limit).
  One subtitle stream at a time; neither call starts or stops playback.
- `availableSubtitles` is now a `StateFlow<List<LiveVoiceAvailableSubtitle>?>`: `null` when not
  joined and a list once a join returned, empty when the event has none.

## 9. Custom UI

The display parameters became five parts. Leave one out to keep the SDK's design.

```kotlin
// 2.x
LiveVoiceView(channelDisplay = MyRow, loadingDisplay = MyLoading, errorDisplay = MyError)   // errorDisplay also drew reconnecting

// 3.0
LiveVoiceView(
    channelCell = { cell -> … },
    loading = { … },
    reconnecting = { retry -> … },        // LiveVoiceRetry.InProgress, Scheduled(atEpochMilliseconds)
    error = { error, retry -> … },        // retry: (suspend () -> Unit)?
    empty = { reason -> … },              // NO_CHANNELS, NO_MATCHES
    onCommandError = { error -> … },
)
```

All parts but `loading` need an API key that permits custom UI. While reconnecting, the channel
list stays, drawn disabled, for the first seconds before the reconnecting part shows.
`onCommandError` receives the errors of the SDK's own controls, never `CANCELLED` or
`SUPERSEDED`; your own cell gets its errors from `togglePlayback()`.

## 10. Audio and background

The output is a preference: `LiveVoice.changeOutput(useLoudSpeaker = true)` is now the suspending
`LiveVoice.setAudioOutput(LiveVoiceAudioOutput.SPEAKER)`, and `outputMode` is `audioOutput`
(`SYSTEM` or `SPEAKER`). New: `audioFocus` in `initializeLiveVoice`, with `EXCLUSIVE` (default),
`DUCK_OTHERS` or `HOST_MANAGED`. The foreground service is `LiveVoiceForegroundServiceConfig.Enabled`
by default and has no message any more; it shows the system media controls, whose image
`LiveVoice.nowPlayingArtwork` replaces. Its media notification needs no `POST_NOTIFICATIONS`
prompt, so remove the permission and its runtime request if you added them only for LiveVoice.

## 11. Renamed and removed

Each 2.x name is a compile error in 3.0.

| 2.x | 3.0 |
| --- | --- |
| `AiTranslationInfo`, `DependentChannel` | `LiveVoiceAiTranslationInfo`, `LiveVoiceDependentChannel` |
| `AudioSwitchView`, `AudioSwitchDisplay` | removed: build a switch on `audioOutput` and `setAudioOutput` |
| `AvailableSubtitle` (`Transcript`, `Translated`), a `Set` | `LiveVoiceAvailableSubtitle`, a nullable `List` |
| `ChannelCellDisplay`, `channelDisplay` | `channelCell` with a `LiveVoiceChannelCell` |
| `ErrorDisplay`, `errorDisplay`; `LoadingDisplay`, `loadingDisplay` | `error` and `reconnecting`; `loading` |
| `ForegroundServiceConfig`, `enabledWithDefaultMessage`, `NotificationText` | `LiveVoiceForegroundServiceConfig.Enabled` / `Disabled` |
| `LiveVoice.changeOutput(useLoudSpeaker)`, `outputMode`, `LiveVoiceOutput.HEADPHONES` | `setAudioOutput(output)`, `audioOutput`, `LiveVoiceAudioOutput.SYSTEM` |
| `LiveVoice.startChannel(channelId)` | removed: the cell's `togglePlayback()` |
| `LiveVoice.stopChannel(channelId)` | `LiveVoice.stopChannel()` |
| `LiveVoice.subtitleState`, `SdkSubtitleState` | `LiveVoice.subtitles`, `LiveVoiceSubtitleState` |
| `LiveVoice.uiState`, `SdkUiState` | `LiveVoice.connection`, `LiveVoiceConnection` |
| `LiveVoicePlayingState.Stopped`, `Connecting`, `Stopping`, `Playing` | `STOPPED`, `TRANSITIONING`, `PLAYING` |
| `NoMatchingChannelsDisplay`, `noMatchingChannelsDisplay` | `empty` with a `LiveVoiceEmptyReason` |
| `SdkRetryState.AwaitingNextReconnectAttempt`, `RetryInProgress` | `LiveVoiceRetry.Scheduled(atEpochMilliseconds)`, `InProgress` |
| `SdkUninitializedException`, `SdkNotConnectedException` | `LiveVoiceException` with `NOT_INITIALIZED`, `NOT_JOINED` |
| `Translations.sdkError…()`, the `sdk_error_…` string resources | removed: `LiveVoiceException(LiveVoiceErrorCode.NO_NETWORK).message`, or the caught error's `message` |

## 12. Checklist

- [ ] `compileSdk` 36 or newer, JDK 21; dependency version 3.
- [ ] `initializeLiveVoice` moved to the `Application`; the `POST_NOTIFICATIONS` request removed.
- [ ] Every `joinEvent` runs in a scope that outlives the screen, its result kept, its error caught.
- [ ] Cleanup uses `joined.leave()`; no leave before a join.
- [ ] No code reads `uiState`; `connection` is collected where needed.
- [ ] Custom cells call `togglePlayback()` and honour `isEnabled`.
- [ ] `CANCELLED` and `SUPERSEDED` are not shown to users.
- [ ] Subtitle, available-subtitle and audio-output code uses the new types and suspend calls.
