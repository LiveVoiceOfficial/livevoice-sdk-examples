// Audio output
//
// `audioOutput` is a preference, not the current route: SYSTEM, the
// default, lets the system choose: connected headphones, wired or
// Bluetooth, and otherwise the earpiece; SPEAKER prefers the loudspeaker.
// Set it any time, also before initializing or joining; setting it never
// fails. The setting is the SDK's, so it applies to the whole app, not just
// this screen.
//
// On Android `audioOutput` is a StateFlow you collect, and you change it
// with the suspend function `setAudioOutput`. Note that SYSTEM on a phone
// without headphones plays through the earpiece, quietly, not the speaker.
//
// Uses: LiveVoice.audioOutput, setAudioOutput(output), LiveVoiceAudioOutput
// See also: Lock screen and audio sharing (how LiveVoice shares the output
// with other apps).

package io.livevoice.example.screens.audioandsystem

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import io.livevoice.example.demo.DemoNote
import io.livevoice.example.demo.DemoNoteKind
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.DemoSegmentedPicker
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceAudioOutput
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.launch

@Composable
fun AudioOutputScreen() {
    val audioOutput by LiveVoice.audioOutput.collectAsState()
    val scope = rememberCoroutineScope()

    DemoScreen("Audio output", caption = "Prefer the loudspeaker, or let the system choose.") {
        DemoSection("Output") {
            DemoNote(
                "These settings apply to the whole app: every demo screen plays with them, and a playing channel keeps playing when you switch screens.",
                DemoNoteKind.Info,
            )
            DemoSegmentedPicker(
                options = listOf(LiveVoiceAudioOutput.SYSTEM to "System", LiveVoiceAudioOutput.SPEAKER to "Speaker"),
                selected = audioOutput,
                onSelect = { output -> scope.launch { LiveVoice.setAudioOutput(output) } },
            )
        }
        DemoSection("Channels") {
            LiveVoiceView()
        }
    }
}
