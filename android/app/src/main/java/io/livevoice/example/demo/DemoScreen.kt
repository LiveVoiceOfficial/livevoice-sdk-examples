// Demo scaffolding — not needed for an integration.
//
// The look every demo screen shares, so that a screen's own file reads as
// LiveVoice SDK usage: the screen shell, the grouped sections and the one-line
// note on what a screen needs from the event.

package io.livevoice.example.demo

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceConnection
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException
import io.livevoice.sdk.android.publicApi.core.model.subtitle.LiveVoiceSubtitleState

/**
 * A demo screen: a scrolling column of [DemoSection]s under a title, with a
 * one-sentence caption.
 *
 * `error` shows a failed call's message in one line under the caption, the
 * text the SDK provides for it. While subtitles are on, the screen links to
 * the Subtitles screen, unless it is the one that shows them (`showsSubtitles`).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DemoScreen(
    title: String,
    caption: String,
    error: LiveVoiceException? = null,
    showsSubtitles: Boolean = false,
    content: @Composable ColumnScope.() -> Unit,
) {
    val navigator = LocalDemoNavigator.current
    val subtitles by LiveVoice.subtitles.collectAsState()

    Scaffold(
        containerColor = MaterialTheme.colorScheme.surfaceContainer,
        topBar = {
            TopAppBar(
                title = {},
                navigationIcon = {
                    IconButton(onClick = navigator::back) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = { DemoApiKeyButton() },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surfaceContainer),
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(padding)
                .padding(start = 20.dp, end = 20.dp, bottom = 24.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp),
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                // In the content rather than the bar, so a long title wraps.
                Text(
                    text = title,
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.semantics { heading() },
                )
                Text(
                    text = caption,
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            if (error != null) {
                DemoNote(error.message, DemoNoteKind.Error)
            }
            if (subtitles !is LiveVoiceSubtitleState.Disabled && !showsSubtitles) {
                DemoNote(
                    "Go to the Subtitles section to see them in action.",
                    DemoNoteKind.Link,
                    onClick = { navigator.open(DemoRoute.Subtitles) },
                )
            }
            content()
        }
    }
}

/** A titled, rounded box that groups part of a demo screen. */
@Composable
fun DemoSection(title: String, content: @Composable ColumnScope.() -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        // Above the box, like a grouped list's header, so it never reads as
        // part of the content.
        Text(
            text = title.uppercase(),
            style = MaterialTheme.typography.labelMedium,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier
                .padding(horizontal = 4.dp)
                .semantics { heading() },
        )
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(demoSectionFill())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            content = content,
        )
    }
}

@Composable
private fun demoSectionFill(): Color = if (isSystemInDarkTheme()) Color(0xFF1C1C1E) else Color(0xFFE8E8ED)

/** The background of a card of your own inside a [DemoSection], such as a custom cell. */
@Composable
fun demoCardColor(): Color = if (isSystemInDarkTheme()) Color(0xFF2C2C2E) else Color.White

/** What a screen needs beyond the demo event; see [DemoRequirement]. */
sealed interface DemoNeed {
    /** An API key that permits custom UI: the "Full customization" preset. */
    data object CustomUi : DemoNeed

    /**
     * An event with [feature] enabled in the Admin console, which the demo
     * event lacks. With your own event, the note says that this event doesn't
     * have it enabled.
     */
    data class OwnEvent(val feature: String) : DemoNeed
}

/**
 * What a demo screen needs beyond the demo event, said in one line while it
 * is missing, with a button to pick another event or API key. Until an event
 * is ready it says it waits instead: permissions and features are only
 * known once joined.
 */
@Composable
fun DemoRequirement(need: DemoNeed, isMet: Boolean) {
    val demoSession = LocalDemoSession.current
    val connection by LiveVoice.connection.collectAsState()
    val eventIsReady = connection is LiveVoiceConnection.Ready || connection is LiveVoiceConnection.Reconnecting

    if (!eventIsReady) {
        DemoNote("Waiting for the event…", DemoNoteKind.Waiting)
        return
    }
    if (isMet) return

    val text = when (need) {
        DemoNeed.CustomUi -> "Needs an API key that permits custom UI."
        is DemoNeed.OwnEvent -> if (demoSession.usesOwnEvent) {
            "This event doesn't have the '${need.feature}' feature enabled. Enable this in the Admin console on the web."
        } else {
            "The demo event doesn't have the '${need.feature}' feature enabled. To try it, use your own event and enable the feature in the Admin console on the web."
        }
    }
    val buttonTitle = when (need) {
        DemoNeed.CustomUi -> "Choose an API key"
        is DemoNeed.OwnEvent -> if (demoSession.usesOwnEvent) "Use another event" else "Use your own event"
    }
    val orange = Color(0xFFFF9500)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(orange.copy(alpha = 0.12f))
            .padding(14.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Icon(Icons.Filled.Warning, contentDescription = null, tint = orange, modifier = Modifier.padding(top = 2.dp))
        Column {
            Text(text, style = MaterialTheme.typography.bodyMedium)
            TextButton(
                onClick = {
                    when (need) {
                        DemoNeed.CustomUi -> demoSession.isApiKeyPickerPresented = true
                        is DemoNeed.OwnEvent -> demoSession.isCustomCredentialsEditorPresented = true
                    }
                },
            ) {
                Text(buttonTitle, fontWeight = FontWeight.SemiBold)
            }
        }
    }
}

/** The icon and colour of a [DemoNote]. */
enum class DemoNoteKind {
    /** Background information. */
    Info,

    /** Something the screen waits for. */
    Waiting,

    /** A failed call's message. */
    Error,

    /** A way to another screen. */
    Link,
}

/** One line of information on a demo screen, with an icon. */
@Composable
fun DemoNote(text: String, kind: DemoNoteKind, onClick: (() -> Unit)? = null) {
    val (icon: ImageVector, tint: Color) = when (kind) {
        DemoNoteKind.Info -> Icons.Filled.Info to MaterialTheme.colorScheme.onSurfaceVariant
        DemoNoteKind.Waiting -> Icons.Filled.Refresh to MaterialTheme.colorScheme.onSurfaceVariant
        DemoNoteKind.Error -> Icons.Filled.Warning to MaterialTheme.colorScheme.error
        DemoNoteKind.Link -> Icons.AutoMirrored.Filled.ArrowForward to MaterialTheme.colorScheme.primary
    }
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .then(if (onClick != null) Modifier.clickable(role = Role.Button, onClick = onClick) else Modifier),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.Top,
    ) {
        Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(18.dp))
        Text(text, style = MaterialTheme.typography.bodySmall, color = tint)
    }
}

/**
 * A small outlined label for one of a channel's properties in a custom
 * cell: full contrast when `isOn`, faint when not, so every value stays
 * visible. Your app draws its own.
 */
@Composable
fun DemoTag(text: String, isOn: Boolean = true) {
    val color = MaterialTheme.colorScheme.onSurface
    Text(
        text = text,
        style = MaterialTheme.typography.labelSmall,
        color = color.copy(alpha = if (isOn) 1f else 0.3f),
        maxLines = 1,
        modifier = Modifier
            .border(0.5.dp, color.copy(alpha = if (isOn) 0.85f else 0.16f), CircleShape)
            .padding(horizontal = 8.dp, vertical = 2.dp),
    )
}
