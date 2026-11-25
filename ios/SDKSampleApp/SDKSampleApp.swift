import SwiftUI
import LiveVoiceSDK

@main
struct LiveVoiceSDKDemoApp: App {
    @StateObject private var demoSession = DemoSession()

    init() {
        // Optional: without `initialize`, LiveVoice takes the audio exclusively
        // and shows the system media controls. Call it before joining to choose
        // other values. Nothing is joined yet at launch, so it can't fail with
        // `invalidArgument`, the only error it throws.
        let audio = DemoAudioSettings.atLaunch
        try? LiveVoice.shared.initialize(
            audioFocus: audio.audioFocus,
            showsSystemMediaControls: audio.showsSystemMediaControls
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(demoSession)
        }
    }
}

extension View {
    // Preview helper so individual screens can render against the same fixture.
    func initialized(joinCode: String, password: String? = nil, apiKey: String) -> some View {
        onAppear {
            Task {
                _ = try? await LiveVoice.shared.joinEvent(
                    joinCode: joinCode,
                    password: password,
                    apiKey: apiKey
                )
            }
        }
    }
}
