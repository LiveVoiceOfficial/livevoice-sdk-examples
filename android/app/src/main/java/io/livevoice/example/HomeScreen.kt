package io.livevoice.example

import androidx.compose.foundation.Image
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import io.livevoice.example.demo.DemoApiKeyButton
import io.livevoice.example.demo.DemoListRow
import io.livevoice.example.demo.DemoListSection
import io.livevoice.example.demo.DemoRoute
import io.livevoice.example.demo.LocalDemoNavigator
import io.livevoice.sdk.android.publicApi.core.LiveVoice

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen() {
    val navigator = LocalDemoNavigator.current

    Scaffold(
        containerColor = MaterialTheme.colorScheme.surfaceContainer,
        topBar = {
            TopAppBar(
                title = {},
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
            verticalArrangement = Arrangement.spacedBy(28.dp),
        ) {
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Image(
                        painter = painterResource(if (isSystemInDarkTheme()) R.drawable.logo_vertical_dark else R.drawable.logo_vertical),
                        contentDescription = "LiveVoice",
                        modifier = Modifier.width(180.dp),
                    )
                    Text(
                        text = "SDK ${LiveVoice.sdkVersion}",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                Text(
                    text = "A quick tour of LiveVoice SDK features.",
                    style = MaterialTheme.typography.bodyLarge,
                    textAlign = TextAlign.Center,
                )
            }

            DemoListSection("Getting started") {
                DemoListRow(
                    title = "Default interface",
                    summary = "The smallest integration: the event's channels, ready to play.",
                    onClick = { navigator.open(DemoRoute.DefaultInterface) },
                )
                DemoListRow(
                    title = "Joining an event",
                    summary = "Join, reconnect and leave, and follow the connection.",
                    onClick = { navigator.open(DemoRoute.JoiningEvent) },
                )
            }

            DemoListSection("Channels") {
                DemoListRow(
                    title = "Filtering channels",
                    summary = "Show only the channels you want.",
                    onClick = { navigator.open(DemoRoute.FilteringChannels) },
                )
                DemoListRow(
                    title = "Custom channel cell",
                    summary = "Draw each channel with your own view.",
                    onClick = { navigator.open(DemoRoute.CustomChannelCell) },
                )
                DemoListRow(
                    title = "Custom view states",
                    summary = "Your own loading, reconnecting, error and empty views.",
                    onClick = { navigator.open(DemoRoute.CustomViewStates) },
                )
            }

            DemoListSection("Subtitles") {
                DemoListRow(
                    title = "Subtitles",
                    summary = "Show a channel's live subtitles in your own view.",
                    onClick = { navigator.open(DemoRoute.Subtitles) },
                )
            }

            DemoListSection("Audio and system") {
                DemoListRow(
                    title = "Audio output",
                    summary = "Prefer the loudspeaker, or let the system choose.",
                    onClick = { navigator.open(DemoRoute.AudioOutput) },
                )
                DemoListRow(
                    title = "Lock screen and audio sharing",
                    summary = "Share the audio with other apps, and show the channel on the lock screen.",
                    onClick = { navigator.open(DemoRoute.LockScreen) },
                )
            }

            DemoListSection("Event features") {
                DemoListRow(
                    title = "Password-protected channels",
                    summary = "Ask for channel passwords with your own UI, and keep them.",
                    needsOwnEvent = true,
                    onClick = { navigator.open(DemoRoute.Passwords) },
                )
                DemoListRow(
                    title = "Language requests",
                    summary = "Ask the event for a language it doesn't offer yet.",
                    needsOwnEvent = true,
                    onClick = { navigator.open(DemoRoute.LanguageRequests) },
                )
                DemoListRow(
                    title = "Linked events",
                    summary = "Switch to an event linked to this one.",
                    needsOwnEvent = true,
                    onClick = { navigator.open(DemoRoute.LinkedEvents) },
                )
            }

            DemoListSection("Customization and diagnostics") {
                DemoListRow(
                    title = "Branding and entitlements",
                    summary = "See what the joined event's API key permits.",
                    onClick = { navigator.open(DemoRoute.Branding) },
                )
                DemoListRow(
                    title = "Localization and accessibility",
                    summary = "The SDK's own texts, in the app's language, for your custom parts.",
                    onClick = { navigator.open(DemoRoute.Localization) },
                )
                DemoListRow(
                    title = "Diagnostics log",
                    summary = "Read what the SDK did, and why a call failed.",
                    onClick = { navigator.open(DemoRoute.Diagnostics) },
                )
            }
        }
    }
}
