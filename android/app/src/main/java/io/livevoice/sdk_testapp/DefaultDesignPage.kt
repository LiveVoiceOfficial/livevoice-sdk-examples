package io.livevoice.sdk_testapp

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.animateScrollBy
import androidx.compose.foundation.gestures.scrollable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CornerSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.SdkUiState
import io.livevoice.sdk.android.publicApi.core.model.subtitle.AvailableSubtitle
import io.livevoice.sdk.android.publicApi.core.model.subtitle.SdkSubtitleState
import io.livevoice.sdk.android.publicApi.core.model.subtitle.SdkSubtitleState.Disabled
import io.livevoice.sdk.android.publicApi.core.model.subtitle.SdkSubtitleState.Enabled
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.launch

@Composable
fun DefaultDesignScreen(modifier: Modifier = Modifier) {
    val scrollState = rememberScrollState()
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(if (isSystemInDarkTheme()) Color.DarkGray else Color.LightGray)
            .verticalScroll(scrollState),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            SampleText("This is the default Livevoice View")
            LiveVoiceView()
            SampleSpacer()

            SampleText("It is also possible to filter channels")
            LiveVoiceView(
                modifier = Modifier.heightIn(min = 200.dp),
                filter = { it.name == "German" }
            )
            SampleSpacer()

            SampleText("And the OutputSwitch is Optional as well")
            LiveVoiceView(showAudioSwitch = false)
            SampleSpacer()
        }

        val uiState by LiveVoice.uiState.collectAsState()
        val subtitleState by LiveVoice.subtitleState.collectAsState()
        val availableSubtitles by LiveVoice.availableSubtitles.collectAsState()

        if (availableSubtitles.isNotEmpty()) {
            SampleText("Your event has the following Subtitles configured")
            Column(
                modifier = Modifier
                    .padding(12.dp)
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(MaterialTheme.colorScheme.surface)
                    .padding(12.dp),
            ) {

                val grouped = availableSubtitles.groupBy { it.parentChannelId ?: it.channelId }
                for (group in grouped) {
                    val channelsOrNull = (uiState as? SdkUiState.Ready)?.channels
                    val parentChannelname = channelsOrNull?.find { it.id == group.key }?.name
                    val rootChannelName = parentChannelname?.let { "Channel: $it" }
                        ?: "Source channel hidden"

                    SampleText(rootChannelName, style = LocalTextStyle.current.copy(fontWeight = FontWeight.Bold))

                    for (subtitleOption in group.value) {
                        val text = when (subtitleOption) {
                            is AvailableSubtitle.Transcript -> "Original Transcript"
                            is AvailableSubtitle.Translated -> subtitleOption.name
                        }
                        SampleText(text = "\t $text")
                    }
                }
            }

            SubtitleSampleDisplay(subtitleState, availableSubtitles, scrollState)

        } else {
            SampleText(
                modifier = Modifier.padding(12.dp),
                text = "Your event has no subtitles configured!\n" +
                        "Use an event with subtitles configured to show an example of how they work here!"
            )
        }
    }
}

@Composable
private fun ColumnScope.SubtitleSampleDisplay(
    subtitleState: SdkSubtitleState,
    availableSubtitles: Set<AvailableSubtitle>,
    scrollState: ScrollState,
) {
    val enabled = subtitleState.isEnabled
    val scope = rememberCoroutineScope()

    //"null" means Automatic (Play subtitles for whatever channel's audio is being played
    var chosenSubtitle: AvailableSubtitle? by remember { mutableStateOf(null) }
    LaunchedEffect(subtitleState) {
        when (subtitleState) {
            is SdkSubtitleState.Specific  -> {
                val correspondingSubtitle = availableSubtitles.find { it.channelId == subtitleState.channelId }
                chosenSubtitle = correspondingSubtitle
            }
            is SdkSubtitleState.Automatic -> chosenSubtitle = null
            Disabled                      -> {} // do nothing
        }
    }

    Spacer(modifier = Modifier.weight(1f))
    Column(
        modifier = Modifier
            .padding(top = 24.dp)
            .height(if (enabled) 300.dp else Dp.Unspecified)
            .fillMaxWidth()
            .clip(
                RoundedCornerShape(
                    CornerSize(12.dp), CornerSize(12.dp), CornerSize(0.dp), CornerSize(0.dp)
                )
            )
            .background(MaterialTheme.colorScheme.surface)
            .padding(12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center
        ) {
            Button(
                border = BorderStroke(1.dp, MaterialTheme.colorScheme.onBackground),
                shape = RoundedCornerShape(12.dp),
                onClick = remember(chosenSubtitle, subtitleState) {
                    {
                        when (subtitleState) {
                            is Disabled -> {
                                LiveVoice.startSubtitles(chosenSubtitle?.channelId)
                            }
                            else        -> {
                                LiveVoice.stopSubtitles()
                            }
                        }
                        scope.launch { scrollState.animateScrollBy(1000f) }
                    }
                }, colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.background)
            ) {
                SampleText(
                    if (subtitleState is Enabled) "Disable subtitles" else "Enable subtitles",
                    color = MaterialTheme.colorScheme.onBackground
                )
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {

            SampleDropdownMenu(
                elements = listOf(null) + availableSubtitles,
                selected = chosenSubtitle,
                onSelect = {
                    chosenSubtitle = it
                    LiveVoice.startSubtitles(chosenSubtitle?.channelId)
                    scope.launch {
                        scrollState.animateScrollBy(1000f)
                    }
                }
            )
        }

        if (enabled)
            HorizontalDivider(Modifier.padding(top = 12.dp, bottom = 24.dp))

        /**
         * Display actual subtitles!
         *
         * If you limit the height of it, you could use a LazyColumn here to show more than the last
         * 3 subtitle fragments.
         *
         * Note that you will have to handle scrolling down in this case.
         *
         * Something like:
         *
         * LaunchedEffect(subtitleState.fragments.size){ scrollState.animateScrollBy(1000f) }
         *
         * can work well.
         */
        Column(
            modifier = Modifier
                .scrollable(rememberScrollState(), orientation = Orientation.Vertical),
        ) {
            if (subtitleState is Enabled) {
                val fragments by subtitleState.fragments.collectAsState()
                fragments.takeLast(3).forEach {
                    SampleText(it)
                }
            }
        }
    }
}
