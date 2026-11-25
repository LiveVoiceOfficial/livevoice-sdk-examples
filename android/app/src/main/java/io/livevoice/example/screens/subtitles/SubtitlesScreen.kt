// Subtitles
//
// `startSubtitles` with no channel follows whatever channel plays; with a
// channel from `availableSubtitles` it shows that subtitle stream, playing
// or not. `subtitles` holds the state and its fragments for your own view,
// and `stopSubtitles` ends them. You don't need LiveVoiceView for subtitles.
//
// On Android `subtitles` and `availableSubtitles` are StateFlows: collect
// them in Compose with `collectAsState()`. Each change of the fragments is a
// new value. A protected channel's subtitles ask for its password with the
// SDK's prompt, which only a LiveVoiceView on screen can show.
//
// Uses: LiveVoice.availableSubtitles, startSubtitles(channelId, password),
// stopSubtitles(), subtitles, LiveVoiceSubtitleState
// See also: Filtering channels (channels with subtitles), Password-protected
// channels (subtitles of a protected channel).

package io.livevoice.example.screens.subtitles

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.livevoice.example.demo.DemoButton
import io.livevoice.example.demo.DemoButtonRow
import io.livevoice.example.demo.DemoMenuPicker
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException
import io.livevoice.sdk.android.publicApi.core.model.subtitle.LiveVoiceSubtitleState
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.launch

@Composable
fun SubtitlesScreen() {
    val availableSubtitles by LiveVoice.availableSubtitles.collectAsState()
    // `null` follows the playing channel.
    var channelId by rememberSaveable { mutableStateOf<Long?>(null) }
    var failure by remember { mutableStateOf<LiveVoiceException?>(null) }
    val scope = rememberCoroutineScope()

    /**
     * One subtitle stream at a time: starting another replaces it, without
     * a stop in between. Subtitles never start, stop or switch playback.
     */
    suspend fun start() {
        failure = null
        try {
            LiveVoice.startSubtitles(channelId = channelId)
        } catch (error: LiveVoiceException) {
            failure = error
        }
    }

    suspend fun stop() {
        failure = null
        try {
            LiveVoice.stopSubtitles()
        } catch (error: LiveVoiceException) {
            failure = error
        }
    }

    DemoScreen("Subtitles", caption = "Show a channel's live subtitles in your own view.", error = failure, showsSubtitles = true) {
        DemoSection("Subtitles") {
            SubtitleView()
        }
        DemoSection("Source") {
            // `null` until known, empty when the event has none. A `null`
            // language is the channel's original transcript.
            DemoMenuPicker(
                label = "Subtitles",
                options = listOf<Pair<Long?, String>>(null to "Playing channel") +
                    availableSubtitles.orEmpty().map { subtitle ->
                        subtitle.channelId to if (subtitle.language == null) "${subtitle.name} (original)" else subtitle.name
                    },
                selected = channelId,
                onSelect = { channelId = it },
            )
            DemoButtonRow {
                DemoButton("Start") { scope.launch { start() } }
                DemoButton("Stop") { scope.launch { stop() } }
            }
        }
        DemoSection("Channels") {
            // Following subtitles show the channel playing here.
            LiveVoiceView()
        }
    }
}

/**
 * Your own subtitle view: the fragments of `LiveVoice.subtitles` in a
 * fixed-height list that shows the newest text.
 *
 * It scrolls to the end on every change, also when the last fragment only
 * grows (the SDK appends an unfinished sentence to it) and also when you
 * scrolled up to read. A real app would usually follow only while the
 * reader is at the bottom.
 */
@Composable
private fun SubtitleView() {
    val subtitles by LiveVoice.subtitles.collectAsState()
    val fragments = when (val state = subtitles) {
        is LiveVoiceSubtitleState.Automatic -> state.fragments
        is LiveVoiceSubtitleState.Specific -> state.fragments
        LiveVoiceSubtitleState.Disabled -> null
        else -> null
    }
    when {
        fragments == null -> SubtitlePlaceholder("Start subtitles to see them here.")
        fragments.isEmpty() -> SubtitlePlaceholder("Waiting for the first words…")
        else -> Feed(fragments)
    }
}

@Composable
private fun Feed(fragments: List<String>) {
    val listState = rememberLazyListState()
    // After every change, the end of the last fragment: an offset past the
    // item's end scrolls as far as the list goes.
    LaunchedEffect(fragments) {
        listState.scrollToItem(fragments.lastIndex, Int.MAX_VALUE)
    }
    LazyColumn(
        state = listState,
        modifier = Modifier
            .fillMaxWidth()
            .height(220.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        itemsIndexed(fragments) { _, fragment ->
            Text(fragment, style = MaterialTheme.typography.bodyLarge)
        }
    }
}

@Composable
private fun SubtitlePlaceholder(text: String) {
    Text(text, style = MaterialTheme.typography.bodyLarge, color = MaterialTheme.colorScheme.onSurfaceVariant)
}
