import SwiftUI
import LiveVoiceSDK

// You can provide any other information for channels by their ID
private let descriptions: [Int64: String] = [
    3308: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Turpis egestas integer eget aliquet nibh praesent tristique. Integer malesuada nunc vel risus commodo. Tortor posuere ac ut consequat semper viverra. Auctor augue mauris augue neque. Adipiscing tristique risus nec feugiat in fermentum posuere urna nec. Diam donec adipiscing tristique risus nec feugiat. Odio morbi quis commodo odio. Dictum non consectetur a erat. Pretium fusce id velit ut.",
    3309: "Ultricies mi eget mauris pharetra et ultrices neque. Lobortis scelerisque fermentum dui faucibus in ornare quam viverra. Quis hendrerit dolor magna eget est lorem. Diam volutpat commodo sed egestas egestas. Eget duis at tellus at. Dignissim convallis aenean et tortor. Mauris cursus mattis molestie a iaculis. Accumsan sit amet nulla facilisi morbi tempus iaculis urna. Hac habitasse platea dictumst vestibulum rhoncus est. Consectetur adipiscing elit ut aliquam purus sit amet.",
]

private let imageURLs:  [Int64: URL] = [
    3308: URL(string: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=60&h=60&q=80")!,
    3309: URL(string: "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=60&h=60&q=80")!,
]

extension LiveVoiceChannel.PlayState {
    @ViewBuilder
    func buttonTitle() -> some View {
        switch self {
        case .stopped:
            Text("Listen now!")
        case .transitioning:
            ProgressView().progressViewStyle(.circular)
        case .playing:
            Text("Stop listening")
        @unknown default:
            EmptyView()
        }
    }
}

struct CustomUI2: View {
    var body: some View {
        VStack {
            Text("Content library")
                .font(.title.bold())
                .foregroundStyle(.white)
                .padding()
            ScrollView {
                LiveVoiceView { (state: LiveVoiceView.ViewState) in
                    VStack {
                        switch state {
                        case .loading:
                            EmptyView()
                        case let .ready(channel: channel, isLast: _, onTap: onTap):
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top, spacing: 20) {
                                    AsyncImage(url: imageURLs[channel.id]) { image in
                                        image
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.gray.opacity(0.8))
                                            .frame(width: 60, height: 60)
                                    }
                                    HStack {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(channel.name)
                                                .font(.title2)
                                            
                                            Text(channel.id, format: .number)
                                                .font(.caption)
                                        }
                                        Spacer()
                                    }
                                }
                                Text(descriptions[channel.id] ?? "No description")
                                    .multilineTextAlignment(.leading)
                                Button {
                                    onTap()
                                } label: {
                                    channel.playState.buttonTitle()
                                }
                                .buttonStyle(.bordered)
                                .foregroundStyle(.white)
                            }
                            .padding()
                        case let .reconnecting(state):
                            if case let .waiting(until) = state {
                                Text("Reconnecting… \(Text(until, style: .relative))")
                            } else {
                                Text("Reconnecting…")
                            }
                        case let .error(error, retry: retry):
                            Text("\(error)")
                            if let retry {
                                Button("Retry") { Task { await retry() } }
                                .buttonStyle(.bordered)
                                .foregroundStyle(.white)
                            }
                        case .noMatchingChannels:
                            Text("No matching channel")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white.opacity(0.2))
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Ensure the LiveVoice logo is white
            .environment(\.colorScheme, .dark)
        }
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.init(hue: 0.4, saturation: 1, brightness: 0.3),
                        Color.init(hue: 0.4, saturation: 1, brightness: 0.2),
                    ]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    CustomUI2()
        .initialized(joinCode: "123456", apiKey: "s09WEG5y3caQ6R2PDaG4i8R1aTooTd")
}
