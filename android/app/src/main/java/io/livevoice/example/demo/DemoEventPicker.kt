// Demo scaffolding — not needed for an integration.
// The toolbar's event picker: the demo API keys, your own event's credentials, and the sheet and
// dialog that pick them.

package io.livevoice.example.demo

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp

/** The toolbar button that opens the API key picker. */
@Composable
fun DemoApiKeyButton() {
    val demoSession = LocalDemoSession.current
    TextButton(onClick = { demoSession.isApiKeyPickerPresented = true }) {
        Text("API key", fontWeight = FontWeight.Medium)
        Icon(Icons.Filled.KeyboardArrowDown, contentDescription = null)
    }
}

/** Presents the API key picker and the credentials editor that [DemoSession] asks for. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DemoEventPickerHost() {
    val demoSession = LocalDemoSession.current

    if (demoSession.isApiKeyPickerPresented) {
        ModalBottomSheet(onDismissRequest = { demoSession.isApiKeyPickerPresented = false }) {
            Column(modifier = Modifier.padding(start = 20.dp, end = 20.dp, bottom = 24.dp)) {
                DemoApiKeyPresetList(onSelect = { demoSession.isApiKeyPickerPresented = false })
                HorizontalDivider()
                val credentials = demoSession.customCredentials
                DemoPickerRow(
                    title = "Use your own event",
                    summary = if (credentials != null) {
                        "Join code ${credentials.joinCode} · tap to edit."
                    } else {
                        "Enter your own join code and API key."
                    },
                    isSelected = demoSession.usesOwnEvent,
                    onClick = demoSession::requestCustomCredentialsEditor,
                )
            }
        }
    }

    if (demoSession.isCustomCredentialsEditorPresented) {
        DemoCustomCredentialsDialog(
            credentials = demoSession.customCredentials,
            onUse = { credentials ->
                demoSession.isCustomCredentialsEditorPresented = false
                demoSession.applyCustomCredentials(credentials)
            },
            onDismiss = { demoSession.isCustomCredentialsEditorPresented = false },
        )
    }
}

/**
 * The demo event's three API keys, each with what it permits; tapping one
 * joins the demo event with it.
 */
@Composable
fun DemoApiKeyPresetList(onSelect: () -> Unit = {}) {
    val demoSession = LocalDemoSession.current
    Column {
        DemoFixture.apiKeyPresets.forEachIndexed { index, preset ->
            if (index > 0) HorizontalDivider()
            DemoPickerRow(
                title = preset.title,
                summary = preset.summary,
                isSelected = demoSession.selectedPreset == preset,
                onClick = {
                    demoSession.select(preset)
                    onSelect()
                },
            )
        }
    }
}

@Composable
private fun DemoPickerRow(title: String, summary: String, isSelected: Boolean, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(vertical = 12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.Top,
    ) {
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(title, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.SemiBold)
            Text(
                text = summary,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        if (isSelected) {
            Icon(
                Icons.Filled.Check,
                contentDescription = "Selected",
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(18.dp),
            )
        }
    }
}

/**
 * Editor for the "Use your own event" credentials. Lets a tester join their
 * own LiveVoice event with their own join code and API key (and optional
 * password) without rebuilding the sample.
 */
@Composable
private fun DemoCustomCredentialsDialog(
    credentials: DemoCredentials?,
    onUse: (DemoCredentials) -> Unit,
    onDismiss: () -> Unit,
) {
    var joinCode by remember { mutableStateOf(credentials?.joinCode.orEmpty()) }
    var apiKey by remember { mutableStateOf(credentials?.apiKey.orEmpty()) }
    var password by remember { mutableStateOf(credentials?.password.orEmpty()) }
    val canUse = joinCode.isNotBlank() && apiKey.isNotBlank()

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Use your own event") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(
                    text = "Enter the join code and API key for your own LiveVoice event. The password is only needed for password-protected events.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                OutlinedTextField(
                    value = joinCode,
                    onValueChange = { joinCode = it },
                    label = { Text("Join code") },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(
                        // Join codes have digits and letters, in any case.
                        keyboardType = KeyboardType.Ascii,
                        capitalization = KeyboardCapitalization.Characters,
                        autoCorrectEnabled = false,
                    ),
                    modifier = Modifier.fillMaxWidth(),
                )
                OutlinedTextField(
                    value = apiKey,
                    onValueChange = { apiKey = it },
                    label = { Text("API key") },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Ascii, autoCorrectEnabled = false),
                    modifier = Modifier.fillMaxWidth(),
                )
                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Password (optional)") },
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        },
        confirmButton = {
            TextButton(
                enabled = canUse,
                onClick = {
                    onUse(DemoCredentials(joinCode = joinCode.trim(), password = password, apiKey = apiKey.trim()))
                },
            ) {
                Text("Use")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        },
    )
}
