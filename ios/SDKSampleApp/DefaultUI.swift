import SwiftUI
import LiveVoiceSDK

struct DefaultUI: View {
    // Use the shared LiveVoice singleton to access the audio output
    @ObservedObject private var liveVoice: LiveVoice = .shared
    
    @State private var availableLanguages: Set<String?> = []
    @State private var subtitles: String = ""
    @State private var subtitleLanguage: String? = nil
    
    var body: some View {
        VStack(spacing: 10) {
            Text("You can create your own output toggle")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("audio_picker", selection: $liveVoice.audioOutput) {
                Image(systemName: "headphones")
                    .tag(AudioOutput.headphones)
                Image(systemName: "speaker.wave.2.fill")
                    .tag(AudioOutput.speaker)
            }
            .pickerStyle(.segmented)
        }
        .padding()
        
        List {
            Section("This is the default list view") {
                LiveVoiceView()
            }
            
            Section("Display only a single specific channel") {
                LiveVoiceView { $0.id == 3308 }
            }
            
            Section("If there are no matching channels") {
                LiveVoiceView { $0.id == 1 }
            }
        }
        Divider()
        HStack {
            Button(liveVoice.subtitles.isEnabled ? "Disable Subtitles" : "Enable Subtitles") {
                Task {
                    if liveVoice.subtitles.isEnabled {
                        try await liveVoice.stopSubtitles()
                    } else {
                        // Always just display the currently playing channel's subtitles
                        try await liveVoice.startSubtitles(
                            channelID: nil,
                            languageOption: subtitleLanguage.map { .translated(language: $0) } ?? .transcript
                        )
                    }
                }
            }
            Picker("Language", selection: $subtitleLanguage) {
                // Include a `nil` value to allow for automatically using the base language of the picked channel
                Text("Automatic").tag(Optional<String>.none)
                // The combined list of available languages for simplicity
                ForEach(availableLanguages.sorted(), id: \.self) { language in
                    if let language {
                        Text(Locale.current.localizedString(forLanguageCode: language) ?? language).tag(language)
                    } else {
                        Text("Original Transcript").tag("transcript")
                    }
                }
            }
            .pickerStyle(.menu)
        }
        .font(.subheadline.bold())
        // Whenever the selected language changes we kick off a request to start subtitles
        .onChange(of: subtitleLanguage) { oldValue, newValue in
            guard oldValue != newValue else { return }
            Task {
                if liveVoice.subtitles.isEnabled {
                    // Always just display the currently playing channel's subtitles
                    try await liveVoice.startSubtitles(
                        channelID: nil,
                        languageOption: newValue.map { .translated(language: $0) } ?? .transcript
                    )
                }
            }
        }
        // Populate the list of available languages
        //
        // For simplicity, we don't care about some languages not being available in some channels
        .onReceive(liveVoice.$availableSubtitles) { subs in
            self.availableLanguages = subs.map { $0.value }.reduce(Set<String?>()) { $0.union($1) }
        }
        if let strings = liveVoice.subtitles.fragments {
            ScrollView {
                // Since the fragments are not necessarily unique, we use their index in the array as identity
                ForEach(Array(zip(strings, strings.indices)), id: \.self.1) {
                    Text($0.0)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .defaultScrollAnchor(.bottom)
            .frame(height: 200)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

extension Set where Element == Optional<String> {
    func sorted() -> [String?] {
        if self.contains(nil) {
            return [nil] + self.compactMap { $0 }.sorted()
        } else {
            return self.compactMap { $0 }.sorted()
        }
    }
}

#Preview {
    DefaultUI()
        .initialized(joinCode: "123456", apiKey: "s09WEG5y3caQ6R2PDaG4i8R1aTooTd")
}
