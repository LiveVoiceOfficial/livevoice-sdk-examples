// Custom channel cell
//
// `channelCell` draws each channel with your own view. The cell gets a
// LiveVoiceChannelCell: the channel, whether it is the last one, whether its
// action may be used now (`isEnabled`), and the action, `togglePlayback()`.
// The SDK keeps the session, playback and reconnection. Both cells read
// out with the SDK's accessibility texts (`LiveVoiceLocalization.accessibility…`).
//
// Needs: an API key that permits custom UI.
// Uses: LiveVoiceView.channelCell(_:), LiveVoiceChannelCell, LiveVoiceChannel
// See also: Custom view states, Localization and accessibility (the SDK's texts
// for your cells).
// Docs: LiveVoiceSDK documentation › Custom Channel Cells

import SwiftUI
import LiveVoiceSDK

struct CustomChannelCellScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared

    var body: some View {
        DemoScreen("Custom channel cell", caption: "Draw each channel with your own view.") {
            DemoRequirement(.customUI, isMet: liveVoice.customUiAllowed)
            DemoSection("Simple cell") {
                LiveVoiceView()
                    .channelCell { cell in
                        ChannelCell(cell: cell)
                    }
            }
            DemoSection("Detailed cell") {
                LiveVoiceView()
                    .channelCell { cell in
                        DetailedChannelCell(cell: cell)
                    }
            }
        }
    }
}

/// A channel row of your own: the name, a status line and a play button.
/// Cells are laid out flush to the view's edges, so the cell sets its own
/// padding and divider.
private struct ChannelCell: View {
    let cell: LiveVoiceChannelCell
    @State private var failure: LiveVoiceError?

    var body: some View {
        VStack(spacing: 0) {
            Button {
                Task { await togglePlayback() }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cell.channel.name)
                            .font(.headline)
                        Text(failure?.message ?? status)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    PlaybackIcon(state: cell.channel.playingState)
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // `false` while the channel is offline, has no audio, or the
            // connection recovers: draw the cell as unavailable then.
            .disabled(!cell.isEnabled)
            .accessibilityLabel(cell.channel.name)
            .accessibilityValue(accessibilityStatus)
            .accessibilityHint(accessibilityHint)

            if !cell.isLast {
                Divider()
            }
        }
    }

    private var status: String {
        let channel = cell.channel
        if !channel.isOnline {
            return "Offline"
        }
        // The SDK plays no video: a channel with video and audio plays its
        // audio, one with only video cannot be played (`hasAudio` is false).
        if !channel.hasAudio {
            return channel.hasVideo ? "Video only" : "No audio"
        }
        if let translation = channel.aiTranslationInfo {
            return "AI translation, \(translation.targetLanguage)"
        }
        return channel.hasSubtitles ? "With subtitles" : "Ready"
    }

    /// What VoiceOver reads after the name: a failed tap's message, as shown,
    /// or the playing state.
    private var accessibilityStatus: String {
        if let failure { return failure.message }
        let playing: String
        switch cell.channel.playingState {
        case .playing: playing = "Playing"
        case .transitioning: playing = "Connecting"
        case .stopped: playing = "Stopped"
        @unknown default: playing = ""
        }
        return cell.channel.isOnline ? playing : "Offline, \(playing)"
    }

    /// The SDK's localized text for the cell's action.
    private var accessibilityHint: String {
        switch cell.channel.playingState {
        case .playing, .transitioning: LiveVoiceLocalization.accessibilityChannelStop
        case .stopped: LiveVoiceLocalization.accessibilityChannelPlay
        @unknown default: LiveVoiceLocalization.accessibilityChannelPlay
        }
    }

    /// Starts the channel if it is stopped and stops it if it plays, decided
    /// when it runs. Returns once the channel plays or has stopped.
    private func togglePlayback() async {
        failure = nil
        do throws(LiveVoiceError) {
            try await cell.togglePlayback()
        } catch {
            failure = error
        }
    }
}

/// A richer row that shows what you can read from `LiveVoiceChannel`: the
/// online dot, every Boolean as a tag (faint when false, so all of them stay
/// visible even where a feature doesn't apply), the AI translation, the
/// channels that translate this one, and the playing state. Each channel is
/// a card of its own.
private struct DetailedChannelCell: View {
    let cell: LiveVoiceChannelCell
    // The channel publishes its changes, such as a speaker going online.
    @ObservedObject private var channel: LiveVoiceChannel
    @State private var failure: LiveVoiceError?

    init(cell: LiveVoiceChannelCell) {
        self.cell = cell
        self.channel = cell.channel
    }

    var body: some View {
        Button {
            Task { await togglePlayback() }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(channel.isOnline ? Color.green : Color.secondary)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)
                VStack(alignment: .leading, spacing: 6) {
                    Text(channel.name)
                        .font(.headline)
                    Text(failure?.message ?? status)
                        .font(.caption)
                        .foregroundStyle(failure == nil ? Color.secondary : Color.red)
                    HStack(spacing: 6) {
                        DemoTag("Audio", isOn: channel.hasAudio)
                        // The SDK plays no video; of a channel with both it plays the audio.
                        DemoTag("Video", isOn: channel.hasVideo)
                        DemoTag("Subtitles", isOn: channel.hasSubtitles)
                        DemoTag("Muted", isOn: channel.isAudioMuted)
                    }
                    HStack(spacing: 6) {
                        DemoTag("Password", isOn: channel.isPasswordProtected)
                        DemoTag("AI voice", isOn: channel.isAISpeaker)
                        DemoTag("On demand", isOn: channel.isOnDemand)
                    }
                    if !channel.dependentChannels.isEmpty {
                        // Channels that translate this one, such as an AI voice.
                        Text("Translations: " + channel.dependentChannels.map(\.name).joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                PlaybackIcon(state: channel.playingState)
                    .foregroundStyle(cell.isEnabled ? Color.accentColor : Color.secondary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.accentColor.opacity(cell.isEnabled ? 0.12 : 0.05)))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.tertiarySystemBackground)))
            .contentShape(Rectangle())
            // Read as one element, so the faint tags aren't read out.
            .accessibilityElement(children: .ignore)
        }
        .buttonStyle(.plain)
        // `false` while the channel is offline, has no audio, or the
        // connection recovers: the cell looks and acts unavailable then.
        .disabled(!cell.isEnabled)
        .accessibilityLabel(channel.name)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(accessibilityHint)
        .padding(.bottom, cell.isLast ? 0 : 12)
    }

    private var status: String {
        if !channel.isOnline { return "Inactive" }
        if let translation = channel.aiTranslationInfo {
            return "AI translation into \(translation.targetLanguage)"
        }
        switch channel.playingState {
        case .playing: return "Currently playing"
        case .transitioning: return "Connecting…"
        case .stopped: return channel.hasAudio ? "Ready to start" : "Nothing to play"
        @unknown default: return ""
        }
    }

    /// The status line and only the properties that are true, the way the
    /// tags show them at full contrast.
    private var accessibilityValue: String {
        let properties: [(isOn: Bool, text: String)] = [
            (channel.hasAudio, "Audio"),
            (channel.hasVideo, "Video"),
            (channel.hasSubtitles, "Subtitles"),
            // The SDK's localized text for a muted channel.
            (channel.isAudioMuted, LiveVoiceLocalization.accessibilityChannelStatusMuted),
            (channel.isPasswordProtected, "Password"),
            (channel.isAISpeaker, "AI voice"),
            (channel.isOnDemand, "On demand"),
        ]
        let line = failure?.message ?? status
        return ([line] + properties.filter(\.isOn).map(\.text)).joined(separator: ", ")
    }

    /// The SDK's localized text for the cell's action.
    private var accessibilityHint: String {
        switch channel.playingState {
        case .playing, .transitioning: LiveVoiceLocalization.accessibilityChannelStop
        case .stopped: LiveVoiceLocalization.accessibilityChannelPlay
        @unknown default: LiveVoiceLocalization.accessibilityChannelPlay
        }
    }

    private func togglePlayback() async {
        failure = nil
        do throws(LiveVoiceError) {
            try await cell.togglePlayback()
        } catch {
            failure = error
        }
    }
}

/// Play, connecting or stop, for a channel's `playingState`.
private struct PlaybackIcon: View {
    let state: LiveVoicePlayingState

    var body: some View {
        switch state {
        case .stopped:
            Image(systemName: "play.fill")
        case .transitioning:
            ProgressView()
        case .playing:
            Image(systemName: "stop.fill")
        @unknown default:
            Image(systemName: "play.fill")
        }
    }
}

#Preview {
    DemoStackNavigation {
        CustomChannelCellScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
