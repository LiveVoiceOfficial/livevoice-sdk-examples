# LiveVoice SDK Sample App - Android

To launch the sample app, either open the directory in Android Studio, or use
```shell
yarn android
```
to launch the app from the command line.

# Integrating the SDK into your Android app

Specify the LiveVoice Android repository either in your root `build.gradle.kts` file or the project's `settings.gradle.kts` file.

```kotlin
// build.gradle.kts (root)
allprojects {
    repositories {
        maven { url = uri("https://sdks.livevoice.io/android") }
        maven { url = uri("https://jitpack.io") }
    }
}

// or settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        maven { url = uri("https://sdks.livevoice.io/android") }
        maven { url = uri("https://jitpack.io") }
    }
}
```

You can then include the dependency declaration in your app's `build.gradle.kts` file.
The `kotlin-parcelize` plugin also needs to be added manually at the moment (this requirement will be removed in the future).

```kotlin
// build.gradle.kts
plugins {
    id("kotlin-parcelize")
}

implementation("io.livevoice.sdk:android:X.X.X")
```

Before invoking any functionality of the LiveVoice SDK, it needs to be initialized.
The easiest way of doing this is inside an `Application` or `Activity` class:

```kotlin
// Application or Activity class
override fun onCreate() {
    super.onCreate()

	initializeLiveVoice()
}
```

You can also manually pass the `applicationContext` and invoke the static function.

```kotlin
LiveVoice.initializeLivevoice(applicationContext = application)
```

To show the channels of your event, you can join the event using the `Livevoice.joinEvent(...)` method, and display the `LiveVoiceView()` composable.

```kotlin
@Composable
fun App(){
	LaunchedEffect(Unit){
		Livevoice.joinEvent(
			joinCode = "123456",
			password =  null,
			apiKey =  "s09WEG5y3caQ6R2PDaG4i8R1aTooTd"
		)
	}

	LiveVoiceView()
}
```

## Android-specific configuration and features

### Specify the size of views

To ensure that e.g. the `LiveVoiceView` does not exceed a certain height, you can specify the max size by passing a `modifier` to the view.

Make sure to also make it `scrollable` if you do that by using the `verticalScroll(..)` modifier.

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

The SDK includes a `android-X.X.X-sources.jar` file, which includes documentation and source-code for public-facing APIs of the LiveVoice SDK, available in your IDE.

While this _should_ automatically be downloaded on project sync, gradle sometimes doesn't resolve the source archive which leads to missing documentation/autocomplete.

When using IntelliJ/Android Studio, use and configure the `idea` plugin to almost always solve this.

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

Alternatively, `File > Invalidate caches > Invalidate and Restart` usually solves the issue as well.

### Background Audio Support

As the Android OS limits resources for apps as soon as the screen is turned off or they are in the
background, we support launching a [ForegroundService](https://developer.android.com/develop/background-work/services/fgs) whenever a channel is being played, which prevents the OS from cutting the audio of a playing channel.

Running this foreground-service requires showing a notification (with a configurable message) while a channel is being played, which will also re-open the app when clicked.

Steps:

1. Enable via optional parameter to `initializeLiveVoice(..)` function

```kotlin
initializeLiveVoice(
	foregroundServiceConfig = ForegroundServiceConfig.enabledWithDefaultMessage
)
```

2. Add the necessary permissions and register the service class

 ```xml
<!--AndroidManifest.xml-->
<manifest>
    <!--  Mandatory, when using the service  -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
	<!--  Necessary for android SDK 34 and above.  -->
    <uses-permission android:minSdkVersion="34"
        android:name="android.permission.POST_NOTIFICATIONS" />


 <application>
        <activity .../>
        <service android:foregroundServiceType="mediaPlayback" android:name="io.livevoice.sdk.android.publicApi.service.LiveVoiceMediaService" />
    </application>
</manifest>
 ```

> [!NOTE]  
> For devices on Android API 34 and above, you need to explicitly specify the
> "POST_NOTIFICATIONS" permission in your manifest, and ask for it at runtime, 
> otherwise the notification will not be displayed!
