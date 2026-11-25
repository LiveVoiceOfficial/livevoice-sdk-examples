// Default interface
//
// The smallest integration: LiveVoiceView lists the joined event's channels
// and plays the one a listener taps. It also shows loading, reconnecting,
// errors, an event without channels and the LiveVoice branding by itself.
//
// On Android, call `initializeLiveVoice` once in `Application.onCreate` (see
// SampleApplication.kt) before you join and show the view. LiveVoiceView
// follows the system's dark theme unless you pass `isDarkTheme`, and it also
// shows the SDK's password prompt for protected channels.
//
// Uses: LiveVoiceView
// See also: Joining an event (how the event is joined), Filtering channels,
// Custom channel cell, Subtitles, Audio output.

package io.livevoice.example.screens.gettingstarted

import androidx.compose.runtime.Composable
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView

@Composable
fun DefaultInterfaceScreen() {
    DemoScreen("Default interface", caption = "Tap a channel to listen.") {
        DemoSection("Channels") {
            LiveVoiceView()
        }
    }
}
