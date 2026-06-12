# LiveVoice SDK Sample App — React Native

A React Native sample app showing how to integrate the LiveVoice SDK on React Native 0.80+. See
the [top-level README](../README.md) for the list of demos and how the samples are organized.

> [!NOTE]
> Make sure you have completed the [Set Up Your
> Environment](https://reactnative.dev/docs/set-up-your-environment) guide for React Native
> before running the sample.

## Run the sample

### 1. Install dependencies

```sh
yarn install   # or: npm install
```

For iOS, install the CocoaPods dependencies — needed on first clone and whenever the native SDK
is updated. Install CocoaPods itself once with the Ruby bundler, then install the pods:

```sh
# inside the react-native directory
bundle install
bundle exec pod install --project-directory=ios
```

### 2. Start Metro

```sh
yarn start   # or: npm start
```

### 3. Build and run

With Metro running, in a separate terminal:

```sh
# Android
yarn android   # or: npm run android

# iOS
yarn ios       # or: npm run ios
```

> [!NOTE]
> **iOS signing:** a build for a **physical device** needs your Apple Developer team. The Xcode
> project ships with no team — first create `signing/Signing.local.xcconfig` with yours (see
> [Signing](../README.md#signing) in the top-level README). Simulators don't need it.

You can also build and run directly from Android Studio or Xcode.

### Run on a specific iOS device or simulator

`yarn ios` builds for a default simulator. To run somewhere specific, let the CLI list the
available targets and pick one interactively:

```sh
yarn ios --list-devices
```

Or target one explicitly. Find a target's UDID with:

```sh
xcrun xctrace list devices   # attached physical devices (and booted simulators)
xcrun simctl list devices    # simulators
```

For a **physical device** use `--device`, passing the UDID or the device name. (Passing a
device UDID to `--udid` matches it against simulators only and fails with
`No simulator available with udid …`.)

```sh
# Physical device, Release build
yarn ios --mode="Release" --device="00008101-001855823EFA601E"

# …by device name instead of UDID
yarn ios --device="My iPhone"

# A specific simulator
yarn ios --simulator="iPhone 16 Pro"
```

## Integrating the SDK into your app

### 1. Add the dependency

Install the SDK package from npm:

```sh
# yarn
yarn add livevoice-sdk-react-native

# npm
npm install livevoice-sdk-react-native
```

### 2. Initialize the SDK

Initialize the SDK once, e.g. at module load before your app renders. On Android this also
configures the foreground service used while audio is playing (see below); on iOS it is
ignored.

```tsx
import { initialize, serviceEnabledWithMessage } from "livevoice-sdk-react-native";

initialize(serviceEnabledWithMessage("Channel %s is playing!"));
```

### 3. Join an event and show the channels

Join an event once, then render a `LiveVoiceView` to show its channels.

```tsx
import React, { useEffect } from "react";
import { joinEvent, LiveVoiceView } from "livevoice-sdk-react-native";

export function Event() {
  useEffect(() => {
    joinEvent("123456", null, "s09WEG5y3caQ6R2PDaG4i8R1aTooTd");
  }, []);

  return <LiveVoiceView />;
}
```

`LiveVoiceView` handles loading, errors, reconnecting, audio, and branding for you. To observe
subtitles or build a custom channel list, see the demos in this sample.

## React Native-specific configuration

> [!NOTE]
> The SDK requires the React Native New Architecture (TurboModules).

### CocoaPods (iOS)

After adding or updating the dependency, re-run the CocoaPods install from step 1 so the native
module is linked into the iOS project.

### Background audio

`initialize(serviceEnabledWithMessage(...))` configures an Android foreground service so audio
keeps playing while the app is backgrounded or the screen is locked. The service shows a
notification for its duration; on Android 13+ you must request the notification permission at
runtime.

On iOS, enable the **Audio, AirPlay, and Picture in Picture** background mode under
`Signing & Capabilities > Background Modes` in the iOS project to keep audio playing in the
background.

