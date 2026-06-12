package io.livevoice.example.shared

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceOutput

// Display helpers for the SDK's LiveVoiceOutput, shared by every output control below.
private fun LiveVoiceOutput.demoLabel(): String = when (this) {
    LiveVoiceOutput.HEADPHONES -> "Receiver"
    LiveVoiceOutput.SPEAKER -> "Speaker"
}

private fun LiveVoiceOutput.demoGlyph(): String = when (this) {
    LiveVoiceOutput.HEADPHONES -> "🎧" // 🎧
    LiveVoiceOutput.SPEAKER -> "🔊" // 🔊
}

private fun selectOutput(output: LiveVoiceOutput) {
    LiveVoice.changeOutput(useLoudSpeaker = output == LiveVoiceOutput.SPEAKER)
}

/** The compact output control: an icon-only segmented picker kept narrow so it can sit above a list. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CompactAudioOutputPicker() {
    val outputMode by LiveVoice.outputMode.collectAsState()
    val options = listOf(LiveVoiceOutput.HEADPHONES, LiveVoiceOutput.SPEAKER)
    SingleChoiceSegmentedButtonRow {
        options.forEachIndexed { index, output ->
            SegmentedButton(
                selected = outputMode == output,
                onClick = { selectOutput(output) },
                shape = SegmentedButtonDefaults.itemShape(index = index, count = options.size),
                icon = {},
                label = { Text(output.demoGlyph()) }
            )
        }
    }
}

/** An "Audio output" label paired with the compact picker — placed above channel lists. */
@Composable
fun AudioOutputRow() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = "Audio output",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        CompactAudioOutputPicker()
    }
}

/** A pop-up menu variant: a field that opens a menu listing the outputs. */
@Composable
fun MenuAudioOutputPicker() {
    val outputMode by LiveVoice.outputMode.collectAsState()
    DemoPickerField(
        selectedLabel = outputMode.demoLabel(),
        options = listOf(
            DemoPickerOption(LiveVoiceOutput.HEADPHONES, LiveVoiceOutput.HEADPHONES.demoLabel()),
            DemoPickerOption(LiveVoiceOutput.SPEAKER, LiveVoiceOutput.SPEAKER.demoLabel()),
        ),
        onOptionSelected = { selectOutput(it) }
    )
}

/** A single button that toggles straight between the two outputs. */
@Composable
fun ToggleAudioOutputButton() {
    val outputMode by LiveVoice.outputMode.collectAsState()
    OutlinedButton(
        onClick = {
            selectOutput(
                if (outputMode == LiveVoiceOutput.SPEAKER) {
                    LiveVoiceOutput.HEADPHONES
                } else {
                    LiveVoiceOutput.SPEAKER
                }
            )
        }
    ) {
        Text("${outputMode.demoGlyph()}  ${outputMode.demoLabel()}")
    }
}
