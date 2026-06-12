# LiveVoice SDK Sample App — Android

A Jetpack Compose sample app showing how to integrate the LiveVoice SDK on Android 6.0+. See
the [top-level README](../README.md) for the list of demos and how the samples are organized.

## Run the sample

Open the [android](.) directory as a project in Android Studio and use the **Run** action in
the top right.

## Integrating the SDK into your app

### 1. Add the repositories

Specify the _LiveVoice Android repository_ either in your root `build.gradle.kts` file or the
project's `settings.gradle.kts` file.

```kotlin
// build.gradle.kts (root)
allprojects {
    repositories {
        maven { url = uri("https://sdks.livevoice.io/android") }
    }
}

// or settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        maven { url = uri("https://sdks.livevoice.io/android") }
    }
}
```

### 2. Add the dependency

Include the dependency declaration in your app's `build.gradle.kts` file.

```kotlin
implementation("io.livevoice.sdk:android:2.0.2")
```

### 3. Initialize the SDK

Before invoking any functionality of the LiveVoice SDK, it needs to be initialized. The easiest
way is inside an `Application` or `Activity` class:

```kotlin
// Application or Activity class
override fun onCreate() {
    super.onCreate()

    initializeLiveVoice()
}
```

You can also manually pass the `applicationContext` and invoke the static function.

```kotlin
LiveVoice.initializeLiveVoice(applicationContext = application)
```

### 4. Join an event and show the channels

To show the channels of your event, join the event using `LiveVoice.joinEvent(...)` and display
the `LiveVoiceView()` composable.

```kotlin
@Composable
fun App() {
    LaunchedEffect(Unit) {
        LiveVoice.joinEvent(
            joinCode = "123456",
            password = null,
            apiKey = "s09WEG5y3caQ6R2PDaG4i8R1aTooTd"
        )
    }

    LiveVoiceView()
}
```

## Android-specific configuration and features

### Specify the size of views

To ensure that e.g. the `LiveVoiceView` does not exceed a certain height, you can specify the
max size by passing a `modifier` to the view.

Make sure to also make it `scrollable` if you do that by using the `verticalScroll(..)`
modifier.

```kotlin
LiveVoiceView(
    modifier = Modifier
        .heightIn(max = 200.dp)
        .verticalScroll(rememberScrollState())
)
```

> [!TIP]
> Be aware that the height needed to render the views will vary with different screen sizes,
> densities and the font-scale chosen by the user. Hardcoding values that fully display the
> event on one device might not be enough to render them on other devices

### Problems downloading sources

The SDK includes a `android-x.y.z-sources.jar` file, which includes documentation and
source-code for public-facing APIs of the LiveVoice SDK, available in your IDE.

While this _should_ automatically be downloaded on project sync, gradle sometimes doesn't
resolve the source archive which leads to missing documentation/autocomplete.

When using IntelliJ/Android Studio, configuring the `idea` plugin should solve this.

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

Alternatively, `File > Invalidate caches > Invalidate and Restart` usually solves the issue as
well.

### Background Audio Support

As the Android OS limits resources for apps as soon as the screen is turned off or they are in
the background, the SDK comes with built-in support for automatically launching a
[ForegroundService](https://developer.android.com/develop/background-work/services/fgs)
whenever a channel is being played, which prevents the OS from cutting the audio of the channel
being played.

This service will automatically be run while audio is being played and requires showing a
notification for the whole duration, which will also re-open the app when clicked.

> [!NOTE]
> As of version 2.0.0, The LiveVoice SDK comes with the necessary manifest entries for running
> the foreground service, which will automatically be merged into your app's manifest during
> build.

#### Integration into the app

The manifest permissions include showing notifications, limited to Android SDK versions 34 and
up. While the manifest already contains it, you will still have to ask for it at runtime.

#### Disabling the service

> [!WARNING]
> This is **not recommended**. Only do it if your app already has a service process running in
> the background, in which case you can add the `android:foregroundServiceType="mediaPlayback"`
> type to it.

If you want to completely remove the manifest entries, you can do so by adding the following to
your app's `AndroidManifest.xml`

```xml
<application>
    <service
        android:name="io.livevoice.sdk.android.publicApi.service.LiveVoiceMediaService"
        tools:node="remove" />
</application>
```
