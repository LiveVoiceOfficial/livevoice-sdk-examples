# LiveVoiceSDK - React Native

## Getting Started

Add the npm package to your project:

Yarn:
```sh
yarn install livevoice-sdk-react-native
```
Npm:
```sh
npm add livevoice-sdk-react-native
npm install
```

In your TypeScript code, call
```typescript
import {initialize, joinEvent, LiveVoiceView} from 'livevoice-sdk-react-native';

initialize()
joinEvent('123456', null, 's09WEG5y3caQ6R2PDaG4i8R1aTooTd');

// Within the desired component place the view
<View>
  <LiveVoiceView>
</View>
```

## Background Audio Support

Both Android and iOS need configuration to support running audio in the background.

### iOS

To allow your app to continue playing audio in the background, you need to add a background mode to your app's capabilities.

Click the project in Xcode's project navigator and select your target. In the `Signing and Capabilities` tab, add the `Background Modes` Capability (if it isn't already present) and check the `Voice over IP` box. This will add the proper key to your app's Info.plist file.

### Android

We provide builtin support for launching a [ForegroundService](https://developer.android.com/develop/background-work/services/fgs) whenever a channel is being played, which prevents the OS from cutting off the audio of a playing channel.

Running this foreground-service requires showing a notification (with a configurable message) while a channel is being played, which will re-open the app when tapped.

We highly recommend either enabling this, or implementing a similar solution on your own.

Steps:

1. Enable via optional parameter to `initialize(..)` function

```typescript
import {initialize, serviceEnabledWithDefaultMessage} from 'livevoice-sdk-react-native';

// Use the default notification message
initialize(serviceEnabledWithDefaultMessage);

// Use a custom notification message
initialize(serviceEnabledWithMessage("Channel %s is playing"));
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

3. Ask for the notification runtime-permission on Android SDK 34 and above

  Choose your preferred npm dependency to achieve this
