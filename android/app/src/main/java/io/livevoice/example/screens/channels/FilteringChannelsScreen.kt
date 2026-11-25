// Filtering channels
//
// LiveVoiceView's `filter` decides which channels it shows: it gets each
// channel and returns `true` to keep it. Filter on any channel property;
// the look, playback and reconnection stay the same. A filter that matches
// nothing shows the view's "no matching channels" state.
//
// Uses: LiveVoiceView(filter), LiveVoiceChannel
// See also: Default interface, Custom view states (your own empty part).

package io.livevoice.example.screens.channels

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.DemoSegmentedPicker
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView

@Composable
fun FilteringChannelsScreen() {
    var filter by rememberSaveable { mutableStateOf(Filter.All) }

    DemoScreen("Filtering channels", caption = "Show only the channels you want.") {
        DemoSection("Filter") {
            DemoSegmentedPicker(Filter.entries.map { it to it.title }, selected = filter) { filter = it }
        }
        DemoSection("Channels") {
            LiveVoiceView(
                filter = { channel ->
                    when (filter) {
                        Filter.All -> true
                        Filter.Online -> channel.isOnline
                        Filter.WithSubtitles -> channel.hasSubtitles
                        Filter.None -> false
                    }
                },
            )
            // More filters:
            // - A single channel, by its ID from the dashboard's "Show Options":
            //   `channel.id == 137L`
            // - A source channel with the AI translations derived from it:
            //   `channel.id == sourceId || channel.aiTranslationInfo?.sourceChannelId == sourceId`
        }
    }
}

private enum class Filter(val title: String) {
    All("All"),
    Online("Online"),
    WithSubtitles("Subtitles"),
    None("None"),
}
