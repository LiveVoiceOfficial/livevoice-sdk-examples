# LiveVoice SDK Sample App — React Native

A React Native sample app showing how to integrate the LiveVoice SDK on React Native 0.81+. See
the [top-level README](../README.md) for the list of demos and how the samples are organized.

Coming from SDK 2.x? See the [migration guide](MIGRATION.md).

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

Requires React Native 0.81 or newer with the New Architecture, iOS 15.1 or newer with Xcode 26.5
or newer (Swift 6.3), and Android 7.0 (API 24) or newer.

### 1. Add the dependency

Install the SDK package from npm:

```sh
# yarn
yarn add livevoice-sdk-react-native

# npm
npm install livevoice-sdk-react-native
```

On iOS, install the pods from your app's `ios/` directory. This also fetches the native LiveVoice
SDK as a Swift package; do not add it to your app yourself.

```sh
pod install
```

### 2. Initialize the SDK

Initialize once, before rendering SDK components or calling the SDK; commands called earlier
reject with `not_initialized`.

```tsx
const [ready, setReady] = useState(false);
useEffect(() => {
  initialize().then(
    () => setReady(true),
    (error: LiveVoiceError) => console.warn(error.code),
  );
}, []);
if (!ready) return null;
```

Calling `initialize()` again with the same options changes nothing. Changed options apply only
while no event is joined and reject with `invalid_argument` otherwise.

### 3. Join an event and show the channels

Await the join and keep the joined event it returns:

```tsx
try {
  const joined = await joinEvent({ joinCode: '123456', apiKey: 'YOUR_API_KEY' });
  // Keep `joined` and call `joined.leave()` when you are done with the event.
} catch (error) {
  // (error as LiveVoiceError).code says what went wrong. 'superseded' and 'cancelled' are
  // expected when a newer join or a leave took over.
}
```

Joining again leaves the previous event, so switching events needs only the new join. A screen
that owns its event leaves it with `joined.leave()`, which can never leave a newer join; see
`src/screens/GettingStarted/JoiningEventScreen.tsx`.

`LiveVoiceView` handles loading, errors, reconnecting, audio, and branding for you. To observe
subtitles or build a custom channel list, see the demos in this sample.

### How playback starts

Playback starts only from a channel cell: a listener taps a channel in the view, or your custom
cell calls `togglePlayback()` (a custom cell needs an API key that permits custom UI). There is no
call that starts a channel by its id. The system media controls pause and resume the playing
channel, and `stopChannel()` stops it.

### Passwords

Protected events and channels need no code of yours: a `LiveVoiceView` on screen asks for the
password, and the SDK remembers an accepted one until the app quits. A password you pass to
`joinEvent` is final: a wrong one fails without a prompt. To ask with your own UI
(`setPasswordProvider`) or keep passwords longer (`setPasswordStore`), see the Password-protected
channels screen.

### What an awaited call guarantees

Joining, leaving, switching and reconnecting finish only when their result is final, so the next
line of your code can rely on it:

| Call | Finishes when | What is true then |
|---|---|---|
| `joinEvent(request)` | The event is ready | `connection` is `ready`, and the current event, linked events, requestable languages and available subtitles show the joined event. The channel list, the features and the subtitle state follow shortly: observe them (`useLiveVoiceFeatures()`, `useLiveVoiceSubtitles()`) instead of reading them right after the call |
| `switchToLinkedEvent(event)` | The linked event is ready | The same, for the linked event. The previous event was left when the switch began. Needs an API key that permits custom UI and a ready connection |
| `reconnect()` | A new connection is ready | `connection` is `ready`, or `reconnecting` again if it dropped meanwhile, and the same values show the event. The playing channel and the subtitle choice are restored unless you stopped them; that audio plays again is not promised |
| `joined.leave()` | That join is left | Nothing of that event plays or changes any more, and the same values show it. Once a newer join exists it does nothing |
| `leaveEvent()` | Whatever was joined or joining is left | `connection` is `idle`, and the current event, linked events, requestable languages and available subtitles are `null` |

Each row holds unless your app made a newer call in the meantime. A call that does not get there
rejects with a `LiveVoiceError`:

- `superseded`: a newer join, switch or reconnect replaced it.
- `cancelled`: a leave ended it. Show neither of these two to the listener. An awaited call cannot
  be cancelled by its caller.
- `timed_out`: the event was not ready 30 seconds after the call, not counting the time a password
  is entered. A `reconnect()` that times out on an established connection fails only the call: the
  event stays joined and keeps recovering.
- `leave_incomplete`: cleanup took longer than 5 seconds. The event is left all the same, and the
  next join waits for the cleanup.

Leaving one event and joining another therefore needs no waiting of your own:

```ts
await leaveEvent();
const joined = await joinEvent({ joinCode: next, apiKey: 'YOUR_API_KEY' });
```

A join replaces the current event by itself, also when it then fails: the earlier event is left
and `connection` is `failed`. Only a join refused for an invalid argument leaves the current event
untouched. Leave first only to be sure the earlier event's cleanup has finished before you join. To
move to an event linked to the current one, call `switchToLinkedEvent(event)`: it leaves and joins
in one call.

## React Native-specific configuration

### CocoaPods (iOS)

After adding or updating the dependency, re-run the CocoaPods install from step 1 so the native
module is linked into the iOS project.

### Background audio

`await initialize({ androidServiceConfig: { kind: 'enabled' } })`, the default, configures an
Android foreground service so audio keeps playing while the app is backgrounded or the screen is
locked. The service shows the system's media controls, including a media notification, while a
channel plays or can resume. That notification needs no `POST_NOTIFICATIONS` prompt; other
notifications of your app may still need the permission; see
[Android's media-session exemption](https://developer.android.com/develop/ui/compose/notifications/notification-permission#media-sessions).

On iOS, to keep audio playing in the background, open the iOS project in Xcode, select the app
target, open **Signing & Capabilities**, add **Background Modes** and check **Audio, AirPlay, and
Picture in Picture**.

By default LiveVoice takes the audio exclusively and shows the playing channel in the system
media controls. `initialize({ audioFocus, showsSystemMediaControls })` changes that (`audioFocus`
`'duckOthers'` or `'hostManaged'`; `showsSystemMediaControls` applies on iOS), and
`setNowPlayingArtwork(image)` replaces the event's logo there; see the Lock screen and audio
sharing screen.
