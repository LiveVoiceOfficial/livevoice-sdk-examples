import SwiftUI
import LiveVoiceSDK

@main
struct LiveVoiceSDKDemoApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await LiveVoice.shared.joinEvent(
                        joinCode: "123456",
                        password: nil,
                        apiKey: "s09WEG5y3caQ6R2PDaG4i8R1aTooTd"
                    )
                }
        }
    }
}

// MARK: - A helper for SwiftUI previews

extension View {
    func initialized(joinCode: String, password: String? = nil, apiKey: String) -> some View {
        self
            .onAppear {
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
