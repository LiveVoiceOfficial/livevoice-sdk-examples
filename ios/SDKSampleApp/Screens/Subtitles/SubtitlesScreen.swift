// Subtitles
//
// `startSubtitles` with no channel follows whatever channel plays; with a
// channel from `availableSubtitles` it shows that subtitle stream, playing
// or not. `subtitles` holds the state and its fragments for your own view,
// and `stopSubtitles` ends them. You don't need LiveVoiceView for subtitles.
//
// Uses: LiveVoice.availableSubtitles, startSubtitles(channelID:password:),
// stopSubtitles(), subtitles, LiveVoiceSubtitleState
// See also: Filtering channels (channels with subtitles), Password-protected
// channels (subtitles of a protected channel).
// Docs: LiveVoiceSDK documentation › Displaying Subtitles

import SwiftUI
import LiveVoiceSDK

struct SubtitlesScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared
    /// `nil` follows the playing channel.
    @State private var channelID: Int64?
    @State private var failure: LiveVoiceError?

    var body: some View {
        DemoScreen("Subtitles", caption: "Show a channel's live subtitles in your own view.", error: failure, showsSubtitles: true) {
            DemoSection("Subtitles") {
                SubtitleView()
            }
            DemoSection("Source") {
                // `nil` until known, `[]` when the event has none. A `nil`
                // language is the channel's original transcript.
                Picker("Subtitles", selection: $channelID) {
                    Text("Playing channel").tag(Int64?.none)
                    ForEach(liveVoice.availableSubtitles ?? [], id: \.channelID) { subtitle in
                        Text(subtitle.language == nil ? "\(subtitle.name) (original)" : subtitle.name)
                            .tag(Int64?.some(subtitle.channelID))
                    }
                }
                .pickerStyle(.menu)
                HStack {
                    Button("Start") { Task { await start() } }
                    Button("Stop") { Task { await stop() } }
                }
                .buttonStyle(.bordered)
            }
            DemoSection("Channels") {
                // Following subtitles show the channel playing here.
                LiveVoiceView()
            }
        }
    }

    /// One subtitle stream at a time: starting another replaces it, without
    /// a stop in between. Subtitles never start, stop or switch playback.
    private func start() async {
        failure = nil
        do throws(LiveVoiceError) {
            try await liveVoice.startSubtitles(channelID: channelID)
        } catch {
            failure = error
        }
    }

    private func stop() async {
        failure = nil
        do throws(LiveVoiceError) {
            try await liveVoice.stopSubtitles()
        } catch {
            failure = error
        }
    }
}

/// Your own subtitle view: the fragments of `LiveVoice.shared.subtitles` in a
/// fixed-height scroll view that shows the newest text.
///
/// It scrolls to the end on every change, also when the last fragment only
/// grows (the SDK appends an unfinished sentence to it) and also when you
/// scrolled up to read. A real app would usually follow only while the
/// reader is at the bottom.
private struct SubtitleView: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared

    var body: some View {
        switch liveVoice.subtitles {
        case let .automatic(fragments), let .specific(_, fragments):
            if fragments.isEmpty {
                Text("Waiting for the first words…")
                    .foregroundStyle(.secondary)
            } else {
                Feed(fragments: fragments)
            }
        case .disabled:
            Text("Start subtitles to see them here.")
                .foregroundStyle(.secondary)
        @unknown default:
            EmptyView()
        }
    }

    private struct Feed: View {
        let fragments: [String]

        var body: some View {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(fragments.enumerated()), id: \.offset) { _, fragment in
                            Text(fragment)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Color.clear
                            .frame(height: 1)
                            .id(Self.end)
                    }
                }
                .frame(height: 220)
                // `onChange(of:)`, on iOS 15 too.
                .demoOnChange(of: fragments) { _ in
                    // After the layout of the changed text, so the end is where it now is.
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(Self.end, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        proxy.scrollTo(Self.end, anchor: .bottom)
                    }
                }
            }
        }

        private static let end = "end"
    }
}

#Preview {
    DemoStackNavigation {
        SubtitlesScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
