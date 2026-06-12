import SwiftUI
import LiveVoiceSDK

@main
struct LiveVoiceSDKDemoApp: App {
    @StateObject private var demoSession = DemoSession()

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
                await LiveVoice.shared.joinEvent(
                    joinCode: joinCode,
                    password: password,
                    apiKey: apiKey
                )
            }
        }
    }
}
