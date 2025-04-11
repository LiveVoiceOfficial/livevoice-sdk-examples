package io.livevoice.sdk_testapp

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import io.livevoice.sdk_testapp.sampleViews.AudioSwitchSample
import io.livevoice.sdk_testapp.sampleViews.ChannelDisplaySample
import io.livevoice.sdk_testapp.sampleViews.ErrorDisplaySample
import io.livevoice.sdk_testapp.sampleViews.LoadingDisplaySample

@Composable
fun CustomDesignSample(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color(0xFF181C34))
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        SampleSpacer()
        SampleText("LiveVoice SDK, but completely custom UI", color = Color.White)
        LiveVoiceView(
            showAudioSwitch = true,
            audioSwitchDisplay = AudioSwitchSample,
            channelDisplay = ChannelDisplaySample,
            errorDisplay = ErrorDisplaySample,
            loadingDisplay = LoadingDisplaySample
        )
        SampleSpacer()
    }
}
