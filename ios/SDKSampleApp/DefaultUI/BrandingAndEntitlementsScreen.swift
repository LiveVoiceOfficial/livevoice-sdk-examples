import SwiftUI
import LiveVoiceSDK

struct BrandingAndEntitlementsScreen: View {
    @EnvironmentObject private var demoSession: DemoSession
    @ObservedObject private var liveVoice: LiveVoice = .shared
    @State private var primaryChannelID: Int64?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DemoScreenHeader(
                    title: "Branding and entitlements",
                    summary: "Switch the preset API key from the toolbar to inspect the real branding and custom UI permissions for this demo event."
                )

                DemoCardSection(title: "Live sample") {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Standard view")
                                .font(.subheadline.weight(.medium))

                            LiveVoiceView(filter: primaryChannelFilter)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom row")
                                .font(.subheadline.weight(.medium))

                            LiveVoiceView(filter: primaryChannelFilter) { state in
                                switch state {
                                case .loading:
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 24)
                                case let .ready(channel, isLast, onTap):
                                    BasicCustomChannelRow(channel: channel, isLast: isLast, onTap: onTap)
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
                }

                DemoCardSection(title: "Current features") {
                    VStack(alignment: .leading, spacing: 12) {
                        entitlementRow("Selected preset", value: demoSession.selectedPreset.title)
                        entitlementRow(
                            "Branding",
                            value: liveVoice.hideBranding ? "Hidden" : "Visible"
                        )
                        entitlementRow(
                            "Custom UI",
                            value: liveVoice.customUiAllowed ? "Allowed" : "Not allowed"
                        )
                    }
                }

                DemoCardSection(title: "Implementation notes") {
                    DemoNoteList(
                        notes: [
                            "Both samples above show only the event's first channel.",
                            "Switch the API key preset from the toolbar to compare branding and custom UI entitlements for that same channel.",
                        ]
                    )
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onReceive(liveVoice.$hideBranding) { _ in
            primaryChannelID = nil
        }
    }

    @ViewBuilder
    private func entitlementRow(_ label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func primaryChannelFilter(_ channel: LiveVoiceChannel) -> Bool {
        if let primaryChannelID {
            return channel.id == primaryChannelID
        }

        DispatchQueue.main.async {
            if self.primaryChannelID == nil {
                self.primaryChannelID = channel.id
            }
        }

        return true
    }
}

#Preview {
    DemoStackNavigation {
        BrandingAndEntitlementsScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(
        joinCode: DemoFixture.joinCode,
        password: DemoFixture.password,
        apiKey: DemoFixture.apiKey
    )
}
