package io.livevoice.sdk_testapp.sampleViews

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.PlayArrow
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.graphics.BlendModeColorFilterCompat
import androidx.core.graphics.BlendModeCompat
import com.airbnb.lottie.LottieProperty
import com.airbnb.lottie.compose.LottieAnimation
import com.airbnb.lottie.compose.LottieCompositionSpec
import com.airbnb.lottie.compose.LottieConstants.IterateForever
import com.airbnb.lottie.compose.animateLottieCompositionAsState
import com.airbnb.lottie.compose.rememberLottieComposition
import com.airbnb.lottie.compose.rememberLottieDynamicProperties
import com.airbnb.lottie.compose.rememberLottieDynamicProperty
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceChannel
import io.livevoice.sdk.android.publicApi.core.model.LiveVoicePlayingState.CONNECTING
import io.livevoice.sdk.android.publicApi.core.model.LiveVoicePlayingState.PLAYING
import io.livevoice.sdk.android.publicApi.core.model.LiveVoicePlayingState.STOPPED
import io.livevoice.sdk.android.publicApi.core.model.LiveVoicePlayingState.STOPPING
import io.livevoice.sdk.android.publicApi.views.ChannelDisplay
import io.livevoice.sdk_testapp.R

val ChannelDisplaySample: ChannelDisplay = { channel, _, onChannelClick -> // draw icon
    val isPlaying = channel.playingState == PLAYING
    val borderTextColor = Color(0xFF084EFF)

    //filter to make lottie-animation in single, configurable color
    val dynamicProperties = rememberLottieDynamicProperties(
        rememberLottieDynamicProperty(
            property = LottieProperty.COLOR_FILTER,
            value = BlendModeColorFilterCompat.createBlendModeColorFilterCompat(
                Color.White.hashCode(), BlendModeCompat.SRC_ATOP
            ),
            keyPath = arrayOf("**")
        )
    )

    val icon: @Composable () -> Unit = {
        when (channel.playingState) {
            STOPPED -> Icon(
                Icons.Outlined.PlayArrow,
                contentDescription = null,
                tint = borderTextColor
            )

            STOPPING, CONNECTING -> {
                Box(Modifier.fillMaxSize()) {
                    CircularProgressIndicator(
                        modifier = Modifier
                            .size(28.dp)
                            .align(Alignment.Center),
                        strokeWidth = 3.dp,
                        color = borderTextColor
                    )
                }
            }

            PLAYING -> {
                val composition by rememberLottieComposition(LottieCompositionSpec.RawRes(R.raw.music))
                val progress by animateLottieCompositionAsState(
                    composition, iterations = IterateForever
                )
                LottieAnimation(
                    composition = composition,
                    progress = { progress },
                    dynamicProperties = dynamicProperties
                )
            }
        }
    }

    Row(
        modifier = Modifier
            .clearAndSetSemantics { }
            .padding(start = 48.dp, end = 48.dp)
            .fillMaxWidth()
            .padding(4.dp)
            .clip(RoundedCornerShape(50))
            .background(if (isPlaying) Color.White else Color.Transparent)
            .clickable(enabled = channel.isOnline) {
                onChannelClick(channel)
            }
            .run {
                if (!isPlaying) border(1.5.dp, borderTextColor, RoundedCornerShape(50))
                else this
            }
            .padding(start = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        val playButtonWidth = 100.dp

        //As text/status is measured before play-button, the max width of the text has to be limited.
        //Otherwise, the play-button might not have enough space to be drawn properly
        BoxWithConstraints {
            Row(
                modifier = Modifier
                    .widthIn(max = maxWidth - playButtonWidth)
                    .fillMaxWidth()
            ) {
                Text(
                    channel.name,
                    modifier = Modifier
                        .alignByBaseline()
                        .padding(end = 16.dp, start = 8.dp),
                    fontWeight = FontWeight.Bold,
                    fontSize = 22.sp,
                    color = borderTextColor
                )

                if (channel.isAudioMuted)
                    Text(
                        "Currently muted",
                        modifier = Modifier.alignByBaseline(),
                        fontStyle = FontStyle.Italic,
                        fontSize = 15.sp,
                        color = borderTextColor,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
            }
        }
        Spacer(modifier = Modifier.weight(1f))

        val buttonColor = when {
            isPlaying -> borderTextColor
            channel.isOnline -> Color.White
            else -> Color.Transparent
        }

        //Play button
        Surface(
            modifier = Modifier
                .padding(8.dp)
                .size(54.dp)
                .clip(RoundedCornerShape(50))
                .background(buttonColor)
                .run {
                    if (!isPlaying && !channel.isOnline) border(
                        1.5.dp, borderTextColor, RoundedCornerShape(50)
                    )
                    else this
                }
                .run {
                    if (!isPlaying) padding(8.dp)
                    else this
                },
            color = buttonColor,
        ) {
            icon()
        }
    }
}

@Preview
@Composable
private fun SampleChannelDisplayPreview() {
    Box(modifier = Modifier.background(Color(0xFF283593))) {
        val channel = LiveVoiceChannel(
            0, "test",
            playingState = STOPPED,
            isOnline = false,
            isAudioMuted = false,
            isAiSpeaker = false
        )
        ChannelDisplaySample(channel, false, {})
    }
}

@Preview
@Composable
private fun LoadingChannelDisplayPreview() {
    Box(modifier = Modifier.background(Color(0xFF283593))) {
        val channel = LiveVoiceChannel(
            1, "test",
            playingState = CONNECTING,
            isOnline = false,
            isAudioMuted = false,
            isAiSpeaker = false
        )
        ChannelDisplaySample(channel, false, {})
    }
}

@Preview
@Composable
private fun PlayingChannelDisplayPreview() {
    Box(modifier = Modifier.background(Color(0xFF283593))) {
        val channel = LiveVoiceChannel(
            1, "test",
            playingState = PLAYING,
            isOnline = false,
            isAudioMuted = false,
            isAiSpeaker = false
        )
        ChannelDisplaySample(channel, false, {})
    }
}

@Preview
@Composable
private fun PlayingChannelMutedDisplayPreview() {
    Box(modifier = Modifier.background(Color(0xFF283593))) {
        val channel = LiveVoiceChannel(
            1, "test",
            playingState = PLAYING,
            isOnline = false,
            isAudioMuted = false,
            isAiSpeaker = false
        )
        ChannelDisplaySample(channel, false, {})
    }
}
