// Localization and accessibility
//
// The SDK's default UI, its password prompt and every error's `message` come
// in English, German and Spanish, following the app's or device's language.
// Use `LiveVoiceLocalization` in your own parts to match the default UI's
// wording, its `a11y_` texts for accessibility labels, and show errors by
// their `message`.
//
// Uses: LiveVoiceLocalization, LiveVoiceError.message
// See also: Custom channel cell (uses the accessibility texts), Custom view
// states (parts that show these texts).
// Docs: LiveVoiceSDK documentation › Localization and Accessibility

import SwiftUI
import LiveVoiceSDK

struct LocalizationScreen: View {
    var body: some View {
        DemoScreen("Localization and accessibility", caption: "The SDK's own texts, in the app's language, for your custom parts.") {
            DemoSection("UI texts") {
                DemoTextRow("errorRetryNowButton", LiveVoiceLocalization.errorRetryNowButton)
                DemoTextRow("noChannels", LiveVoiceLocalization.noChannels)
                DemoTextRow("channelStatusOffline", LiveVoiceLocalization.channelStatusOffline)
                DemoTextRow("isAiChannelStatusMessage", LiveVoiceLocalization.isAiChannelStatusMessage)
                DemoTextRow("errorScreenRetrying", LiveVoiceLocalization.errorScreenRetrying)
                DemoTextRow("errorScreenRetryingIn(30)", LiveVoiceLocalization.errorScreenRetryingIn(30))
                DemoTextRow("sdkNoMatchingChannels", LiveVoiceLocalization.sdkNoMatchingChannels)
                DemoTextRow("streamingByTitle", LiveVoiceLocalization.streamingByTitle)
            }
            // The SDK takes care of its default parts' accessibility; the parts
            // you provide are yours: give them labels and traits, and reflect
            // the cell's `isEnabled` and the channel's `playingState`.
            DemoSection("Accessibility labels") {
                DemoTextRow("accessibilityChannelPlay", LiveVoiceLocalization.accessibilityChannelPlay)
                DemoTextRow("accessibilityChannelStop", LiveVoiceLocalization.accessibilityChannelStop)
                DemoTextRow("accessibilityChannelStatusMuted", LiveVoiceLocalization.accessibilityChannelStatusMuted)
            }
            // Show `message` to the listener, and decide by `code`, never by the text.
            DemoSection("Error messages") {
                DemoTextRow(".channelOffline", LiveVoiceError(.channelOffline).message)
                DemoTextRow(".eventInactive", LiveVoiceError(.eventInactive).message)
                DemoTextRow(".eventNotFound", LiveVoiceError(.eventNotFound).message)
                DemoTextRow(".listenerLimitReached", LiveVoiceError(.listenerLimitReached).message)
                DemoTextRow(".noNetwork", LiveVoiceError(.noNetwork).message)
                DemoTextRow(".networkFailed, HTTP 500", LiveVoiceError(.networkFailed, detail: .init(httpStatus: 500)).message)
                DemoTextRow(".wrongPassword", LiveVoiceError(.wrongPassword).message)
                // Errors from a mistake in your code carry a generic text; the
                // SDK log explains them (see Diagnostics log).
                DemoTextRow(".apiKeyInvalid", LiveVoiceError(.apiKeyInvalid).message)
                DemoTextRow(".generic", LiveVoiceError(.generic).message)
            }
        }
    }
}

#Preview {
    DemoStackNavigation {
        LocalizationScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
