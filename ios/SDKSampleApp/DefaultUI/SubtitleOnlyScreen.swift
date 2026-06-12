import SwiftUI
import LiveVoiceSDK

struct SubtitleOnlyScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared
    @State private var selectedSubtitleID: Int64?

    private var hasSubtitles: Bool { !liveVoice.availableSubtitles.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DemoScreenHeader(
                    title: "Subtitle only",
                    summary: "Display subtitles on their own, without showing any of the event channels."
                )

                DemoCardSection(title: "Live sample") {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Subtitle view")
                            .font(.headline)

                        if hasSubtitles {
                            SubtitleFeedView(
                                fragments: liveVoice.subtitles.fragments,
                                placeholder: "Start subtitles to render fragments in this dedicated view."
                            )
                            .transition(.opacity)
                        } else {
                            DemoSubtitleUnavailableHint()
                                .transition(.opacity)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeOut(duration: 0.35), value: hasSubtitles)
                }

                DemoCardSection(title: "Controls") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Subtitle source", selection: $selectedSubtitleID) {
                            Text("Automatic").tag(Optional<Int64>.none)
                            ForEach(liveVoice.availableSubtitles, id: \.self) { subtitle in
                                let label = subtitle.language == nil
                                    ? "\(subtitle.name) transcript"
                                    : subtitle.name
                                Text(label).tag(Optional(subtitle.id))
                            }
                        }
                        .pickerStyle(.menu)

                        HStack {
                            Button("Start subtitles") {
                                Task {
                                    try? await liveVoice.startSubtitles(channelID: selectedSubtitleID)
                                }
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Stop subtitles") {
                                Task {
                                    try? await liveVoice.stopSubtitles()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                DemoCardSection(title: "Implementation notes") {
                    DemoNoteList(
                        notes: [
                            "Your app provides the subtitle view and chooses which subtitle stream to start or stop.",
                            "You can use this without rendering the LiveVoice channel list at all.",
                            "LiveVoice.shared.subtitles gives you the current subtitle fragments for your custom view.",
                        ]
                    )
                }

            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onReceive(liveVoice.$availableSubtitles) { subtitles in
            if selectedSubtitleID == nil {
                selectedSubtitleID = subtitles.first?.id
            }
        }
        .demoOnChange(of: selectedSubtitleID) { newValue in
            guard liveVoice.subtitles.isEnabled else { return }
            Task {
                try? await liveVoice.startSubtitles(channelID: newValue)
            }
        }
    }
}

#Preview {
    DemoStackNavigation {
        SubtitleOnlyScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(
        joinCode: DemoFixture.joinCode,
        password: DemoFixture.password,
        apiKey: DemoFixture.apiKey
    )
}
