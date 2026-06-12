package io.livevoice.example.defaultui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.subtitle.AvailableSubtitle
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import io.livevoice.example.shared.DefaultFilterMode
import io.livevoice.example.shared.DemoCardSection
import io.livevoice.example.shared.DemoNotes
import io.livevoice.example.shared.DemoPage
import io.livevoice.example.shared.DemoPickerField
import io.livevoice.example.shared.DemoPickerOption
import io.livevoice.example.shared.SourceOption

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilteredChannelListScreen(paddingValues: PaddingValues) {
    var selectedModeName by rememberSaveable { mutableStateOf(DefaultFilterMode.All.name) }
    val selectedMode = DefaultFilterMode.valueOf(selectedModeName)

    val availableSubtitles by LiveVoice.availableSubtitles.collectAsState()
    val sourceOptions = sourceOptions(availableSubtitles)
    var selectedSourceId by rememberSaveable { mutableStateOf<Long?>(null) }
    val featuredChannelIds = featuredChannelIds(selectedSourceId, availableSubtitles)
    LaunchedEffect(sourceOptions) {
        if (selectedSourceId !in sourceOptions.map { it.id }) {
            selectedSourceId = sourceOptions.firstOrNull()?.id
        }
    }

    val predicateDescription = when (selectedMode) {
        DefaultFilterMode.All -> "{ _ -> true }"
        DefaultFilterMode.HasSubtitles -> "{ channel -> channel.hasSubtitles }"
        DefaultFilterMode.NoMatchingChannels -> "{ _ -> false }"
    }

    DemoPage(
        paddingValues = paddingValues,
        summary = "Keep the standard LiveVoice list, but choose which channels appear — " +
            "by any property, the empty state, or a source channel with its AI subtitles."
    ) {
        DemoCardSection(title = "Filter by property") {
            LiveVoiceView(
                filter = { channel ->
                    when (selectedMode) {
                        DefaultFilterMode.All -> true
                        DefaultFilterMode.HasSubtitles -> channel.hasSubtitles
                        DefaultFilterMode.NoMatchingChannels -> false
                    }
                }
            )
        }

        DemoCardSection(title = "Controls") {
            Column(
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                SingleChoiceSegmentedButtonRow(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    DefaultFilterMode.entries.forEachIndexed { index, mode ->
                        SegmentedButton(
                            selected = selectedMode == mode,
                            onClick = { selectedModeName = mode.name },
                            shape = SegmentedButtonDefaults.itemShape(
                                index = index,
                                count = DefaultFilterMode.entries.size
                            ),
                            label = { Text(mode.title) }
                        )
                    }
                }
                Text("Predicate: $predicateDescription")
            }
        }

        DemoCardSection(title = "Source and AI subtitles") {
            if (sourceOptions.isEmpty()) {
                Text(
                    text = "This event has no source channel with derived AI subtitles. " +
                        "The filter keeps the source channel plus any channel whose " +
                        "aiTranslationInfo.sourceChannelId matches it.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            } else {
                Column(
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    LiveVoiceView(
                        filter = { channel ->
                            selectedSourceId == null ||
                                channel.id in featuredChannelIds ||
                                channel.aiTranslationInfo?.sourceChannelId == selectedSourceId
                        }
                    )
                    DemoPickerField(
                        label = "Source channel",
                        selectedLabel = sourceOptions
                            .firstOrNull { it.id == selectedSourceId }
                            ?.name
                            ?: "Choose source channel",
                        options = sourceOptions.map { option ->
                            DemoPickerOption(option.id, option.name)
                        },
                        onOptionSelected = { selectedSourceId = it }
                    )
                }
            }
        }

        DemoCardSection(title = "Implementation notes") {
            DemoNotes(
                listOf(
                    "You provide the filter to the LiveVoiceView.",
                    "You can filter by any channel property and not just hard-coded IDs.",
                    "A predicate that always returns false is useful for checking the no-matching-channels state.",
                    "The source picker is derived from the demo event's available subtitle configuration.",
                    "To feature a source channel, keep it plus any channel whose aiTranslationInfo.sourceChannelId matches."
                )
            )
        }
    }
}

private fun sourceOptions(subtitles: Set<AvailableSubtitle>): List<SourceOption> {
    val namesById = subtitles.associate { it.channelId to it.name }
    val rootIds = subtitles
        .map { subtitle -> subtitle.parentChannelId ?: subtitle.channelId }
        .toSet()

    return rootIds
        .map { id -> SourceOption(id = id, name = namesById[id] ?: "Channel $id") }
        .sortedWith(compareBy(String.CASE_INSENSITIVE_ORDER) { it.name })
}

private fun featuredChannelIds(
    selectedSourceId: Long?,
    subtitles: Set<AvailableSubtitle>,
): Set<Long> {
    if (selectedSourceId == null) return emptySet()
    return subtitles
        .filter { subtitle ->
            subtitle.channelId == selectedSourceId ||
                subtitle.parentChannelId == selectedSourceId
        }
        .map { it.channelId }
        .toSet() + selectedSourceId
}
