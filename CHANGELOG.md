# Changelog LiveVoice SDK

Platforms: [iOS](#ios) | [Android](#android) | [React Native](#react-native) | [Flutter](#flutter)

## iOS

### 3.0.0 - November 24, 2026

- `joinEvent` returns once the event is ready and returns the joined event; its `leave()` and
  `leaveEvent()` are awaited and finish when the event is left
- One error type with stable codes, and an observable connection state with `reconnect()`
- Playback starts only from a channel cell or the system media controls; there is no start by
  channel id
- Passwords: built-in prompt, your own provider, and a store
- Custom view parts: loading, reconnecting, error, empty
- Audio focus modes and your own artwork in the system media controls
- Breaking: see the [migration guide](ios/MIGRATION.md)

### 2.0.2 - June 26, 2026

- Bugfixes

### 2.0.0 - June 3, 2026

- Updated for LiveVoice 5.0 model changes and UI
- Get derived AI channels per channel

### 1.0.1 - May 13, 2025

- Bugfixes and optimizations

### 1.0.0 - May 1, 2025

- Initial release

## Android

### 3.0.0 - November 24, 2026

- `joinEvent` returns once the event is ready and returns the joined event; its `leave()` and
  `leaveEvent()` are awaited and finish when the event is left
- One error type with stable codes, and an observable connection state with `reconnect()`
- Playback starts only from a channel cell or the system media controls; there is no start by
  channel id
- Passwords: built-in prompt, your own provider, and a store
- Custom view parts: loading, reconnecting, error, empty
- Audio focus modes and your own artwork in the system media controls
- Breaking: see the [migration guide](android/MIGRATION.md)

### 2.0.2 - June 26, 2026

- Bugfixes

### 2.0.0 - June 3, 2026

- Updated for LiveVoice 5.0 model changes and UI
- Get derived AI channels per channel

### 1.0.1 - May 13, 2025

- Bugfixes and optimizations

### 1.0.0 - May 1, 2025

- Initial release

## React Native

### 3.0.0 - November 25, 2026

- `joinEvent` returns once the event is ready and returns the joined event; its `leave()` and
  `leaveEvent()` are awaited and finish when the event is left
- One error type with stable codes, and an observable connection state with `reconnect()`
- Playback starts only from a channel cell or the system media controls; there is no start by
  channel id
- Passwords: built-in prompt, your own provider, and a store
- Custom view parts: loading, reconnecting, error, empty
- Audio focus modes and your own artwork in the system media controls
- Breaking: see the [migration guide](react-native/MIGRATION.md)

### 2.0.1 - June 27, 2026

- Bugfixes
- Harmonize API with other platforms

### 2.0.0 - June 3, 2026

- Updated for LiveVoice 5.0 model changes and UI
- Get derived AI channels per channel

### 1.0.3 - May 14, 2025

Based on iOS v1.0.1, Android v1.0.1

- Return cleanup function from event emitters

### 1.0.2 - May 13, 2025

Based on iOS v1.0.1, Android v1.0.1

- Bugfixes and optimizations

### 1.0.1 - May 1, 2025

Based on iOS v1.0.0, Android v1.0.0

- Initial release

## Flutter

### 3.0.0 - November 25, 2026

- `joinEvent` returns once the event is ready and returns the joined event; its `leave()` and
  `leaveEvent()` are awaited and finish when the event is left
- One error type with stable codes, and an observable connection state with `reconnect()`
- Playback starts only from a channel cell or the system media controls; there is no start by
  channel id
- Passwords: built-in prompt, your own provider, and a store
- Custom view parts: loading, reconnecting, error, empty
- Audio focus modes and your own artwork in the system media controls
- iOS integrates through Swift Package Manager
- Breaking: see the [migration guide](flutter/MIGRATION.md)

### 2.0.0 - June 27, 2026

- Initial release
