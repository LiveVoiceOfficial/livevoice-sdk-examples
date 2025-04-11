package io.livevoice.sdk_testapp.sampleViews

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceOutput
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceOutput.*
import io.livevoice.sdk.android.publicApi.views.AudioSwitchDisplay
import io.livevoice.sdk_testapp.R

val AudioSwitchSample: AudioSwitchDisplay = { currentOutput, onAudioOutputChanged ->
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Center
    ) {
        val shape = RoundedCornerShape(50)
        Surface(
            modifier = Modifier
                .padding(start = 12.dp, end = 12.dp, top = 8.dp, bottom = 8.dp)
                .clickable {
                    onAudioOutputChanged(HEADPHONES)
                }
                .border(1.5.dp, Color.White, shape)
                .clip(shape)
                .background(if (currentOutput == HEADPHONES) Color.White else Color.Transparent)
                .padding(start = 24.dp, end = 24.dp)
                .size(48.dp),
            shape = shape,
            color = Color.Transparent
        ) {
            Icon(
                modifier = Modifier.padding(4.dp),
                painter = painterResource(R.drawable.ic_output_headset_bluetooth),
                contentDescription = null,
                tint = if (currentOutput == HEADPHONES) Color.Black else Color.White
            )
        }

        Surface(
            modifier = Modifier
                .padding(start = 12.dp, end = 12.dp, top = 8.dp, bottom = 8.dp)
                .clickable {
                    onAudioOutputChanged(SPEAKER)
                }
                .border(1.5.dp, Color.White, shape)
                .clip(shape)
                .background(if (currentOutput == SPEAKER) Color.White else Color.Transparent)
                .padding(start = 24.dp, end = 24.dp)
                .size(48.dp),
            color = Color.Transparent
        ) {
            Icon(
                modifier = Modifier.padding(12.dp),
                painter = painterResource(R.drawable.ic_output_speaker),
                contentDescription = null,
                tint = if (currentOutput == SPEAKER) Color.Black else Color.White
            )
        }
    }
}

@Preview
@Composable
private fun AudioSamplePreview() {
    Box(modifier = Modifier.background(Color.Black)) {
        AudioSwitchSample(HEADPHONES, {})
    }
}

@Preview
@Composable
private fun AudioSamplePreviewLoud() {
    Box(modifier = Modifier.background(Color.Black)) {
        AudioSwitchSample(SPEAKER, {})
    }
}
