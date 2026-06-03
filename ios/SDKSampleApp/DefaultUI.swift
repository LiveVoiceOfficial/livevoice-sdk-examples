import SwiftUI
import LiveVoiceSDK

struct DefaultUI: View {
    // Use the shared LiveVoice singleton to access the audio output
    @ObservedObject private var liveVoice: LiveVoice = .shared
    
    @State private var availableSubtitles: [String?: [LiveVoice.AvailableSubtitle]] = [:]
    @State private var subtitles: String = ""
    @State private var pickedSubtitle: Int64? = nil
    
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
                LiveVoiceView {
                    $0.id == 3308
                    || ($0.aiTranslationInfo?.sourceID == 3308 && $0.hasAudio)
                    && $0.dependentChannels.count(where: { $0.hasAudio }) > 0
                }
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
                        try await liveVoice.startSubtitles(channelID: pickedSubtitle)
                    }
                }
            }
            Picker("Language", selection: $pickedSubtitle) {
                // Include a `nil` value to allow for automatically picking the active channel
                Text("Automatic").tag(Optional<Int64>.none)
                // The combined list of available languages for simplicity
                ForEach(availableSubtitles.keys.sorted(by: { $0 ?? "" < $1 ?? "" }), id: \.self) { name in
                    if let name {
                        Section("Based on \(name)") {
                            ForEach(availableSubtitles[name] ?? [], id: \.self) { subtitle in
                                Text(subtitle.language != nil ? subtitle.name : "Original Transcript")
                                    .tag(subtitle.id)
                            }
                        }
                    } else {
                        ForEach(availableSubtitles[nil] ?? [], id: \.self) { subtitle in
                            Text(subtitle.language != nil ? subtitle.name : "Original Transcript \(subtitle.name)")
                                .tag(subtitle.id)
                        }
                    }
                }
            }
            .pickerStyle(.menu)
        }
        .font(.subheadline.bold())
        // Whenever the selected language changes we kick off a request to start subtitles
        .onChange(of: pickedSubtitle) { oldValue, newValue in
            guard oldValue != newValue else { return }
            Task {
                if liveVoice.subtitles.isEnabled {
                    // Always just display the currently playing channel's subtitles
                    try await liveVoice.startSubtitles(channelID: newValue)
                }
            }
        }
        // Populate the list of available languages
        .onReceive(liveVoice.$availableSubtitles) { availableSubtitles in
            var names: [Int64: String] = [:]
            for a in availableSubtitles {
                if names[a.id] ==  nil {
                    names[a.id] = a.name
                }
            }
            
            var mapped: [String?: [LiveVoice.AvailableSubtitle]] = [:]
            for a in availableSubtitles {
                if let parent = a.parent, let parentName = names[parent] {
                    mapped[parentName, default: []].append(a)
                } else if let name = names[a.id], a.parent == nil {
                    mapped[name, default: []].append(a)
                } else {
                    mapped[nil, default: []].append(a)
                }
            }
            
            self.availableSubtitles = mapped
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
