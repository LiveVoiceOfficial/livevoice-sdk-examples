// Filtering channels
//
// LiveVoiceView's `filter` decides which channels it shows: it gets each
// channel and returns `true` to keep it. Filter on any channel property;
// the look, playback and reconnection stay the same. A filter that matches
// nothing shows the view's "no matching channels" state.
//
// Uses: LiveVoiceView(filter:), LiveVoiceChannel
// See also: Default interface, Custom view states (your own empty part).
// Docs: LiveVoiceSDK documentation › Filtering Channels

import SwiftUI
import LiveVoiceSDK

struct FilteringChannelsScreen: View {
    @State private var filter: Filter = .all

    var body: some View {
        DemoScreen("Filtering channels", caption: "Show only the channels you want.") {
            DemoSection("Filter") {
                Picker("Filter", selection: $filter) {
                    ForEach(Filter.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            DemoSection("Channels") {
                LiveVoiceView { channel in
                    switch filter {
                    case .all: true
                    case .online: channel.isOnline
                    case .withSubtitles: channel.hasSubtitles
                    case .none: false
                    }
                }
                // More filters:
                // - A single channel, by its ID from the dashboard's "Show Options":
                //   `channel.id == 137`
                // - A source channel with the AI translations derived from it:
                //   `channel.id == sourceID || channel.aiTranslationInfo?.sourceChannelID == sourceID`
            }
        }
    }

    private enum Filter: String, CaseIterable {
        case all = "All"
        case online = "Online"
        case withSubtitles = "Subtitles"
        case none = "None"
    }
}

#Preview {
    DemoStackNavigation {
        FilteringChannelsScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
