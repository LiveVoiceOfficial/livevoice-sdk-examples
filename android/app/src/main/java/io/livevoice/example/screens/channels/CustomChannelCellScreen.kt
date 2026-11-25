// Custom channel cell
//
// `channelCell` draws each channel with your own view. The cell gets a
// LiveVoiceChannelCell: the channel, whether it is the last one, whether its
// action may be used now (`isEnabled`), and the action, `togglePlayback()`.
// The SDK keeps the session, playback and reconnection. Both cells read
// out with the SDK's accessibility texts (`LiveVoice.translations.accessibility…()`).
//
// On Android the cell's `channel` is a value, as it was when the cell was
// drawn: LiveVoiceView draws the cell again when the channel changes, so
// there is nothing to observe. `togglePlayback()` is a suspend function;
// await it and show its error, since the SDK reports a custom cell's
// failure nowhere else. Leaving the cell's composition cancels the call.
//
// Needs: an API key that permits custom UI.
// Uses: LiveVoiceView(channelCell), LiveVoiceChannelCell, LiveVoiceChannel,
// LiveVoice.translations
// See also: Custom view states, Localization and accessibility (the SDK's texts
// for your cells).

package io.livevoice.example.screens.channels

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.unit.dp
import io.livevoice.example.demo.DemoNeed
import io.livevoice.example.demo.DemoRequirement
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.DemoTag
import io.livevoice.example.demo.demoCardColor
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException
import io.livevoice.sdk.android.publicApi.core.model.channel.LiveVoiceChannel
import io.livevoice.sdk.android.publicApi.core.model.channel.LiveVoicePlayingState
import io.livevoice.sdk.android.publicApi.views.LiveVoiceChannelCell
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.launch

@Composable
fun CustomChannelCellScreen() {
    val customUiAllowed by LiveVoice.customUiAllowed.collectAsState()

    DemoScreen("Custom channel cell", caption = "Draw each channel with your own view.") {
        DemoRequirement(DemoNeed.CustomUi, isMet = customUiAllowed)
        DemoSection("Simple cell") {
            LiveVoiceView(channelCell = { cell -> ChannelCell(cell) })
        }
        DemoSection("Detailed cell") {
            LiveVoiceView(channelCell = { cell -> DetailedChannelCell(cell) })
        }
    }
}

/**
 * A channel row of your own: the name, a status line and a play button.
 * Cells are laid out flush to the view's edges, so the cell sets its own
 * padding and divider.
 */
@Composable
private fun ChannelCell(cell: LiveVoiceChannelCell) {
    val channel = cell.channel
    val scope = rememberCoroutineScope()
    var failure by remember(channel.id) { mutableStateOf<LiveVoiceException?>(null) }

    Column {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                // `isEnabled` is `false` while the channel is offline, has no
                // audio, or the connection recovers: draw the cell as
                // unavailable then. The click label is the SDK's localized
                // text for the cell's action.
                .clickable(enabled = cell.isEnabled, role = Role.Button, onClickLabel = actionLabel(channel)) {
                    scope.launch {
                        failure = null
                        failure = togglePlayback(cell)
                    }
                }
                // What TalkBack reads after the name: a failed tap's message,
                // as shown, or the playing state.
                .semantics { stateDescription = failure?.message ?: playingStatus(channel) }
                .padding(vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(channel.name, style = MaterialTheme.typography.titleMedium)
                Text(
                    text = failure?.message ?: status(channel),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.clearAndSetSemantics {},
                )
            }
            PlaybackIcon(channel.playingState, tint = MaterialTheme.colorScheme.primary)
        }
        if (!cell.isLast) {
            HorizontalDivider()
        }
    }
}

private fun status(channel: LiveVoiceChannel): String {
    if (!channel.isOnline) return "Offline"
    // The SDK plays no video: a channel with video and audio plays its
    // audio, one with only video cannot be played (`hasAudio` is false).
    if (!channel.hasAudio) return if (channel.hasVideo) "Video only" else "No audio"
    channel.aiTranslationInfo?.let { return "AI translation, ${it.targetLanguage}" }
    return if (channel.hasSubtitles) "With subtitles" else "Ready"
}

private fun playingStatus(channel: LiveVoiceChannel): String {
    val playing = when (channel.playingState) {
        LiveVoicePlayingState.PLAYING -> "Playing"
        LiveVoicePlayingState.TRANSITIONING -> "Connecting"
        LiveVoicePlayingState.STOPPED -> "Stopped"
        else -> ""
    }
    return if (channel.isOnline) playing else "Offline, $playing"
}

/**
 * A richer row that shows what you can read from `LiveVoiceChannel`: the
 * online dot, every Boolean as a tag (faint when false, so all of them stay
 * visible even where a feature doesn't apply), the AI translation, the
 * channels that translate this one, and the playing state. Each channel is
 * a card of its own.
 */
@Composable
private fun DetailedChannelCell(cell: LiveVoiceChannelCell) {
    val channel = cell.channel
    val scope = rememberCoroutineScope()
    var failure by remember(channel.id) { mutableStateOf<LiveVoiceException?>(null) }
    val accent = MaterialTheme.colorScheme.primary
    val inactive = MaterialTheme.colorScheme.onSurfaceVariant

    Row(
        modifier = Modifier
            .padding(bottom = if (cell.isLast) 0.dp else 12.dp)
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(demoCardColor())
            // `isEnabled` is `false` while the channel is offline, has no
            // audio, or the connection recovers: the cell looks and acts
            // unavailable then.
            .clickable(enabled = cell.isEnabled, role = Role.Button, onClickLabel = actionLabel(channel)) {
                scope.launch {
                    failure = null
                    failure = togglePlayback(cell)
                }
            }
            // TalkBack reads the name, then this: the faint tags aren't read out.
            .semantics { stateDescription = accessibilityValue(channel, failure) }
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Box(
            modifier = Modifier
                .padding(top = 6.dp)
                .size(10.dp)
                .background(if (channel.isOnline) Color(0xFF34C759) else inactive, CircleShape),
        )
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text(channel.name, style = MaterialTheme.typography.titleMedium)
            Column(modifier = Modifier.clearAndSetSemantics {}, verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(
                    text = failure?.message ?: detailedStatus(channel),
                    style = MaterialTheme.typography.bodySmall,
                    color = if (failure == null) inactive else MaterialTheme.colorScheme.error,
                )
                FlowRow(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    DemoTag("Audio", isOn = channel.hasAudio)
                    // The SDK plays no video; of a channel with both it plays the audio.
                    DemoTag("Video", isOn = channel.hasVideo)
                    DemoTag("Subtitles", isOn = channel.hasSubtitles)
                    DemoTag("Muted", isOn = channel.isAudioMuted)
                    DemoTag("Password", isOn = channel.isPasswordProtected)
                    DemoTag("AI voice", isOn = channel.isAiSpeaker)
                    DemoTag("On demand", isOn = channel.isOnDemand)
                }
                if (channel.dependentChannels.isNotEmpty()) {
                    // Channels that translate this one, such as an AI voice.
                    Text(
                        text = "Translations: " + channel.dependentChannels.joinToString { it.name },
                        style = MaterialTheme.typography.bodySmall,
                        color = inactive,
                    )
                }
            }
        }
        Box(
            modifier = Modifier
                .size(40.dp)
                .background(accent.copy(alpha = if (cell.isEnabled) 0.12f else 0.05f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            PlaybackIcon(channel.playingState, tint = if (cell.isEnabled) accent else inactive)
        }
    }
}

private fun detailedStatus(channel: LiveVoiceChannel): String {
    if (!channel.isOnline) return "Inactive"
    channel.aiTranslationInfo?.let { return "AI translation into ${it.targetLanguage}" }
    return when (channel.playingState) {
        LiveVoicePlayingState.PLAYING -> "Currently playing"
        LiveVoicePlayingState.TRANSITIONING -> "Connecting…"
        LiveVoicePlayingState.STOPPED -> if (channel.hasAudio) "Ready to start" else "Nothing to play"
        else -> ""
    }
}

/**
 * The status line and only the properties that are true, the way the
 * tags show them at full contrast.
 */
private fun accessibilityValue(channel: LiveVoiceChannel, failure: LiveVoiceException?): String {
    val properties = listOf(
        channel.hasAudio to "Audio",
        channel.hasVideo to "Video",
        channel.hasSubtitles to "Subtitles",
        // The SDK's localized text for a muted channel.
        channel.isAudioMuted to LiveVoice.translations.accessibilityChannelStatusMuted(),
        channel.isPasswordProtected to "Password",
        channel.isAiSpeaker to "AI voice",
        channel.isOnDemand to "On demand",
    )
    val line = failure?.message ?: detailedStatus(channel)
    return (listOf(line) + properties.filter { it.first }.map { it.second }).joinToString(", ")
}

/** The SDK's localized text for the cell's action. */
private fun actionLabel(channel: LiveVoiceChannel): String = when (channel.playingState) {
    LiveVoicePlayingState.PLAYING, LiveVoicePlayingState.TRANSITIONING -> LiveVoice.translations.accessibilityChannelStop()
    LiveVoicePlayingState.STOPPED -> LiveVoice.translations.accessibilityChannelPlay()
    else -> LiveVoice.translations.accessibilityChannelPlay()
}

/**
 * Starts the channel if it is stopped and stops it if it plays, decided
 * when it runs. Returns once the channel plays or has stopped, with the
 * error to show if it failed.
 */
private suspend fun togglePlayback(cell: LiveVoiceChannelCell): LiveVoiceException? = try {
    cell.togglePlayback()
    null
} catch (error: LiveVoiceException) {
    error
}

/** Play, connecting or stop, for a channel's `playingState`. */
@Composable
private fun PlaybackIcon(state: LiveVoicePlayingState, tint: Color) {
    when (state) {
        LiveVoicePlayingState.STOPPED -> Icon(Icons.Filled.PlayArrow, contentDescription = null, tint = tint)
        LiveVoicePlayingState.TRANSITIONING -> CircularProgressIndicator(modifier = Modifier.size(20.dp), color = tint, strokeWidth = 2.dp)
        LiveVoicePlayingState.PLAYING -> Box(Modifier.size(14.dp).background(tint, RoundedCornerShape(2.dp)))
        else -> Icon(Icons.Filled.PlayArrow, contentDescription = null, tint = tint)
    }
}
