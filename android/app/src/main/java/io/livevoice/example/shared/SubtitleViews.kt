package io.livevoice.example.shared

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.subtitle.AvailableSubtitle
import io.livevoice.sdk.android.publicApi.core.model.subtitle.SdkSubtitleState
import io.livevoice.sdk.android.publicApi.core.model.subtitle.SdkSubtitleState.Enabled

@Composable
fun SubtitleControlsCard(
    availableSubtitles: Set<AvailableSubtitle>,
    subtitleState: SdkSubtitleState,
    selectedChannelId: Long?,
    onSelectedChannelIdChange: (Long?) -> Unit,
) {
    val selectedLabel = availableSubtitles
        .firstOrNull { it.channelId == selectedChannelId }
        ?.name
        ?: "Automatic"

    DemoCardSection(title = "Controls") {
        Column(
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            DemoPickerField(
                label = "Subtitle source",
                selectedLabel = selectedLabel,
                enabled = availableSubtitles.isNotEmpty(),
                options = listOf(DemoPickerOption<AvailableSubtitle?>(null, "Automatic")) +
                    availableSubtitles
                        .sortedBy { it.name }
                        .map { subtitle -> DemoPickerOption(subtitle, subtitle.name) },
                onOptionSelected = { subtitle ->
                    val nextChannelId = subtitle?.channelId
                    onSelectedChannelIdChange(nextChannelId)
                    if (subtitleState !is SdkSubtitleState.Disabled) {
                        LiveVoice.startSubtitles(nextChannelId)
                    }
                }
            )

            Button(
                onClick = {
                    if (subtitleState is SdkSubtitleState.Disabled) {
                        LiveVoice.startSubtitles(selectedChannelId)
                    } else {
                        LiveVoice.stopSubtitles()
                    }
                },
                enabled = availableSubtitles.isNotEmpty()
            ) {
                Text(
                    text = if (subtitleState is SdkSubtitleState.Disabled) {
                        "Start subtitles"
                    } else {
                        "Stop subtitles"
                    }
                )
            }
        }
    }
}

@Composable
fun SubtitleFragmentsView(
    subtitleState: SdkSubtitleState,
    placeholder: String = "Start subtitles to render incoming fragments in your own view.",
) {
    if (subtitleState is Enabled) {
        val fragments by subtitleState.fragments.collectAsState()
        if (fragments.isEmpty()) {
            SubtitlePlaceholder(text = "Waiting for subtitle fragments…")
        } else {
            val listState = rememberLazyListState()
            LaunchedEffect(fragments.size) {
                listState.scrollToItem(fragments.lastIndex)
            }
            LazyColumn(
                state = listState,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(220.dp)
                    .padding(4.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(fragments) { fragment ->
                    Text(
                        text = fragment,
                        style = MaterialTheme.typography.bodyLarge
                    )
                }
            }
        }
    } else {
        SubtitlePlaceholder(text = placeholder)
    }
}

@Composable
private fun SubtitlePlaceholder(text: String) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 120.dp)
            .padding(4.dp)
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
