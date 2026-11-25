# LiveVoice SDK Sample App — Android

A Jetpack Compose sample app showing how to integrate the LiveVoice SDK (minimum: Android 6.0,
API 23, for the SDK and the sample). See the [top-level README](../README.md) for the list of
demos and how the samples are organized.

Coming from SDK 2.x? See the [migration guide](MIGRATION.md).

The SDK plays a channel's audio and shows its subtitles; video will be supported in an upcoming
version. Until then a channel with video and audio plays its audio, and a channel with only video
cannot be played.

## Run the sample

Open the [android](.) directory as a project in Android Studio and use the **Run** action in
the top right.

The parts an integration needs are:

- [`SampleApplication.kt`](app/src/main/java/io/livevoice/example/SampleApplication.kt):
  initializes the SDK once per process in `Application.onCreate`.
- [`DemoSession.kt`](app/src/main/java/io/livevoice/example/demo/DemoSession.kt): joins the
  event picked in the toolbar.
- [`screens/`](app/src/main/java/io/livevoice/example/screens): one feature per screen, each with
  a note at the top on what it shows and which calls it uses.

## Integrating the SDK into your app

Requires Android 6.0 (API 23) or newer, `compileSdk` 36 or newer and JDK 21 for the build. The
sample declares `minSdk` 23 and `compileSdk` 37.

### 1. Add the repository

Add the _LiveVoice Android repository_ in your project's `settings.gradle.kts` file, or in the
root `build.gradle.kts` file.

```kotlin
// settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        maven { url = uri("https://sdks.livevoice.io/android") }
    }
}

// or build.gradle.kts (root)
allprojects {
    repositories {
        maven { url = uri("https://sdks.livevoice.io/android") }
    }
}
```

### 2. Add the dependency

Add the dependency to your app's `build.gradle.kts` file, with the SDK version you use. This
sample pins its version in [`app/build.gradle.kts`](app/build.gradle.kts).

```kotlin
implementation("io.livevoice.sdk:android:<version>")
```

### 3. Initialize the SDK

Initialize the SDK once per process, before any other call to `LiveVoice`, in your
`Application`'s `onCreate`. The SDK belongs to the process, not to an Activity: a recreated
Activity keeps the joined event and the playing channel.

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        LiveVoice.initializeLiveVoice(applicationContext = this)
    }
}
```

Register the class in your `AndroidManifest.xml` with `<application android:name=".MyApplication">`.

`initializeLiveVoice` also takes `foregroundServiceConfig`, the foreground service that keeps
playback going in the background (see [Background audio](#background-audio)), and `audioFocus`,
how LiveVoice shares the audio output with other apps: `LiveVoiceAudioFocus.EXCLUSIVE`, the
default, pauses other audio while a channel plays; `DUCK_OTHERS` lets it play on, quieter;
`HOST_MANAGED` leaves the audio focus to your app. Calling `initializeLiveVoice` again with the
same configuration changes nothing. A changed configuration applies only while no event is joined
(`LiveVoice.connection` is `Idle` or `Failed`) and throws a `LiveVoiceException` with
`INVALID_ARGUMENT` otherwise. The sample keeps its configuration in `LiveVoiceSetup` in
`SampleApplication.kt`.

### 4. Join an event and show the channels

Join the event with `LiveVoice.joinEvent(joinCode, password, apiKey)` and show the
`LiveVoiceView()` composable. `joinEvent` is a suspend function that returns once the event is
ready; `password` is optional. Playback starts when a listener taps a channel in the view, or from
the system media controls. There is no call that starts a channel by its id: a custom cell starts
and stops its channel with `togglePlayback()`, and `LiveVoice.stopChannel()` stops whatever plays.

```kotlin
// Cancelling a pending joinEvent cancels the join, so join in a scope that outlives the screen.
val applicationScope = MainScope()

fun join() {
    applicationScope.launch {
        try {
            val joined = LiveVoice.joinEvent(joinCode = "123456", apiKey = "YOUR_API_KEY")
            // Keep `joined` and call `joined.leave()` when you are done with the event.
        } catch (error: LiveVoiceException) {
            // CANCELLED and SUPERSEDED mean a leave or a newer join ended this one. The view
            // shows connection failures itself; error.code says what went wrong.
        }
    }
}

@Composable
fun Channels() {
    LiveVoiceView()
}
```

A finished join outlives its coroutine: only `joined.leave()` or `LiveVoice.leaveEvent()` ends it.
Joining again leaves the previous event. `LiveVoice.connection` is a `StateFlow` with where the
connection is (`Idle`, `Joining`, `Ready`, `Reconnecting`, `Leaving`, `Failed`), and
`LiveVoice.reconnect()` reconnects at once.

Protected events and channels need no code of yours: a `LiveVoiceView` on screen asks for the
password, and the SDK remembers an accepted one while the process lives. A password you pass to
`joinEvent` is final: a wrong one fails without a prompt. To ask with your own UI
(`LiveVoice.passwordProvider`) or keep passwords longer (`LiveVoice.passwordStore`), see the
Password-protected channels screen.

The [`screens/`](app/src/main/java/io/livevoice/example/screens) show the rest: filtering
channels, a custom channel cell and custom view states, subtitles, audio output, the lock screen
and audio sharing, passwords, language requests, linked events, branding, localization and
diagnostics.

### What a completed call guarantees

Joining, leaving, switching and reconnecting finish only when their result is final, so the next
line of your code can rely on it:

| Call | Finishes when | What is true then |
|---|---|---|
| `LiveVoice.joinEvent(...)` | The event is ready | `connection` is `Ready`, and `currentEvent`, its lists and the channels show the joined event |
| `LiveVoice.switchToLinkedEvent(event)` | The linked event is ready | The same, for the linked event. The previous event was left when the switch began. Needs an API key that permits custom UI and a ready connection |
| `LiveVoice.reconnect()` | A new connection is ready | `connection` is `Ready`, or `Reconnecting` again if it dropped meanwhile. The playing channel and the subtitle choice are restored unless you stopped them; that audio plays again is not promised |
| `joined.leave()` | That join is left | Nothing of that event plays or changes any more. Once a newer join exists it does nothing |
| `LiveVoice.leaveEvent()` | Whatever was joined or joining is left | `connection` is `Idle` and `currentEvent` is `null` |

Each row holds unless your app made a newer call in the meantime. A call that does not get there
throws a `LiveVoiceException`:

- `SUPERSEDED`: a newer join, switch or reconnect replaced it.
- `CANCELLED`: a leave ended it. Show neither of these two to the listener. Cancelling the
  coroutine of a pending join leaves the event and throws the coroutine's `CancellationException`,
  not a `LiveVoiceException`.
- `TIMED_OUT`: the event was not ready 30 seconds after the call, not counting the time a password
  is entered. A `reconnect()` that times out on an established connection fails only the call: the
  event stays joined and keeps recovering.
- `LEAVE_INCOMPLETE`: cleanup took longer than 5 seconds. The event is left all the same, and the
  next join waits for the cleanup.

Leaving one event and joining another therefore needs no waiting of your own:

```kotlin
LiveVoice.leaveEvent()
val joined = LiveVoice.joinEvent(joinCode = next, apiKey = "YOUR_API_KEY")
```

A join replaces the current event by itself, also when it then fails: the earlier event is left
and `connection` is `Failed`. Only a join refused for an invalid argument leaves the current event
untouched. Leave first only to be sure the earlier event's cleanup has finished before you join. To
move to an event linked to the current one, call `LiveVoice.switchToLinkedEvent(event)`: it leaves
and joins in one call.

## Android-specific configuration and features

### Specify the size of views

To keep e.g. the `LiveVoiceView` below a certain height, pass a `modifier` with a maximum size.
Make it scrollable as well, with the `verticalScroll(..)` modifier.

```kotlin
LiveVoiceView(
    modifier = Modifier
        .heightIn(max = 200.dp)
        .verticalScroll(rememberScrollState())
)
```

> [!TIP]
> The height the views need varies with screen size, density and the font scale the user chose.
> A height that shows the whole event on one device might not be enough on another.

### Problems downloading sources

The SDK includes an `android-x.y.z-sources.jar` file with the documentation and source code of
the LiveVoice SDK's public API, for your IDE.

It _should_ be downloaded on project sync, but Gradle sometimes doesn't resolve the source archive,
which leaves documentation and autocomplete missing.

In IntelliJ or Android Studio, configuring the `idea` plugin should solve this.

```kotlin
// build.gradle.kts
plugins {
    idea
}

idea {
    module {
        isDownloadSources = true
        isDownloadJavadoc = true
    }
}
```

Alternatively, `File > Invalidate caches > Invalidate and Restart` usually solves it as well.

### Background audio

Android limits the resources of apps in the background and with the screen off. The SDK
therefore runs a
[foreground service](https://developer.android.com/develop/background-work/services/fgs)
while a channel plays or can resume, so the system does not cut the channel's audio.

The service shows the system's media controls for the whole time it runs: a media notification,
and the player on the lock screen and in quick settings, with Play and Pause. Opening it opens
the app. `LiveVoice.nowPlayingArtwork` sets the image they show instead of the event's logo.

> [!NOTE]
> The SDK's manifest declares the service and its permissions; they are merged into your app's
> manifest during the build.

The media notification needs no `POST_NOTIFICATIONS` permission prompt: notifications of a media
session are exempt. Other notifications of your app may still need the permission; see
[Android's media-session exemption](https://developer.android.com/develop/ui/compose/notifications/notification-permission#media-sessions).

#### Disabling the service

> [!WARNING]
> This is **not recommended**. Without the service the system may stop playback once your app is
> in the background or the screen is off, and there are no system media controls (no media
> notification, no player on the lock screen or in quick settings). Only do it if your app
> already runs a foreground service of its own while it plays audio, in which case give that
> service the `android:foregroundServiceType="mediaPlayback"` type.

Pass `LiveVoiceForegroundServiceConfig.Disabled` to `initializeLiveVoice`:

```kotlin
LiveVoice.initializeLiveVoice(
    applicationContext = this,
    foregroundServiceConfig = LiveVoiceForegroundServiceConfig.Disabled,
)
```

Removing the manifest entries alone is not enough: with the default configuration the SDK still
starts the service, which is then missing.

Once the SDK is initialized with `Disabled`, you can also remove the service and its permissions
from your app's manifest by adding the following to your `AndroidManifest.xml` (with
`xmlns:tools="http://schemas.android.com/tools"` on its `<manifest>` element). Keep the
permissions if your own foreground service needs them.

```xml
<uses-permission
    android:name="android.permission.FOREGROUND_SERVICE"
    tools:node="remove" />
<uses-permission
    android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"
    tools:node="remove" />

<application>
    <service
        android:name="io.livevoice.sdk.android.publicApi.service.LiveVoiceMediaService"
        tools:node="remove" />
</application>
```
