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

                Section("Getting started") {
                    NavigationLink {
                        DefaultInterfaceScreen()
                    } label: {
                        DemoListRow(
                            title: "Default interface",
                            summary: "The smallest integration: the event's channels, ready to play."
                        )
                    }

                    NavigationLink {
                        JoiningEventScreen()
                    } label: {
                        DemoListRow(
                            title: "Joining an event",
                            summary: "Join, reconnect and leave, and follow the connection."
                        )
                    }
                }

                Section("Channels") {
                    NavigationLink {
                        FilteringChannelsScreen()
                    } label: {
                        DemoListRow(
                            title: "Filtering channels",
                            summary: "Show only the channels you want."
                        )
                    }

                    NavigationLink {
                        CustomChannelCellScreen()
                    } label: {
                        DemoListRow(
                            title: "Custom channel cell",
                            summary: "Draw each channel with your own view."
                        )
                    }

                    NavigationLink {
                        CustomViewStatesScreen()
                    } label: {
                        DemoListRow(
                            title: "Custom view states",
                            summary: "Your own loading, reconnecting, error and empty views."
                        )
                    }
                }

                Section("Subtitles") {
                    NavigationLink {
                        SubtitlesScreen()
                    } label: {
                        DemoListRow(
                            title: "Subtitles",
                            summary: "Show a channel's live subtitles in your own view."
                        )
                    }
                }

                Section("Audio and system") {
                    NavigationLink {
                        AudioOutputScreen()
                    } label: {
                        DemoListRow(
                            title: "Audio output",
                            summary: "Prefer the loudspeaker, or let the system choose."
                        )
                    }

                    NavigationLink {
                        LockScreenScreen()
                    } label: {
                        DemoListRow(
                            title: "Lock screen and audio sharing",
                            summary: "Share the audio with other apps, and show the channel on the Lock Screen."
                        )
                    }
                }

                Section("Event features") {
                    NavigationLink {
                        PasswordsScreen()
                    } label: {
                        DemoListRow(
                            title: "Password-protected channels",
                            summary: "Ask for channel passwords with your own UI, and keep them.",
                            needsOwnEvent: true
                        )
                    }

                    NavigationLink {
                        LanguageRequestsScreen()
                    } label: {
                        DemoListRow(
                            title: "Language requests",
                            summary: "Ask the event for a language it doesn't offer yet.",
                            needsOwnEvent: true
                        )
                    }

                    NavigationLink {
                        LinkedEventsScreen()
                    } label: {
                        DemoListRow(
                            title: "Linked events",
                            summary: "Switch to an event linked to this one.",
                            needsOwnEvent: true
                        )
                    }
                }

                Section("Customization and diagnostics") {
                    NavigationLink {
                        BrandingScreen()
                    } label: {
                        DemoListRow(
                            title: "Branding and entitlements",
                            summary: "See what the joined event's API key permits."
                        )
                    }

                    NavigationLink {
                        LocalizationScreen()
                    } label: {
                        DemoListRow(
                            title: "Localization and accessibility",
                            summary: "The SDK's own texts, in the app's language, for your custom parts."
                        )
                    }

                    NavigationLink {
                        DiagnosticsScreen()
                    } label: {
                        DemoListRow(
                            title: "Diagnostics log",
                            summary: "Read what the SDK did, and why a call failed."
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
