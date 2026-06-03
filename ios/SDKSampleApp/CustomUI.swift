import SwiftUI
import LiveVoiceSDK

extension LiveVoiceChannel.PlayState {
    @ViewBuilder
    func buttonLabel() -> some View {
        switch self {
        case .stopped:
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 50, height: 50)
                Image(systemName: "play")
                    .font(.title2.bold())
            }
        case .transitioning:
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 50, height: 50)
                ProgressView()
            }
        case .playing:
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 50, height: 50)
                Image(systemName: "stop")
                    .font(.title2.bold())
            }
        @unknown default:
            EmptyView()
        }
    }
}

extension Color {
    static let darkBlue = Color.init(hue: 0.6, saturation: 1, brightness: 0.4)
    static let lightBlue = Color.init(hue: 0.6, saturation: 1, brightness: 1)
}

struct CustomUI: View {
    var body: some View {
        Group {
            LiveVoiceView { (state: LiveVoice.ViewState) in
                switch state {
                case .loading:
                    EmptyView()
                case let .ready(channel: channel, isLast: _, onTap: onTap):
                    HStack {
                        VStack(alignment: .leading) {
                            Text(channel.name)
                                .font(.title.bold())
                            if !channel.dependentChannels.isEmpty {
                                // Every channel carries information about AI channels that have
                                // this channel as input. Check their `hasSubtitles` or `hasAudio`
                                // properties to learn what kind of translation they provide.
                                let channelList = channel.dependentChannels
                                    .map(\.name)
                                    .formatted(.list(type: .and))
                                Text(verbatim: "Other languages: \(channelList)")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(Color.lightBlue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        Button {
                            onTap()
                        } label: {
                            channel.playState.buttonLabel()
                        }
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 40, style: .circular)
                            .stroke(Color.lightBlue, lineWidth: 3)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                case let .reconnecting(state):
                    HStack {
                        if case let .waiting(until) = state {
                            Text("Reconnecting… \(Text(until, style: .relative))")
                                .foregroundStyle(Color.lightBlue)
                                .padding(.leading, 10)
                        } else {
                            Text("Reconnecting…")
                                .foregroundStyle(Color.lightBlue)
                                .padding(.leading, 10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 40, style: .circular)
                            .stroke(Color.lightBlue, lineWidth: 3)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    
                case let .error(error, retry: retry):
                    HStack {
                        Text(error.localizedDescription, bundle: .liveVoiceSDK)
                            .foregroundStyle(Color.lightBlue)
                            .padding(.leading, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 40, style: .circular)
                            .stroke(Color.lightBlue, lineWidth: 3)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    if let retry {
                        Button("Retry") {
                            Task { await retry() }
                        }
                    }
                case .noMatchingChannels:
                    Text("No matching channel")
                @unknown default:
                    EmptyView()
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.darkBlue)
    }
}

#Preview {
    CustomUI()
        .initialized(joinCode: "123456", apiKey: "s09WEG5y3caQ6R2PDaG4i8R1aTooTd")
}
