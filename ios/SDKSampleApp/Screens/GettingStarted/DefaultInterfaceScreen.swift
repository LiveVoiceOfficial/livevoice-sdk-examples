// Default interface
//
// The smallest integration: LiveVoiceView lists the joined event's channels
// and plays the one a listener taps. It also shows loading, reconnecting,
// errors, an event without channels and the LiveVoice branding by itself.
// `initialize` is optional; the demo calls it at launch (SDKSampleApp.swift).
//
// Uses: LiveVoiceView
// See also: Joining an event (how the event is joined), Filtering channels,
// Custom channel cell, Subtitles, Audio output.
// Docs: LiveVoiceSDK documentation › Getting Started

import SwiftUI
import LiveVoiceSDK

struct DefaultInterfaceScreen: View {
    var body: some View {
        DemoScreen("Default interface", caption: "Tap a channel to listen.") {
            DemoSection("Channels") {
                LiveVoiceView()
            }
        }
    }
}

#Preview {
    DemoStackNavigation {
        DefaultInterfaceScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
