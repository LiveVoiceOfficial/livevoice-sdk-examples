import SwiftUI
import LiveVoiceSDK

struct LocalizationAndAccessibilityScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DemoScreenHeader(
                    title: "Localization and accessibility",
                    summary: "The SDK ships reusable strings and accessibility labels in English, German, and Spanish. They follow the app or device language — reuse them in your custom UI."
                )

                DemoCardSection(title: "Strings") {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(localizedRows, id: \.0) { name, value in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(name)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                                Text(value)
                                    .font(.subheadline)
                            }
                        }
                    }
                }

                DemoCardSection(title: "Implementation notes") {
                    DemoNoteList(
                        notes: [
                            "Reuse SDK-provided strings and accessibility labels in your custom UI instead of writing separate copy.",
                            "Access them through LiveVoiceLocalization. They follow the app or device language; the SDK has no runtime language switch.",
                        ]
                    )
                }

            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var localizedRows: [(String, String)] {
        [
            ("action_retry_now", LiveVoiceLocalization.action_retry_now),
            ("channel_status_offline", LiveVoiceLocalization.channel_status_offline),
            ("error_screen_retrying", LiveVoiceLocalization.error_screen_retrying),
            ("error_screen_retrying_in(12)", LiveVoiceLocalization.error_screen_retrying_in(12)),
            ("sdk_error_generic", LiveVoiceLocalization.sdk_error_generic),
            ("sdk_error_inactive", LiveVoiceLocalization.sdk_error_inactive),
            ("sdk_error_invalid_api_key", LiveVoiceLocalization.sdk_error_invalid_api_key),
            ("sdk_error_listener_limit_reached", LiveVoiceLocalization.sdk_error_listener_limit_reached),
            ("sdk_error_no_network", LiveVoiceLocalization.sdk_error_no_network),
            ("sdk_error_not_found", LiveVoiceLocalization.sdk_error_not_found),
            ("sdk_error_request_failed(\"500\")", LiveVoiceLocalization.sdk_error_request_failed("500")),
            ("sdk_error_wrong_password", LiveVoiceLocalization.sdk_error_wrong_password),
            ("sdk_no_matching_channels", LiveVoiceLocalization.sdk_no_matching_channels),
            ("streaming_by_title", LiveVoiceLocalization.streaming_by_title),
            ("a11y_channel_play", LiveVoiceLocalization.a11y_channel_play),
            ("a11y_channel_status_muted", LiveVoiceLocalization.a11y_channel_status_muted),
            ("a11y_channel_stop", LiveVoiceLocalization.a11y_channel_stop),
            ("channel_list_empty", LiveVoiceLocalization.channel_list_empty),
            ("channel_status_is_ai", LiveVoiceLocalization.channel_status_is_ai),
        ]
    }
}

#Preview {
    DemoStackNavigation {
        LocalizationAndAccessibilityScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(
        joinCode: DemoFixture.joinCode,
        password: DemoFixture.password,
        apiKey: DemoFixture.apiKey
    )
}
