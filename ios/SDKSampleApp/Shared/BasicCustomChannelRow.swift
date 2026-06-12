import SwiftUI
import LiveVoiceSDK

struct BasicCustomChannelRow: View {
    let channel: LiveVoiceChannel
    let isLast: Bool
    let onTap: @MainActor () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(channel.name)
                        .font(.headline)
                    Text(channelStatusText(channel))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: channel.playState == .playing ? "stop.fill" : "play.fill")
                    .font(.headline)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.accentColor.opacity(0.12))
                    )
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
            )
        }
        .buttonStyle(.plain)
        .padding(.bottom, isLast ? 0 : 12)
    }

    private func channelStatusText(_ channel: LiveVoiceChannel) -> String {
        if !channel.isOnline {
            return LiveVoiceLocalization.channel_status_offline
        }
        if let translation = channel.aiTranslationInfo {
            return "AI \(translation.targetLanguage)"
        }
        if channel.playState == .playing {
            return "Currently playing"
        }
        return "Ready to start"
    }
}

/// A richer custom channel row that surfaces the channel's Booleans — `isOnline` as the
/// status dot, the rest as badges (solid when `true`, faint when `false`) — so you can see
/// which values you can read even when a feature doesn't apply to your own design. The row is
/// tappable — and its play control active — only when the channel can be started (online and
/// with audio); otherwise both are disabled.
struct DetailedCustomChannelRow: View {
    let channel: LiveVoiceChannel
    let isLast: Bool
    let onTap: @MainActor () -> Void

    var body: some View {
        Group {
            // Tappable only when the channel can actually be started — online and with audio.
            // Otherwise the whole row (and its play control) is inert, with no tap highlight.
            if canPlay {
                Button(action: onTap) { content }
                    .buttonStyle(.plain)
            } else {
                content
            }
        }
        .padding(.bottom, isLast ? 0 : 12)
    }

    /// The channel can be started only when it is online and has audio.
    private var canPlay: Bool { channel.isOnline && channel.hasAudio }

    private var content: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(channel.isOnline ? Color.green : Color.secondary)
                .frame(width: 10, height: 10)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 6) {
                Text(channel.name)
                    .font(.headline)
                Text(channelStatusText(channel))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // isOnline is already conveyed by the status dot + status line above, so it's
                // not repeated as a badge here.
                HStack(spacing: 6) {
                    booleanBadge("Audio", channel.hasAudio)
                    booleanBadge("Subtitles", channel.hasSubtitles)
                    booleanBadge("Muted", channel.isAudioMuted)
                }
                .padding(.top, 2)
            }

            Spacer()

            let accent = canPlay ? Color.accentColor : Color.secondary
            Image(systemName: channel.playState == .playing ? "stop.fill" : "play.fill")
                .font(.headline)
                .foregroundStyle(accent)
                .frame(width: 40, height: 40)
                .background(Circle().fill(accent.opacity(0.12)))
                .opacity(canPlay ? 1 : 0.4)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
    }

    /// A pill for one Boolean property: full-contrast (black/white per appearance) when
    /// `true`, faint when `false`, so every readable value stays visible.
    @ViewBuilder
    private func booleanBadge(_ label: String, _ isOn: Bool) -> some View {
        Text(label)
            .font(.caption2.weight(.medium))
            .lineLimit(1)
            .foregroundStyle(Color.primary.opacity(isOn ? 1 : 0.3))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .overlay(
                Capsule().stroke(Color.primary.opacity(isOn ? 0.85 : 0.16), lineWidth: 0.5)
            )
            .fixedSize(horizontal: true, vertical: false)
    }

    private func channelStatusText(_ channel: LiveVoiceChannel) -> String {
        if !channel.isOnline {
            return LiveVoiceLocalization.channel_status_offline
        }
        if let translation = channel.aiTranslationInfo {
            return "AI \(translation.targetLanguage)"
        }
        if channel.playState == .playing {
            return "Currently playing"
        }
        return "Ready to start"
    }
}
