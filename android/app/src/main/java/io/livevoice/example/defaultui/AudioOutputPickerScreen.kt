package io.livevoice.example.defaultui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import io.livevoice.example.shared.CompactAudioOutputPicker
import io.livevoice.example.shared.DemoCardSection
import io.livevoice.example.shared.DemoNotes
import io.livevoice.example.shared.DemoPage
import io.livevoice.example.shared.MenuAudioOutputPicker
import io.livevoice.example.shared.ToggleAudioOutputButton

@Composable
fun AudioOutputPickerScreen(paddingValues: PaddingValues) {
    DemoPage(
        paddingValues = paddingValues,
        summary = "Place an audio output control wherever it fits in your app and bind it to the SDK. " +
            "Here are three styles — all driving the same output."
    ) {
        DemoCardSection(title = "Live sample") {
            LiveVoiceView()
        }

        DemoCardSection(title = "Output controls") {
            Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
                AudioOutputVariant(
                    title = "Compact icons",
                    detail = "An icon-only segmented picker that stays compact."
                ) {
                    CompactAudioOutputPicker()
                }
                AudioOutputVariant(
                    title = "Pop-up menu",
                    detail = "A field that opens a menu — handy when space is tight."
                ) {
                    MenuAudioOutputPicker()
                }
                AudioOutputVariant(
                    title = "Toggle button",
                    detail = "A single button that flips straight to the other output."
                ) {
                    ToggleAudioOutputButton()
                }
            }
        }

        DemoCardSection(title = "Implementation notes") {
            DemoNotes(
                listOf(
                    "The Android SDK exposes outputMode and changeOutput for custom output controls.",
                    "Every control here drives that single value, so they all stay in sync.",
                    "Bind a picker, menu, or toggle to it wherever it makes sense in your screen."
                )
            )
        }
    }
}

@Composable
private fun AudioOutputVariant(
    title: String,
    detail: String,
    content: @Composable () -> Unit,
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Text(text = title, style = MaterialTheme.typography.titleSmall)
        Text(
            text = detail,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        content()
    }
}
