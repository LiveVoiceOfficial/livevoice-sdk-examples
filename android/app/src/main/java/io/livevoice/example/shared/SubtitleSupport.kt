package io.livevoice.example.shared

import io.livevoice.sdk.android.publicApi.core.model.subtitle.AvailableSubtitle

enum class DefaultFilterMode(val title: String) {
    All("All"),
    HasSubtitles("Has subtitles"),
    NoMatchingChannels("No match"),
}

data class SourceOption(
    val id: Long,
    val name: String,
)

data class SubtitleGroup(
    val title: String?,
    val items: List<AvailableSubtitle>,
)

fun mapSubtitleGroups(subtitles: Set<AvailableSubtitle>): List<SubtitleGroup> {
    if (subtitles.isEmpty()) return emptyList()

    val grouped = subtitles.groupBy { subtitle ->
        when (subtitle) {
            is AvailableSubtitle.Transcript -> subtitle.channelId to null
            is AvailableSubtitle.Translated -> subtitle.parentChannelId to subtitle.name
        }
    }

    return grouped.entries
        .sortedBy { (groupKey, _) -> groupKey.first }
        .map { (groupKey, values) ->
            SubtitleGroup(
                title = values
                    .firstOrNull { it is AvailableSubtitle.Transcript }
                    ?.name
                    ?: groupKey.second,
                items = values.sortedBy { it.language ?: "" }
            )
        }
}
