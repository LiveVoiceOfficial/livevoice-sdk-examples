package io.livevoice.example.defaultui

import androidx.compose.animation.Crossfade
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.subtitle.SdkSubtitleState
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import io.livevoice.example.shared.AudioOutputRow
import io.livevoice.example.shared.DemoCardSection
import io.livevoice.example.shared.DemoNotes
import io.livevoice.example.shared.DemoPage
import io.livevoice.example.shared.DemoSubtitleUnavailableHint
import io.livevoice.example.shared.SubtitleFragmentsView

@Composable
fun DefaultParticipantInterfaceScreen(paddingValues: PaddingValues) {
    val availableSubtitles by LiveVoice.availableSubtitles.collectAsState()
    val subtitleState by LiveVoice.subtitleState.collectAsState()
    val hasSubtitles = availableSubtitles.isNotEmpty()

    DemoPage(
        paddingValues = paddingValues,
        summary = "The simplest LiveVoice integration. The default view manages channels and audio; tap a channel's subtitle button and the fragments stream into your own subtitle view."
    ) {
        DemoCardSection(title = "Live sample") {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                // Keep audio output reachable right above the list, so playback is never silent.
                AudioOutputRow()
                LiveVoiceView(
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }

        DemoCardSection(title = "Your subtitle view") {
            Text(
                text = "Tap a channel's subtitle button above and its subtitles stream into this view, which your app provides.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Crossfade(targetState = hasSubtitles, label = "subtitleView") { showFeed ->
                if (showFeed) {
                    SubtitleFragmentsView(subtitleState = subtitleState)
                } else {
                    DemoSubtitleUnavailableHint()
                }
            }
            OutlinedButton(
                onClick = { LiveVoice.stopSubtitles() },
                enabled = subtitleState !is SdkSubtitleState.Disabled
            ) {
                Text("Stop subtitles")
            }
        }

        DemoCardSection(title = "Implementation notes") {
            DemoNotes(
                listOf(
                    "Join the event once at app startup or before presenting the screen.",
                    "LiveVoiceView handles loading, errors, reconnecting, and branding for you.",
                    "Tapping a channel's subtitle button starts its subtitles; your app provides the view that renders the fragments.",
                    "Automatic subtitle mode follows whichever channel is currently playing."
                )
            )
        }
    }
}
