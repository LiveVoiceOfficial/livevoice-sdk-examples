package io.livevoice.example.customui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import io.livevoice.example.shared.AudioOutputRow
import io.livevoice.example.shared.DetailedCustomChannelRow
import io.livevoice.example.shared.CustomErrorCard
import io.livevoice.example.shared.CustomLoadingCard
import io.livevoice.example.shared.DemoCardSection
import io.livevoice.example.shared.DemoNotes
import io.livevoice.example.shared.DemoPage
import io.livevoice.example.shared.DemoWarningBanner

@Composable
fun CustomChannelCellScreen(
    paddingValues: PaddingValues,
) {
    DemoPage(
        paddingValues = paddingValues,
        summary = "Replace the built-in channel row with your own Compose view while keeping the LiveVoice session logic."
    ) {
        val customUiAllowed by LiveVoice.customUiAllowed.collectAsState()
        if (!customUiAllowed) {
            DemoWarningBanner(
                "This API key does not allow custom UI. Pick one that allows it in the top right."
            )
        }

        DemoCardSection(title = "Live sample") {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                // Keep audio output reachable right above the list, so playback is never silent.
                AudioOutputRow()
                LiveVoiceView(
                    modifier = Modifier.fillMaxWidth(),
                    channelDisplay = DetailedCustomChannelRow,
                    loadingDisplay = CustomLoadingCard,
                    errorDisplay = CustomErrorCard
                )
            }
        }

        DemoCardSection(title = "Implementation notes") {
            DemoNotes(
                listOf(
                    "The SDK passes your Compose view the channel to render for each row.",
                    "The channel's Booleans are surfaced — isOnline as the status dot, the rest as badges (solid when true, faint when false) — so you can see which values you can read even when a feature doesn't apply to your own design.",
                    "The row is tappable — and its play control active — only when the channel can be started (online and with audio); otherwise the cell is inert.",
                    "You can replace the row design without changing the built-in session behavior."
                )
            )
        }
    }
}
