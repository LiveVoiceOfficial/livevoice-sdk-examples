import SwiftUI
import LiveVoiceSDK

struct DefaultParticipantInterfaceScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared

    private var hasSubtitles: Bool { !liveVoice.availableSubtitles.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DemoScreenHeader(
                    title: "Default participant interface",
                    summary: "The simplest LiveVoice integration. The default view manages channels and audio; tap a channel's subtitle button and the fragments stream into your own subtitle view."
                )

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
                        LiveVoiceView()
                    }
                }

                DemoCardSection(title: "Your subtitle view") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tap a channel's subtitle button above and its subtitles stream into this view, which your app provides.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if hasSubtitles {
                            SubtitleFeedView(
                                fragments: liveVoice.subtitles.fragments,
                                placeholder: "Subtitles will appear here."
                            )
                            .transition(.opacity)
                        } else {
                            DemoSubtitleUnavailableHint()
                                .transition(.opacity)
                        }

                        Button("Stop subtitles") {
                            Task {
                                try? await liveVoice.stopSubtitles()
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(!liveVoice.subtitles.isEnabled)
                    }
                    .animation(.easeOut(duration: 0.35), value: hasSubtitles)
                }

                DemoCardSection(title: "Implementation notes") {
                    DemoNoteList(
                        notes: [
                            "Join the event once at app startup or before presenting the screen.",
                            "LiveVoiceView handles loading, errors, reconnecting, and branding for you.",
                            "Tapping a channel's subtitle button starts its subtitles; your app provides the view that renders the fragments.",
                            "Automatic subtitle mode follows whichever channel is currently playing.",
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
        DefaultParticipantInterfaceScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(
        joinCode: DemoFixture.joinCode,
        password: DemoFixture.password,
        apiKey: DemoFixture.apiKey
    )
}
