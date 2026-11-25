// Diagnostics log
//
// The SDK reports what it does as named events, such as `LV_JOIN_RESULT` or
// `LV_CHANNEL_RESULT`, each with a level and a few fields; a failure carries
// its error `code`. They go to Logcat (tag `LiveVoiceSDK`), and
// `setLogListener` forwards them to your own logging. Tap a channel to see
// some.
//
// On Android the listener is called on whichever thread logged the event;
// it must return quickly and must not call the SDK. Here it hands each entry
// to a flow that the screen collects on the main thread.
//
// Uses: LiveVoice.setLogListener(listener), LiveVoiceLogListener,
// LiveVoiceLogEntry, LiveVoiceLogLevel
// See also: Joining an event, Localization and accessibility (error messages).

package io.livevoice.example.screens.customization

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import io.livevoice.example.demo.DemoPlaceholder
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceLogEntry
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceLogLevel
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceLogListener
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.buffer
import kotlinx.coroutines.flow.callbackFlow
import java.text.DateFormat
import java.util.Date

@Composable
fun DiagnosticsScreen() {
    // The latest entries, newest first.
    val entries = remember { mutableStateListOf<LiveVoiceLogEntry>() }

    LaunchedEffect(Unit) {
        // There is one listener: setting one replaces the previous, `null`
        // removes it. It's called on the thread that logged the event, so
        // it only hands the entry on, and never calls the SDK.
        callbackFlow {
            LiveVoice.setLogListener(LiveVoiceLogListener { entry -> trySend(entry) })
            // Leaving the screen cancels the collection, which removes the listener.
            awaitClose { LiveVoice.setLogListener(null) }
        }.buffer(Channel.UNLIMITED).collect { entry ->
            entries.add(0, entry)
            if (entries.size > 100) entries.removeRange(100, entries.size)
        }
    }

    DemoScreen("Diagnostics log", caption = "Read what the SDK did, and why a call failed.") {
        DemoSection("Channels") {
            LiveVoiceView()
        }
        DemoSection("Log") {
            if (entries.isEmpty()) {
                DemoPlaceholder("Nothing logged yet: tap a channel.")
            }
            entries.forEach { entry ->
                LogEntryRow(entry)
            }
        }
    }
}

/**
 * One entry: its event, level, time and fields. Entries never contain a
 * password or an API key.
 */
@Composable
private fun LogEntryRow(entry: LiveVoiceLogEntry) {
    val isError = when (entry.level) {
        LiveVoiceLogLevel.INFO -> false
        LiveVoiceLogLevel.ERROR -> true
        else -> false
    }
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Row {
            Text(
                text = entry.event,
                style = MaterialTheme.typography.bodyMedium,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.SemiBold,
                color = if (isError) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.weight(1f),
            )
            Text(
                text = DateFormat.getTimeInstance(DateFormat.MEDIUM).format(Date(entry.timestampEpochMilliseconds)),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        Text(
            text = entry.fields.entries.sortedBy { it.key }.joinToString(" ") { "${it.key}=${it.value}" },
            style = MaterialTheme.typography.bodySmall,
            fontFamily = FontFamily.Monospace,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}
