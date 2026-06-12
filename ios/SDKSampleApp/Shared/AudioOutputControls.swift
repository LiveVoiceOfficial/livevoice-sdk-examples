import SwiftUI
import LiveVoiceSDK

// Display helpers for the SDK's AudioOutput, shared by every output control below.
extension AudioOutput {
    var demoLabel: String {
        switch self {
        case .headphones: "Receiver"
        case .speaker: "Speaker"
        @unknown default: "Output"
        }
    }

    var demoSymbol: String {
        switch self {
        case .headphones: "headphones"
        case .speaker: "speaker.wave.2.fill"
        @unknown default: "speaker"
        }
    }
}

/// The "default" output control: an icon-only segmented picker, kept compact so it can sit above a
/// channel list without taking the full width. All variants bind to the same shared `audioOutput`.
struct CompactAudioOutputPicker: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared

    var body: some View {
        Picker("Audio output", selection: $liveVoice.audioOutput) {
            Image(systemName: AudioOutput.headphones.demoSymbol)
                .tag(AudioOutput.headphones)
            Image(systemName: AudioOutput.speaker.demoSymbol)
                .tag(AudioOutput.speaker)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .fixedSize()
        .accessibilityLabel("Audio output")
    }
}

/// A pop-up menu variant: a single button that opens a menu listing the outputs.
struct MenuAudioOutputPicker: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared

    var body: some View {
        Menu {
            Picker("Audio output", selection: $liveVoice.audioOutput) {
                Label(AudioOutput.headphones.demoLabel, systemImage: AudioOutput.headphones.demoSymbol)
                    .tag(AudioOutput.headphones)
                Label(AudioOutput.speaker.demoLabel, systemImage: AudioOutput.speaker.demoSymbol)
                    .tag(AudioOutput.speaker)
            }
        } label: {
            Label(liveVoice.audioOutput.demoLabel, systemImage: liveVoice.audioOutput.demoSymbol)
        }
        .buttonStyle(.bordered)
    }
}

/// A single button that toggles straight between the two outputs.
struct ToggleAudioOutputButton: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared

    var body: some View {
        Button {
            liveVoice.audioOutput = liveVoice.audioOutput == .speaker ? .headphones : .speaker
        } label: {
            Label(liveVoice.audioOutput.demoLabel, systemImage: liveVoice.audioOutput.demoSymbol)
        }
        .buttonStyle(.bordered)
    }
}
