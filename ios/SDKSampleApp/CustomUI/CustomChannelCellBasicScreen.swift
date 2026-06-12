import SwiftUI
import LiveVoiceSDK

struct CustomChannelCellBasicScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DemoScreenHeader(
                    title: "Custom channel cell",
                    summary: "Replace the built-in channel row with your own SwiftUI view while keeping the LiveVoice session logic."
                )

                DemoCustomUiWarning()

                DemoCardSection(title: "Live sample") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Keep audio output reachable right above the list, so playback is never silent.
                        HStack {
                            Text("Audio output")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            CompactAudioOutputPicker()
                        }

                        // Provide a custom cell closure to replace the standard channel rows.
                        LiveVoiceView { state in
                            switch state {
                            case .loading:
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 24)
                            case let .ready(channel, isLast, onTap):
                                DetailedCustomChannelRow(channel: channel, isLast: isLast, onTap: onTap)
                            case let .reconnecting(reconnectState):
                                CustomReconnectCard(state: reconnectState)
                            case let .error(error, retry):
                                CustomErrorCard(error: error, retry: retry)
                            case .noMatchingChannels:
                                Text(LiveVoiceLocalization.sdk_no_matching_channels)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 24)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }

                DemoCardSection(title: "Implementation notes") {
                    DemoNoteList(
                        notes: [
                            "LiveVoice passes each channel and its tap handler into your custom row so you can draw every cell with your own SwiftUI view.",
                            "The channel's Booleans are surfaced — isOnline as the status dot, the rest as badges (solid when true, faint when false) — so you can see which values you can read even when a feature doesn't apply to your own design.",
                            "The row is tappable — and its play control active — only when the channel can be started (online and with audio); otherwise the cell is inert.",
                        ]
                    )
                }

            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    DemoStackNavigation {
        CustomChannelCellBasicScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(
        joinCode: DemoFixture.joinCode,
        password: DemoFixture.password,
        apiKey: DemoFixture.apiKey
    )
}
