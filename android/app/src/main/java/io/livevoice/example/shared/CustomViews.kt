package io.livevoice.example.shared

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedCard
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.SdkRetryState
import io.livevoice.sdk.android.publicApi.core.model.SdkUiState
import io.livevoice.sdk.android.publicApi.core.model.channel.LiveVoiceChannel
import io.livevoice.sdk.android.publicApi.core.model.channel.LiveVoicePlayingState
import io.livevoice.sdk.android.publicApi.views.ChannelCellDisplay
import io.livevoice.sdk.android.publicApi.views.ErrorDisplay
import io.livevoice.sdk.android.publicApi.views.LoadingDisplay
import kotlinx.coroutines.delay
import kotlin.time.Duration.Companion.seconds

val BasicCustomChannelRow: ChannelCellDisplay = { channel, isLastInList, onAudioClick ->
    val accent = Color(0xFF007AFF)
    Card(
        onClick = onAudioClick,
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = if (isLastInList) 0.dp else 12.dp)
            .seanticsForChannel(channel),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (isSystemInDarkTheme()) Color(0xFF212429) else Color.White
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    text = channel.name,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = channelStatusText(channel),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Box(
                modifier = Modifier
                    .size(40.dp)
                    .background(
                        color = accent.copy(alpha = 0.12f),
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = if (channel.playingState == LiveVoicePlayingState.Playing) {
                        Icons.Filled.Close
                    } else {
                        Icons.Filled.PlayArrow
                    },
                    contentDescription = null,
                    tint = accent
                )
            }
        }
    }
}

/**
 * A richer custom channel row that surfaces the channel's Booleans — isOnline as the status dot,
 * the rest as badges (solid when true, faint when false) — so you can see which values you can read
 * even when a feature doesn't apply to your own design. The row is tappable, and its play control
 * active, only when the channel can be started (online and with audio).
 */
val DetailedCustomChannelRow: ChannelCellDisplay = { channel, isLastInList, onAudioClick ->
    val accent = Color(0xFF007AFF)
    val online = Color(0xFF34C759)
    val offline = Color(0xFF8E8E93)
    // The channel can be started only when it is online and has audio.
    val canPlay = channel.isOnline && channel.hasAudio
    val cardBg = if (isSystemInDarkTheme()) Color(0xFF212429) else Color.White
    Card(
        onClick = onAudioClick,
        enabled = canPlay,
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = if (isLastInList) 0.dp else 12.dp)
            .seanticsForChannel(channel),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = cardBg,
            disabledContainerColor = cardBg
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.Top
        ) {
            Box(
                modifier = Modifier
                    .padding(top = 5.dp)
                    .size(10.dp)
                    .background(
                        color = if (channel.isOnline) online else offline,
                        shape = CircleShape
                    )
            )

            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Text(
                    text = channel.name,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = channelStatusText(channel),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                // isOnline is already conveyed by the status dot + status line above, so it's not
                // repeated as a badge here.
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    BooleanBadge(label = "Audio", isOn = channel.hasAudio)
                    BooleanBadge(label = "Subtitles", isOn = channel.hasSubtitles)
                    BooleanBadge(label = "Muted", isOn = channel.isAudioMuted)
                }
            }

            val playColor = if (canPlay) accent else offline
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .alpha(if (canPlay) 1f else 0.4f)
                    .background(
                        color = playColor.copy(alpha = 0.12f),
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = if (channel.playingState == LiveVoicePlayingState.Playing) {
                        Icons.Filled.Close
                    } else {
                        Icons.Filled.PlayArrow
                    },
                    contentDescription = null,
                    tint = playColor
                )
            }
        }
    }
}

/**
 * A pill for one Boolean property: full-contrast (onSurface) when true, faint when false, so every
 * readable value stays visible even when the feature doesn't apply.
 */
@Composable
private fun BooleanBadge(label: String, isOn: Boolean) {
    val color = MaterialTheme.colorScheme.onSurface
    Text(
        text = label,
        style = MaterialTheme.typography.labelSmall,
        color = color.copy(alpha = if (isOn) 1f else 0.3f),
        maxLines = 1,
        modifier = Modifier
            .border(
                width = 0.5.dp,
                color = color.copy(alpha = if (isOn) 0.85f else 0.16f),
                shape = CircleShape
            )
            .padding(horizontal = 8.dp, vertical = 2.dp)
    )
}

private fun Modifier.seanticsForChannel(channel: LiveVoiceChannel): Modifier =
    semantics {
        stateDescription = if (channel.playingState == LiveVoicePlayingState.Playing) {
            LiveVoice.translations.accessibilityChannelStop()
        } else {
            LiveVoice.translations.accessibilityChannelPlay()
        }
    }

val CustomLoadingCard: LoadingDisplay = {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 120.dp),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator()
    }
}

val CustomErrorCard: ErrorDisplay = { error ->
    OutlinedCard(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = when (error) {
                    is SdkUiState.Error -> error.message
                    is SdkUiState.Reconnecting -> reconnectMessage(error.retryState)
                },
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Medium
            )

            val retry = when (error) {
                is SdkUiState.Error -> error.onRetry
                is SdkUiState.Reconnecting -> error.onRetry
            }

            if (retry != null) {
                Button(onClick = retry) {
                    Text(LiveVoice.translations.errorRetryNowButton())
                }
            }
        }
    }
}

private fun reconnectMessage(retryState: SdkRetryState): String {
    return when (retryState) {
        is SdkRetryState.AwaitingNextReconnectAttempt -> {
            LiveVoice.translations.errorScreenRetryingIn(retryState.getSecondsUntilRetry())
        }
        SdkRetryState.RetryInProgress -> LiveVoice.translations.errorScreenRetrying()
    }
}

@Composable
fun ReconnectCard(retryState: SdkRetryState, onRetry: (() -> Unit)? = null) {
    val message by produceState(initialValue = reconnectMessage(retryState), retryState) {
        value = reconnectMessage(retryState)
        while (retryState is SdkRetryState.AwaitingNextReconnectAttempt) {
            delay(1.seconds)
            value = reconnectMessage(retryState)
        }
    }

    OutlinedCard(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = message,
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Medium
            )

            if (onRetry != null) {
                Button(onClick = onRetry) {
                    Text(LiveVoice.translations.errorRetryNowButton())
                }
            }
        }
    }
}

private fun channelStatusText(channel: LiveVoiceChannel): String {
    if (!channel.isOnline) {
        return LiveVoice.translations.channelStatusOffline()
    }
    val aiTranslationInfo = channel.aiTranslationInfo
    if (aiTranslationInfo != null) {
        return "AI ${aiTranslationInfo.targetLanguage}"
    }
    if (channel.playingState == LiveVoicePlayingState.Playing) {
        return "Currently playing"
    }
    return "Ready to start"
}
