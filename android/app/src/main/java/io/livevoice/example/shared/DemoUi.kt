@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package io.livevoice.example.shared

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.ui.graphics.Color
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.Warning
import androidx.compose.foundation.Image
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExposedDropdownMenuAnchorType
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import io.livevoice.example.R
import io.livevoice.sdk.android.publicApi.core.LiveVoice

@Composable
fun DemoScaffold(
    title: String?,
    selectedPreset: DemoApiKeyPreset,
    onPresetSelected: (DemoApiKeyPreset) -> Unit,
    customCredentials: DemoCredentials?,
    onCustomCredentialsEntered: (DemoCredentials) -> Unit,
    showTopBar: Boolean = true,
    onBack: (() -> Unit)? = null,
    content: @Composable (PaddingValues) -> Unit,
) {
    Scaffold(
        containerColor = MaterialTheme.colorScheme.surfaceContainer,
        topBar = {
            if (showTopBar) {
                TopAppBar(
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.surfaceContainer
                    ),
                    title = {
                        if (title != null) {
                            Text(title)
                        }
                    },
                    navigationIcon = {
                        if (onBack != null) {
                            IconButton(onClick = onBack) {
                                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                            }
                        }
                    },
                    actions = {
                        DemoApiKeyMenu(
                            selectedPreset = selectedPreset,
                            onPresetSelected = onPresetSelected,
                            customCredentials = customCredentials,
                            onCustomCredentialsEntered = onCustomCredentialsEntered
                        )
                    }
                )
            }
        },
        content = content
    )
}

@Composable
fun DemoPage(
    paddingValues: PaddingValues,
    summary: String,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(paddingValues)
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(24.dp),
        content = {
            Text(
                text = summary,
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            content()
        }
    )
}

@Composable
fun HomeScreen(
    paddingValues: PaddingValues,
    selectedPreset: DemoApiKeyPreset,
    onPresetSelected: (DemoApiKeyPreset) -> Unit,
    customCredentials: DemoCredentials?,
    onCustomCredentialsEntered: (DemoCredentials) -> Unit,
    onDefaultParticipantClick: () -> Unit,
    onFilteredChannelsClick: () -> Unit,
    onAudioOutputClick: () -> Unit,
    onSubtitleOnlyClick: () -> Unit,
    onBrandingClick: () -> Unit,
    onCustomChannelClick: () -> Unit,
    onLocalizationClick: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(top = 12.dp)
            .padding(paddingValues)
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(32.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                DemoApiKeyMenu(
                    selectedPreset = selectedPreset,
                    onPresetSelected = onPresetSelected,
                    customCredentials = customCredentials,
                    onCustomCredentialsEntered = onCustomCredentialsEntered
                )
            }
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Image(
                    painter = painterResource(
                        id = if (androidx.compose.foundation.isSystemInDarkTheme()) {
                            R.drawable.logo_vertical_dark
                        } else {
                            R.drawable.logo_vertical
                        }
                    ),
                    contentDescription = "LiveVoice",
                    modifier = Modifier
                        .width(180.dp)
                )
                Text(
                    text = "SDK ${LiveVoice.sdkVersion}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Text(
                text = "A quick tour of LiveVoice SDK features.",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        DemoListSection(title = "Default UI") {
            DemoListItem(
                title = "Default participant interface",
                summary = "The simplest integration, with subtitles in your own view.",
                onClick = onDefaultParticipantClick,
                showDivider = true
            )
            DemoListItem(
                title = "Filtered channel list",
                summary = "Show only the channels you want — by property, an empty result, or a source channel with its AI subtitles.",
                onClick = onFilteredChannelsClick,
                showDivider = true
            )
            DemoListItem(
                title = "Audio output picker",
                summary = "Place the audio output picker wherever it fits in your app.",
                onClick = onAudioOutputClick,
                showDivider = true
            )
            DemoListItem(
                title = "Subtitle only",
                summary = "Show subtitles without displaying any of the event channels.",
                onClick = onSubtitleOnlyClick,
                showDivider = false
            )
        }

        DemoListSection(title = "Custom UI") {
            DemoListItem(
                title = "Branding and entitlements",
                summary = "See how API key permissions affect branding and customization.",
                onClick = onBrandingClick,
                showDivider = true
            )
            DemoListItem(
                title = "Custom channel cell",
                summary = "A richer custom channel row with status, translation, and subtitle badges.",
                onClick = onCustomChannelClick,
                showDivider = true
            )
            DemoListItem(
                title = "Localization and accessibility",
                summary = "The strings and labels needed for a polished custom integration.",
                onClick = onLocalizationClick,
                showDivider = false
            )
        }
    }
}

@Composable
fun DemoCardSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit,
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (androidx.compose.foundation.isSystemInDarkTheme()) {
                Color(0xFF1C1C1E)
            } else {
                Color(0xFFE8E8ED)
            }
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )
            content()
        }
    }
}

@Composable
fun DemoWarningBanner(text: String) {
    Card(
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.errorContainer.copy(alpha = 0.5f)
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.Top
        ) {
            Icon(
                imageVector = Icons.Filled.Warning,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onErrorContainer
            )
            Text(
                text = text,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onErrorContainer
            )
        }
    }
}

/** A placeholder shown in a subtitle view while no channel is providing subtitles. */
@Composable
fun DemoSubtitleUnavailableHint() {
    Card(
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color.Gray.copy(alpha = 0.12f)
        )
    ) {
        Text(
            text = "Your channels need to provide subtitles to see them here.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp)
        )
    }
}

@Composable
fun DemoNotes(notes: List<String>) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        notes.forEach { note ->
            Text(
                text = note,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

data class DemoPickerOption<T>(
    val value: T,
    val label: String,
)

@Composable
fun <T> DemoPickerField(
    selectedLabel: String,
    options: List<DemoPickerOption<T>>,
    onOptionSelected: (T) -> Unit,
    modifier: Modifier = Modifier,
    label: String? = null,
    enabled: Boolean = true,
) {
    var expanded by remember { mutableStateOf(false) }

    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = it },
        modifier = modifier
    ) {
        OutlinedTextField(
            value = selectedLabel,
            onValueChange = {},
            readOnly = true,
            enabled = enabled,
            label = label?.let { { Text(it) } },
            trailingIcon = {
                ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
            },
            modifier = Modifier
                .menuAnchor(ExposedDropdownMenuAnchorType.PrimaryNotEditable, enabled)
                .fillMaxWidth()
        )

        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = {
                        Text(
                            text = option.label,
                            fontWeight = if (option.label == selectedLabel) {
                                FontWeight.Medium
                            } else {
                                FontWeight.Normal
                            }
                        )
                    },
                    onClick = {
                        expanded = false
                        onOptionSelected(option.value)
                    }
                )
            }
        }
    }
}

@Composable
fun DemoLabelValueRow(label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium
        )
    }
}

@Composable
private fun DemoListSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = title,
            modifier = Modifier.padding(start = 4.dp),
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Card(
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surfaceBright
            )
        ) {
            Column(content = content)
        }
    }
}

@Composable
private fun DemoListItem(
    title: String,
    summary: String,
    onClick: () -> Unit,
    showDivider: Boolean,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 20.dp, vertical = 18.dp)
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium
        )
        Text(
            text = summary,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
    if (showDivider) {
        HorizontalDivider(
            modifier = Modifier.padding(horizontal = 20.dp),
            color = MaterialTheme.colorScheme.outlineVariant
        )
    }
}

@Composable
fun DemoApiKeyMenu(
    selectedPreset: DemoApiKeyPreset,
    onPresetSelected: (DemoApiKeyPreset) -> Unit,
    customCredentials: DemoCredentials?,
    onCustomCredentialsEntered: (DemoCredentials) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }
    var showEditor by remember { mutableStateOf(false) }

    Box {
        TextButton(onClick = { expanded = true }) {
            Text("API key")
            Icon(
                imageVector = Icons.Filled.KeyboardArrowDown,
                contentDescription = null
            )
        }

        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            DemoFixture.apiKeyPresets.forEach { preset ->
                DropdownMenuItem(
                    text = {
                        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text(
                                text = if (preset == selectedPreset) "${preset.title} ✓" else preset.title,
                                style = MaterialTheme.typography.bodyMedium
                            )
                            Text(
                                text = preset.summary,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    },
                    onClick = {
                        expanded = false
                        onPresetSelected(preset)
                    }
                )
            }

            HorizontalDivider()

            DropdownMenuItem(
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                        Text(
                            text = if (selectedPreset.isCustom) "Use your own event ✓" else "Use your own event",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = customCredentials
                                ?.let { "Join code ${it.joinCode} · tap to edit." }
                                ?: "Enter your own join code and API key.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                },
                onClick = {
                    expanded = false
                    showEditor = true
                }
            )
        }
    }

    if (showEditor) {
        DemoCustomCredentialsDialog(
            credentials = customCredentials,
            onUse = { credentials ->
                showEditor = false
                onCustomCredentialsEntered(credentials)
            },
            onDismiss = { showEditor = false }
        )
    }
}

/**
 * Modal editor for the "Use your own event" credentials. Lets a tester join their
 * own LiveVoice event with their own join code + API key (and optional password)
 * without rebuilding the sample.
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

    val canUse = joinCode.trim().isNotEmpty() && apiKey.trim().isNotEmpty()

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Use your own event") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(
                    text = "Enter the join code and API key for your own LiveVoice event. The password is only needed for password-protected events.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                OutlinedTextField(
                    value = joinCode,
                    onValueChange = { joinCode = it },
                    label = { Text("Join code") },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.fillMaxWidth()
                )
                OutlinedTextField(
                    value = apiKey,
                    onValueChange = { apiKey = it },
                    label = { Text("API key") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Password (optional)") },
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            TextButton(
                enabled = canUse,
                onClick = {
                    onUse(
                        DemoCredentials(
                            joinCode = joinCode.trim(),
                            password = password,
                            apiKey = apiKey.trim()
                        )
                    )
                }
            ) {
                Text("Use")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
