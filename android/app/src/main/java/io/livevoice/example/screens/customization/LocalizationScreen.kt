// Localization and accessibility
//
// The SDK's default UI, its password prompt and every error's `message` come
// in English, German and Spanish, following the app's or device's language.
// Use `LiveVoice.translations` in your own parts to match the default UI's
// wording, its `accessibility…()` texts for accessibility labels, and show
// errors by their `message`.
//
// On Android `translations` is read from the application context's
// resources: it throws NOT_INITIALIZED before `initializeLiveVoice`, and an
// error's `message` is English until then. Each call reads the current
// configuration, so call it where you show the text rather than keeping
// the string.
//
// Uses: LiveVoice.translations, LiveVoiceException.message
// See also: Custom channel cell (uses the accessibility texts), Custom view
// states (parts that show these texts).

package io.livevoice.example.screens.customization

import androidx.compose.runtime.Composable
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.DemoTextRow
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceErrorCode
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceErrorDetail
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException

@Composable
fun LocalizationScreen() {
    val translations = LiveVoice.translations

    DemoScreen("Localization and accessibility", caption = "The SDK's own texts, in the app's language, for your custom parts.") {
        DemoSection("UI texts") {
            DemoTextRow("errorRetryNowButton()", translations.errorRetryNowButton())
            DemoTextRow("noChannels()", translations.noChannels())
            DemoTextRow("channelStatusOffline()", translations.channelStatusOffline())
            DemoTextRow("isAiChannelStatusMessage()", translations.isAiChannelStatusMessage())
            DemoTextRow("errorScreenRetrying()", translations.errorScreenRetrying())
            DemoTextRow("errorScreenRetryingIn(30)", translations.errorScreenRetryingIn(30))
            DemoTextRow("sdkNoMatchingChannels()", translations.sdkNoMatchingChannels())
            DemoTextRow("streamingByTitle()", translations.streamingByTitle())
        }
        // The SDK takes care of its default parts' accessibility; the parts
        // you provide are yours: give them labels and roles, and reflect
        // the cell's `isEnabled` and the channel's `playingState`.
        DemoSection("Accessibility labels") {
            DemoTextRow("accessibilityChannelPlay()", translations.accessibilityChannelPlay())
            DemoTextRow("accessibilityChannelStop()", translations.accessibilityChannelStop())
            DemoTextRow("accessibilityChannelStatusMuted()", translations.accessibilityChannelStatusMuted())
        }
        // Show `message` to the listener, and decide by `code`, never by the text.
        DemoSection("Error messages") {
            DemoTextRow("CHANNEL_OFFLINE", LiveVoiceException(LiveVoiceErrorCode.CHANNEL_OFFLINE).message)
            DemoTextRow("EVENT_INACTIVE", LiveVoiceException(LiveVoiceErrorCode.EVENT_INACTIVE).message)
            DemoTextRow("EVENT_NOT_FOUND", LiveVoiceException(LiveVoiceErrorCode.EVENT_NOT_FOUND).message)
            DemoTextRow("LISTENER_LIMIT_REACHED", LiveVoiceException(LiveVoiceErrorCode.LISTENER_LIMIT_REACHED).message)
            DemoTextRow("NO_NETWORK", LiveVoiceException(LiveVoiceErrorCode.NO_NETWORK).message)
            DemoTextRow(
                "NETWORK_FAILED, HTTP 500",
                LiveVoiceException(LiveVoiceErrorCode.NETWORK_FAILED, LiveVoiceErrorDetail(httpStatus = 500)).message,
            )
            DemoTextRow("WRONG_PASSWORD", LiveVoiceException(LiveVoiceErrorCode.WRONG_PASSWORD).message)
            // Errors from a mistake in your code carry a generic text; the
            // SDK log explains them (see Diagnostics log).
            DemoTextRow("API_KEY_INVALID", LiveVoiceException(LiveVoiceErrorCode.API_KEY_INVALID).message)
            DemoTextRow("GENERIC", LiveVoiceException(LiveVoiceErrorCode.GENERIC).message)
        }
    }
}
