// Custom view states
//
// LiveVoiceView takes your own views for its states: `loading`,
// `reconnecting`, `error` and `empty`; the parts you leave out keep the SDK's
// design. `onCommandError` receives the errors of the SDK's own controls.
// LiveVoiceView shows a part only while its state lasts, so the screen shows
// each of your views with sample values first. Below, LiveVoiceView uses them:
// turn on airplane mode while a channel plays to see reconnecting and errors.
//
// On Android the parts are parameters of LiveVoiceView, not modifiers. The
// `error` part's retry is a suspend function, and `reconnecting` gets the
// next attempt's time in epoch milliseconds: count down to it yourself.
//
// Needs: an API key that permits custom UI (except for `loading`).
// Uses: LiveVoiceView(loading, reconnecting, error, empty, onCommandError),
// LiveVoiceRetry, LiveVoiceEmptyReason
// See also: Custom channel cell, Joining an event (connection and reconnect),
// Localization and accessibility (error messages).

package io.livevoice.example.screens.channels

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import io.livevoice.example.demo.DemoLabeled
import io.livevoice.example.demo.DemoNeed
import io.livevoice.example.demo.DemoNote
import io.livevoice.example.demo.DemoNoteKind
import io.livevoice.example.demo.DemoRequirement
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.demoCardColor
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceErrorCode
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceRetry
import io.livevoice.sdk.android.publicApi.views.LiveVoiceEmptyReason
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun CustomViewStatesScreen() {
    val customUiAllowed by LiveVoice.customUiAllowed.collectAsState()
    var failure by remember { mutableStateOf<LiveVoiceException?>(null) }
    val sampleRetry = remember { LiveVoiceRetry.Scheduled(System.currentTimeMillis() + 8_000) }

    DemoScreen("Custom view states", caption = "Show loading, reconnecting, errors and no channels your way.", error = failure) {
        DemoRequirement(DemoNeed.CustomUi, isMet = customUiAllowed)
        DemoSection("Your views, with sample values") {
            DemoLabeled("Loading") { LoadingView() }
            DemoLabeled("Reconnecting") { ReconnectingView(sampleRetry) }
            DemoLabeled("Error") { ErrorView(LiveVoiceException(LiveVoiceErrorCode.NO_NETWORK), retry = {}) }
            DemoLabeled("No channels") { NoChannelsView(LiveVoiceEmptyReason.NO_CHANNELS) }
        }
        DemoSection("In LiveVoiceView") {
            DemoNote("Your views show while their state lasts; while connected, the channels do.", DemoNoteKind.Info)
            LiveVoiceView(
                loading = { LoadingView() },
                reconnecting = { retry -> ReconnectingView(retry) },
                error = { error, retry -> ErrorView(error, retry) },
                empty = { reason -> NoChannelsView(reason) },
                // CANCELLED and SUPERSEDED never arrive here. Your own parts
                // get their errors from their actions instead.
                onCommandError = { error -> failure = error },
            )
        }
    }
}

/** While the event loads. */
@Composable
private fun LoadingView() {
    StateRow(title = "Loading channels…") {
        CircularProgressIndicator(modifier = Modifier.size(24.dp), strokeWidth = 2.dp)
    }
}

/**
 * Shown after the SDK kept the channel list, drawn disabled, for the first
 * seconds of a reconnection. The SDK reconnects by itself.
 */
@Composable
private fun ReconnectingView(retry: LiveVoiceRetry) {
    val detail by produceState(initialValue = retryText(retry), retry) {
        // Count down to a scheduled attempt, once a second.
        while (retry is LiveVoiceRetry.Scheduled && retry.atEpochMilliseconds > System.currentTimeMillis()) {
            value = retryText(retry)
            delay(1_000)
        }
        value = retryText(retry)
    }
    StateRow(title = "Reconnecting", detail = detail) {
        CircularProgressIndicator(modifier = Modifier.size(24.dp), strokeWidth = 2.dp)
    }
}

private fun retryText(retry: LiveVoiceRetry): String = when (retry) {
    LiveVoiceRetry.InProgress -> "Trying now…"
    is LiveVoiceRetry.Scheduled -> {
        val seconds = (retry.atEpochMilliseconds - System.currentTimeMillis() + 999) / 1_000
        if (seconds > 0) "Next try in $seconds s" else "Trying now…"
    }
    else -> "Trying again soon…"
}

/**
 * Shows the error's `message`, the SDK's text for it. `retry` is there
 * exactly when trying again can help.
 */
@Composable
private fun ErrorView(error: LiveVoiceException, retry: (suspend () -> Unit)?) {
    val scope = rememberCoroutineScope()
    StateRow(title = "Couldn't connect", detail = error.message, icon = Icons.Filled.Warning) {
        if (retry != null) {
            Button(
                onClick = {
                    scope.launch {
                        // A failed retry shows up as the view's next error.
                        try {
                            retry()
                        } catch (_: LiveVoiceException) {
                        }
                    }
                },
            ) {
                Text("Try again")
            }
        }
    }
}

@Composable
private fun NoChannelsView(reason: LiveVoiceEmptyReason) {
    val title = when (reason) {
        LiveVoiceEmptyReason.NO_CHANNELS -> "This event has no channels yet."
        // The view's filter matches none of the event's channels.
        LiveVoiceEmptyReason.NO_MATCHES -> "No matching channels."
        else -> "No channels."
    }
    StateRow(title = title, icon = Icons.AutoMirrored.Filled.List)
}

/**
 * The look the state views share with a channel row: an icon, a title, a
 * detail line, and an accessory on the trailing side, in a card.
 */
@Composable
private fun StateRow(
    title: String,
    detail: String? = null,
    icon: ImageVector? = null,
    accessory: @Composable RowScope.() -> Unit = {},
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(demoCardColor())
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            Icon(icon, contentDescription = null, tint = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(title, style = MaterialTheme.typography.titleMedium)
            if (detail != null) {
                Text(detail, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
        accessory()
    }
}
