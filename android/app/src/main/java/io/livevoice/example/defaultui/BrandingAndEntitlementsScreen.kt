package io.livevoice.example.defaultui

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.channel.LiveVoiceChannel
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import io.livevoice.example.shared.DemoApiKeyPreset
import io.livevoice.example.shared.BasicCustomChannelRow
import io.livevoice.example.shared.CustomErrorCard
import io.livevoice.example.shared.CustomLoadingCard
import io.livevoice.example.shared.DemoCardSection
import io.livevoice.example.shared.DemoLabelValueRow
import io.livevoice.example.shared.DemoNotes
import io.livevoice.example.shared.DemoPage

@Composable
fun BrandingAndEntitlementsScreen(
    paddingValues: PaddingValues,
    selectedPreset: DemoApiKeyPreset,
) {
    val hideBranding by LiveVoice.hideBranding.collectAsState()
    val customUiAllowed by LiveVoice.customUiAllowed.collectAsState()

    val primaryChannelId = remember(selectedPreset) { object { var value: Long? = null } }
    val primaryFilter: (LiveVoiceChannel) -> Boolean = { channel ->
        val current = primaryChannelId.value
        if (current != null) {
            channel.id == current
        } else {
            primaryChannelId.value = channel.id
            true
        }
    }

    DemoPage(
        paddingValues = paddingValues,
        summary = "Switch the preset API key from the toolbar to inspect the real branding and custom UI permissions for this demo event."
    ) {
        DemoCardSection(title = "Live sample") {
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(
                        text = "Standard view",
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.Medium
                    )

                    LiveVoiceView(filter = primaryFilter)
                }

                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(
                        text = "Custom row",
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.Medium
                    )

                    LiveVoiceView(
                        filter = primaryFilter,
                        channelDisplay = BasicCustomChannelRow,
                        loadingDisplay = CustomLoadingCard,
                        errorDisplay = CustomErrorCard
                    )
                }
            }
        }

        DemoCardSection(title = "Current features") {
            DemoLabelValueRow("Selected preset", selectedPreset.title)
            DemoLabelValueRow("Branding", if (hideBranding) "Hidden" else "Visible")
            DemoLabelValueRow("Custom UI", if (customUiAllowed) "Allowed" else "Not allowed")
        }

        DemoCardSection(title = "Implementation notes") {
            DemoNotes(
                listOf(
                    "Both samples above show only the event's first channel.",
                    "Switch the API key preset from the toolbar to compare branding and custom UI entitlements for that same channel."
                )
            )
        }
    }
}
