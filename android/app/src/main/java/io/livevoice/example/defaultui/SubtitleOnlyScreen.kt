package io.livevoice.example.defaultui

import androidx.compose.animation.Crossfade
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.subtitle.SdkSubtitleState
import io.livevoice.example.shared.DemoCardSection
import io.livevoice.example.shared.DemoNotes
import io.livevoice.example.shared.DemoPage
import io.livevoice.example.shared.DemoSubtitleUnavailableHint
import io.livevoice.example.shared.SubtitleControlsCard
import io.livevoice.example.shared.SubtitleFragmentsView

@Composable
fun SubtitleOnlyScreen(paddingValues: PaddingValues) {
    val availableSubtitles by LiveVoice.availableSubtitles.collectAsState()
    val subtitleState by LiveVoice.subtitleState.collectAsState()
    val hasSubtitles = availableSubtitles.isNotEmpty()

    var selectedChannelId by rememberSaveable { mutableStateOf<Long?>(null) }
    LaunchedEffect(subtitleState) {
        val currentSubtitleState = subtitleState
        selectedChannelId = when (currentSubtitleState) {
            is SdkSubtitleState.Specific -> currentSubtitleState.channelId
            is SdkSubtitleState.Automatic -> null
            SdkSubtitleState.Disabled -> selectedChannelId
        }
    }

    DemoPage(
        paddingValues = paddingValues,
        summary = "Display subtitles on their own, without showing any of the event channels."
    ) {
        DemoCardSection(title = "Live sample") {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Subtitle view",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )

                Crossfade(targetState = hasSubtitles, label = "subtitleView") { showFeed ->
                    if (showFeed) {
                        SubtitleFragmentsView(
                            subtitleState = subtitleState,
                            placeholder = "Start subtitles to render fragments in this dedicated view."
                        )
                    } else {
                        DemoSubtitleUnavailableHint()
                    }
                }
            }
        }

        SubtitleControlsCard(
            availableSubtitles = availableSubtitles,
            subtitleState = subtitleState,
            selectedChannelId = selectedChannelId,
            onSelectedChannelIdChange = { selectedChannelId = it }
        )

        DemoCardSection(title = "Implementation notes") {
            DemoNotes(
                listOf(
                    "Your app provides the subtitle view and chooses which subtitle stream to start or stop.",
                    "You can use this without rendering the LiveVoice channel list at all.",
                    "LiveVoice.subtitleState gives you the current subtitle fragments for your custom view."
                )
            )
        }
    }
}
