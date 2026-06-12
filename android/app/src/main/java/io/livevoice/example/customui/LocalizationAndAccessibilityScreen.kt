package io.livevoice.example.customui

import android.content.Context
import android.content.res.Configuration
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.platform.LocalContext
import io.livevoice.sdk.android.R as LiveVoiceR
import io.livevoice.example.shared.DemoCardSection
import io.livevoice.example.shared.DemoNotes
import io.livevoice.example.shared.DemoPage
import io.livevoice.example.shared.DemoPickerField
import io.livevoice.example.shared.DemoPickerOption
import java.util.Locale

@Composable
fun LocalizationAndAccessibilityScreen(paddingValues: PaddingValues) {
    var selectedLanguageCode by rememberSaveable { mutableStateOf(DemoLocalizationLanguage.English.code) }
    val selectedLanguage = DemoLocalizationLanguage.entries.first { it.code == selectedLanguageCode }
    val appContext = LocalContext.current.applicationContext
    val preview = remember(appContext, selectedLanguage) {
        DemoSdkLocalizationPreview(appContext, selectedLanguage)
    }

    DemoPage(
        paddingValues = paddingValues,
        summary = "The SDK ships reusable strings and accessibility labels in English, German, and Spanish. They follow the app or device language — reuse them in your custom UI."
    ) {
        DemoCardSection(title = "Strings") {
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                LanguagePicker(
                    selectedLanguage = selectedLanguage,
                    onSelectedLanguage = { selectedLanguageCode = it.code }
                )

                localizedRows(preview).forEach { row ->
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(
                            text = row.key,
                            style = MaterialTheme.typography.labelSmall,
                            fontFamily = FontFamily.Monospace,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            text = row.value,
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
            }
        }

        DemoCardSection(title = "Implementation notes") {
            DemoNotes(
                listOf(
                    "Reuse SDK-provided strings and accessibility labels in your custom UI instead of writing separate copy.",
                    "The SDK does not expose a runtime language switch. The strings follow the app or device language.",
                    "This demo reads the SDK bundles directly so you can preview the shipped English, German, and Spanish translations."
                )
            )
        }
    }
}

@Composable
private fun LanguagePicker(
    selectedLanguage: DemoLocalizationLanguage,
    onSelectedLanguage: (DemoLocalizationLanguage) -> Unit,
) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        DemoPickerField(
            label = "Language",
            selectedLabel = selectedLanguage.title,
            options = DemoLocalizationLanguage.entries.map { language ->
                DemoPickerOption(language, language.title)
            },
            onOptionSelected = onSelectedLanguage
        )
    }
}

private fun localizedRows(preview: DemoSdkLocalizationPreview): List<DemoLocalizedRow> = listOf(
    DemoLocalizedRow("action_retry_now", preview.string(LiveVoiceR.string.action_retry_now)),
    DemoLocalizedRow("channel_status_offline", preview.string(LiveVoiceR.string.channel_status_offline)),
    DemoLocalizedRow("error_screen_retrying", preview.string(LiveVoiceR.string.error_screen_retrying)),
    DemoLocalizedRow("error_screen_retrying_in(12)", preview.string(LiveVoiceR.string.error_screen_retrying_in, 12)),
    DemoLocalizedRow("sdk_error_generic", preview.string(LiveVoiceR.string.sdk_error_generic)),
    DemoLocalizedRow("sdk_error_inactive", preview.string(LiveVoiceR.string.sdk_error_inactive)),
    DemoLocalizedRow("sdk_error_invalid_api_key", preview.string(LiveVoiceR.string.sdk_error_invalid_api_key)),
    DemoLocalizedRow("sdk_error_listener_limit_reached", preview.string(LiveVoiceR.string.sdk_error_listener_limit_reached)),
    DemoLocalizedRow("sdk_error_no_network", preview.string(LiveVoiceR.string.sdk_error_no_network)),
    DemoLocalizedRow("sdk_error_not_found", preview.string(LiveVoiceR.string.sdk_error_not_found)),
    DemoLocalizedRow("sdk_error_request_failed(\"500\")", preview.string(LiveVoiceR.string.sdk_error_request_failed, 500)),
    DemoLocalizedRow("sdk_error_wrong_password", preview.string(LiveVoiceR.string.sdk_error_wrong_password)),
    DemoLocalizedRow("sdk_no_matching_channels", preview.string(LiveVoiceR.string.sdk_no_matching_channels)),
    DemoLocalizedRow("streaming_by_title", preview.string(LiveVoiceR.string.streaming_by_title)),
    DemoLocalizedRow("a11y_channel_play", preview.string(LiveVoiceR.string.accessibility_channel_play)),
    DemoLocalizedRow("a11y_channel_status_muted", preview.string(LiveVoiceR.string.accessibility_channel_status_muted)),
    DemoLocalizedRow("a11y_channel_stop", preview.string(LiveVoiceR.string.accessibility_channel_stop)),
    DemoLocalizedRow("lobby_no_channels_configured", preview.string(LiveVoiceR.string.lobby_no_channels_configured)),
    DemoLocalizedRow("channel_status_is_ai", preview.string(LiveVoiceR.string.channel_status_is_ai)),
)

private data class DemoLocalizedRow(
    val key: String,
    val value: String,
)

private enum class DemoLocalizationLanguage(
    val code: String,
    val title: String,
) {
    English("en", "English"),
    German("de", "Deutsch"),
    Spanish("es", "Español"),
}

private class DemoSdkLocalizationPreview(
    context: Context,
    language: DemoLocalizationLanguage,
) {
    private val localizedContext: Context

    init {
        val configuration = Configuration(context.resources.configuration).apply {
            setLocale(Locale.forLanguageTag(language.code))
            setLayoutDirection(Locale.forLanguageTag(language.code))
        }
        localizedContext = context.createConfigurationContext(configuration)
    }

    fun string(resId: Int, vararg args: Any): String = localizedContext.getString(resId, *args)
}
