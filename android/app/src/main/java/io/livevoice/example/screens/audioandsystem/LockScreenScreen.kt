// Lock screen and audio sharing
//
// `audioFocus` decides what happens to other audio while a channel plays:
// EXCLUSIVE, the default, pauses it; DUCK_OTHERS lets it play on, quieter.
// While a channel plays, the SDK's foreground service keeps it playing in
// the background and with the screen off, and shows the system's media
// controls on the lock screen, in the notification shade and in quick
// settings; `nowPlayingArtwork` replaces the event's logo there. Best tried
// on a device: play a channel, then lock the phone. The settings are the
// SDK's, so they apply to the whole app, not just this screen.
//
// As on iOS, audio focus is part of initializing (`initializeLiveVoice`), here
// together with the foreground service; neither is a property. A changed
// configuration applies only while no event is joined, so this screen leaves
// the event, initializes again and joins again: playback stops. Your app sets
// them once, in Application.onCreate (see LiveVoiceSetup in
// SampleApplication.kt).
//
// Android differs from iOS here:
// - There is no separate switch for the media controls: they come with the
//   foreground service. Without it (`LiveVoiceForegroundServiceConfig.Disabled`)
//   there are no system media controls, and the system may stop playback
//   once the app is in the background.
// - The media notification needs no notification permission on Android 13
//   and later: notifications of a media session are exempt. The SDK's
//   manifest already declares the foreground service and its permissions.
// - `nowPlayingArtwork` is a Bitmap. The SDK keeps its own copy, so you may
//   recycle yours afterwards.
//
// Uses: initializeLiveVoice(applicationContext, foregroundServiceConfig,
// audioFocus), LiveVoiceAudioFocus, LiveVoiceForegroundServiceConfig,
// leaveEvent(), nowPlayingArtwork
// See also: Audio output.

package io.livevoice.example.screens.audioandsystem

import android.content.Context
import android.graphics.BitmapFactory
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import io.livevoice.example.LiveVoiceSetup
import io.livevoice.example.R
import io.livevoice.example.applicationScope
import io.livevoice.example.demo.DemoButton
import io.livevoice.example.demo.DemoButtonRow
import io.livevoice.example.demo.DemoNote
import io.livevoice.example.demo.DemoNoteKind
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.DemoSegmentedPicker
import io.livevoice.example.demo.DemoSwitchRow
import io.livevoice.example.demo.LocalDemoSession
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceAudioFocus
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceForegroundServiceConfig
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.launch

@Composable
fun LockScreenScreen() {
    val context = LocalContext.current
    val demoSession = LocalDemoSession.current
    // The SDK has no getter for these; the screen starts from the values
    // the app initialized LiveVoice with.
    var audioFocus by remember { mutableStateOf(LiveVoiceSetup.audioFocus) }
    var foregroundService by remember { mutableStateOf(LiveVoiceSetup.foregroundService is LiveVoiceForegroundServiceConfig.Enabled) }
    var isApplying by remember { mutableStateOf(false) }
    var failure by remember { mutableStateOf<LiveVoiceException?>(null) }

    /**
     * Initializes LiveVoice again with the picked settings. It runs in the
     * app's scope: leaving the screen halfway must not leave the app without
     * an event.
     */
    fun applySettings() {
        isApplying = true
        failure = null
        applicationScope.launch {
            try {
                reinitialize(
                    context = context.applicationContext,
                    audioFocus = audioFocus,
                    foregroundService = if (foregroundService) LiveVoiceForegroundServiceConfig.Enabled else LiveVoiceForegroundServiceConfig.Disabled,
                )
            } catch (error: LiveVoiceException) {
                failure = error
                audioFocus = LiveVoiceSetup.audioFocus
                foregroundService = LiveVoiceSetup.foregroundService is LiveVoiceForegroundServiceConfig.Enabled
            } finally {
                // The demo joins the event picked in the toolbar again.
                demoSession.rejoin()
                isApplying = false
            }
        }
    }

    DemoScreen(
        "Lock screen and audio sharing",
        caption = "Share the audio with other apps, and show the playing channel on the lock screen.",
        error = failure,
    ) {
        DemoSection("Other audio") {
            DemoNote(
                "These settings apply to the whole app: every demo screen plays with them, and a playing channel keeps playing when you switch screens.",
                DemoNoteKind.Info,
            )
            DemoNote(
                "On Android, LiveVoice takes these settings when it is initialized: changing one leaves the event and joins it again, which stops playback.",
                DemoNoteKind.Info,
            )
            // HOST_MANAGED requests no audio focus: your app owns it and
            // decides how its own audio and LiveVoice's share the output.
            DemoSegmentedPicker(
                options = listOf(LiveVoiceAudioFocus.EXCLUSIVE to "Pause", LiveVoiceAudioFocus.DUCK_OTHERS to "Duck"),
                selected = audioFocus,
                enabled = !isApplying,
                onSelect = { focus ->
                    audioFocus = focus
                    applySettings()
                },
            )
        }
        DemoSection("Lock screen and notifications") {
            // Turn it off only if your app keeps playback going its own way:
            // the media controls and background playback come together.
            DemoSwitchRow("Media controls and background playback", checked = foregroundService, enabled = !isApplying) {
                foregroundService = it
                applySettings()
            }
            DemoButtonRow {
                // The SDK draws it fitted, with a margin, on a white square.
                DemoButton("App image") {
                    LiveVoice.nowPlayingArtwork = BitmapFactory.decodeResource(context.resources, R.drawable.demo_artwork)
                }
                // `null` shows the event's logo from the dashboard, or none.
                DemoButton("Event logo") { LiveVoice.nowPlayingArtwork = null }
            }
        }
        DemoSection("Channels") {
            LiveVoiceView()
        }
    }
}

/**
 * A changed configuration applies only while no event is joined: leave,
 * initialize with the new values, then join again. Initializing with a
 * changed configuration while joined throws `INVALID_ARGUMENT`.
 */
private suspend fun reinitialize(
    context: Context,
    audioFocus: LiveVoiceAudioFocus,
    foregroundService: LiveVoiceForegroundServiceConfig,
) {
    LiveVoice.leaveEvent()
    LiveVoiceSetup.initialize(context, audioFocus = audioFocus, foregroundService = foregroundService)
}
