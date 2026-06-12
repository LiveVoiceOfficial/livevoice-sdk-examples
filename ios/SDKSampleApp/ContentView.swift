import SwiftUI
import LiveVoiceSDK

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        DemoSplitNavigation {
            List {
                Section {
                    VStack(spacing: 12) {
                        VStack(spacing: 4) {
                            Image("logo")
                                .padding(.top, 24)

                            Text("SDK \(LiveVoice.shared.sdkVersion)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Text("A quick tour of LiveVoice SDK features.")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }

                Section("Default UI") {
                    NavigationLink {
                        DefaultParticipantInterfaceScreen()
                    } label: {
                        DemoListRow(
                            title: "Default participant interface",
                            summary: "The simplest integration, with subtitles in your own view."
                        )
                    }

                    NavigationLink {
                        FilteredChannelListScreen()
                    } label: {
                        DemoListRow(
                            title: "Filtered channel list",
                            summary: "Show only the channels you want — by property, an empty result, or a source channel with its AI subtitles."
                        )
                    }

                    NavigationLink {
                        AudioOutputPickerScreen()
                    } label: {
                        DemoListRow(
                            title: "Audio output picker",
                            summary: "Place the audio output picker wherever it fits in your app."
                        )
                    }

                    NavigationLink {
                        SubtitleOnlyScreen()
                    } label: {
                        DemoListRow(
                            title: "Subtitle only",
                            summary: "Show subtitles without displaying any of the event channels."
                        )
                    }
                }

                Section("Custom UI") {
                    NavigationLink {
                        BrandingAndEntitlementsScreen()
                    } label: {
                        DemoListRow(
                            title: "Branding and entitlements",
                            summary: "See how API key permissions affect branding and customization."
                        )
                    }

                    NavigationLink {
                        CustomChannelCellBasicScreen()
                    } label: {
                        DemoListRow(
                            title: "Custom channel cell",
                            summary: "A richer custom channel row with status, translation, and subtitle badges."
                        )
                    }

                    NavigationLink {
                        LocalizationAndAccessibilityScreen()
                    } label: {
                        DemoListRow(
                            title: "Localization and accessibility",
                            summary: "The strings and labels needed for a polished custom integration."
                        )
                    }
                }
            }
            .adaptiveSidebarListStyle(regular: horizontalSizeClass == .regular)
            .demoApiKeyToolbar()
        } detail: {
            Text("Select a demo from the sidebar.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .demoApiKeyPickerSheet()
    }
}

private extension View {
    @ViewBuilder
    func adaptiveSidebarListStyle(regular: Bool) -> some View {
        if regular {
            listStyle(.sidebar)
        } else {
            listStyle(.insetGrouped)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DemoSession.preview)
        .initialized(
            joinCode: DemoFixture.joinCode,
            password: DemoFixture.password,
            apiKey: DemoFixture.apiKey
        )
}
