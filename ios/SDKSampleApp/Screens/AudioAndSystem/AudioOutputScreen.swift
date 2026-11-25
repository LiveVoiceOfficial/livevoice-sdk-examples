// Audio output
//
// `audioOutput` is a preference, not the current route: `.system`, the
// default, lets the system choose, such as connected headphones or the
// receiver; `.speaker` prefers the loudspeaker. Set it any time, also before
// joining; setting it never fails. The setting is the SDK's, so it applies
// to the whole app, not just this screen.
//
// Uses: LiveVoice.audioOutput, LiveVoiceAudioOutput
// See also: Lock screen and audio sharing (with `.hostManaged` audio focus,
// your app picks the route and this preference has no effect).
// Docs: LiveVoiceSDK documentation › Choosing Audio Output

import SwiftUI
import LiveVoiceSDK

struct AudioOutputScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared

    var body: some View {
        DemoScreen("Audio output", caption: "Prefer the loudspeaker, or let the system choose.") {
            DemoSection("Output") {
                DemoNote(
                    "These settings apply to the whole app: every demo screen plays with them, and a playing channel keeps playing when you switch screens.",
                    systemImage: "info.circle",
                    tint: .secondary
                )
                Picker("Audio output", selection: $liveVoice.audioOutput) {
                    Text("System")
                        .tag(LiveVoiceAudioOutput.system)
                    Text("Speaker")
                        .tag(LiveVoiceAudioOutput.speaker)
                }
                .pickerStyle(.segmented)
            }
            DemoSection("Channels") {
                LiveVoiceView()
            }
        }
    }
}

#Preview {
    DemoStackNavigation {
        AudioOutputScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
