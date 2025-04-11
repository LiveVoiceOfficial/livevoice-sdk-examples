package io.livevoice.sdk_testapp

import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.animateScrollBy
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CornerSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.HorizontalDivider
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
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.SdkSubtitleLanguage
import io.livevoice.sdk.android.publicApi.core.model.SdkSubtitleState
import io.livevoice.sdk.android.publicApi.core.model.SdkSubtitleState.Disabled
import io.livevoice.sdk.android.publicApi.core.model.SdkSubtitleState.Enabled
import io.livevoice.sdk.android.publicApi.core.model.SdkSubtitleState.Specific
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.Locale

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
            modifier = Modifier.padding(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            SampleText("This is the default LiveVoice View")
            LiveVoiceView()
            SampleSpacer()

            SampleText("It is also possible to filter channels")
            LiveVoiceView(filter = { it.name == "German" })
            SampleSpacer()

            SampleText("And the OutputSwitch is Optional as well")
            LiveVoiceView(showAudioSwitch = false)
            SampleSpacer()
        }

        val subtitleState by LiveVoice.subtitleState.collectAsState(Disabled(mapOf()))
        if (subtitleState.availableSubtitles.isNotEmpty()) {
            SampleText("Your event has the following Subtitles configured")
            Column(
                modifier = Modifier
                    .padding(12.dp)
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(MaterialTheme.colorScheme.surface)
                    .padding(12.dp),
            ) {
                for (item in subtitleState.availableSubtitles) {
                    SampleText(
                        text = "Channel: ${item.key}: [${item.value.joinToString { """"$it"""" }}]",
                    )
                }
            }
            SubtitleSampleDisplay(subtitleState, scrollState)
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
    scrollState: ScrollState,
) {
    val enabled = subtitleState.isEnabled
    val scope = rememberCoroutineScope()

    var languageTag: String? by remember { mutableStateOf(null) }
    var channelId: Long? by remember { mutableStateOf(null) }
    var isInitialLaunch by remember { mutableStateOf(true) }

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
        LaunchedEffect(languageTag, channelId) {
            if (isInitialLaunch) {
                isInitialLaunch = false
                return@LaunchedEffect
            }
            //restart the subtitles if the chosen language changed
            LiveVoice.startSubtitles(channelId, languageTag.toSdkSubtitleLanguage())
            delay(500)
            scrollState.animateScrollBy(1000f)
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center
        ) {
            Button(
                shape = RoundedCornerShape(12.dp),
                onClick = {
                    when (subtitleState) {
                        is Specific -> LiveVoice.stopSubtitles()
                        is Disabled -> {
                            val subtitleLanguage = languageTag.toSdkSubtitleLanguage()

                            LiveVoice.startSubtitles(channelId, subtitleLanguage)
                        }

                        is SdkSubtitleState.Automatic,
                            -> LiveVoice.stopSubtitles()
                    }
                    scope.launch {
                        scrollState.animateScrollBy(1000f)
                    }
                }
            ) {
                SampleText(
                    if (subtitleState is Enabled) "Disable subtitles" else "Enable subtitles",
                    color = Color.White
                )
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            val channels: List<DropdownOption<Long?>> = subtitleState.availableSubtitles.keys.map {
                DropdownOption(
                    displayValue = it.toString(),
                    clickValue = it
                )
            }
            val autoChannelOption = DropdownOption<Long?>("auto", null)
            val combined: List<DropdownOption<Long?>> =
                listOf(autoChannelOption, *channels.toTypedArray())

            SampleDropdownMenu(
                elements = combined,
                selected = channelId,
                buttonPrefix = "ChannelId",
                nullableOptionTitle = "Auto",
                onSelect = { channelId = it })

            val sdkSubtitleConfig: Set<String?> =
                subtitleState.availableSubtitles[channelId] ?: emptySet()

            val subtitleOptions: List<DropdownOption<String?>> = sdkSubtitleConfig
                .map {
                    if (it == null) {
                        DropdownOption("Transcript", null)
                    } else
                        DropdownOption(
                            displayValue = Locale.forLanguageTag(it).displayName,
                            clickValue = it
                        )
                }

            SampleDropdownMenu(
                elements = subtitleOptions,
                selected = languageTag,
                buttonPrefix = "Language",
                nullableOptionTitle = "Transcript",
                onSelect = { languageTag = it })
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
        Column {
            if (subtitleState is Enabled) {
                val fragments by subtitleState.fragments.collectAsStateWithLifecycle()
                fragments.takeLast(3).forEach {
                    SampleText(it)
                }
            }
        }
    }
}

private fun String?.toSdkSubtitleLanguage() = this
    ?.let { SdkSubtitleLanguage.Translated(it) }
    ?: SdkSubtitleLanguage.Transcript
