// Lock screen and audio sharing
//
// `audioFocus` decides what happens to other audio while a channel plays.
// With `.exclusive`, the default, the playing channel appears on the Lock
// Screen and in Control Center, unless `showsSystemMediaControls` is off;
// `nowPlayingArtwork` replaces the event's logo there. Best tried on a
// device: play a channel, then lock the phone. The settings are the SDK's,
// so they apply to the whole app, not just this screen.
//
// `audioFocus` and `showsSystemMediaControls` are arguments of the optional
// `initialize`, which the demo calls at launch (SDKSampleApp.swift). There
// is no getter, so the app keeps what it passed (DemoSession). A changed
// configuration applies only while no event is joined (connection `.idle`
// or `.failed`); otherwise `initialize` throws `invalidArgument`. So this
// screen leaves the event, initializes again and joins again, which stops
// the playing channel; a real app passes them once, at launch.
// `nowPlayingArtwork` is a property you can set at any time.
//
// Uses: LiveVoice.initialize(audioFocus:showsSystemMediaControls:),
// LiveVoiceAudioFocus, nowPlayingArtwork, connection, leaveEvent(),
// joinEvent(joinCode:password:apiKey:)
// See also: Audio output.
// Docs: LiveVoiceSDK documentation › Sharing Audio with Other Apps

import SwiftUI
import LiveVoiceSDK

struct LockScreenScreen: View {
    @EnvironmentObject private var demoSession: DemoSession
    // The settings being applied, shown until `initialize` has taken them.
    @State private var pending: DemoAudioSettings?
    @State private var failure: LiveVoiceError?

    var body: some View {
        DemoScreen("Lock screen and audio sharing", caption: "Share the audio with other apps, and show the playing channel on the Lock Screen.", error: failure) {
            DemoSection("Other audio") {
                DemoNote(
                    "These settings apply to the whole app: every demo screen plays with them, and a playing channel keeps playing when you switch screens.",
                    systemImage: "info.circle",
                    tint: .secondary
                )
                DemoNote(
                    "Changing them leaves the event, initializes the SDK again and joins again, so the playing channel stops.",
                    systemImage: pending == nil ? "info.circle" : "hourglass",
                    tint: .secondary
                )
                // `.hostManaged` leaves the audio session to your app: it sets up
                // and activates one before a channel starts, and picks the route.
                Picker("Audio focus", selection: setting(\.audioFocus)) {
                    Text("Pause").tag(LiveVoiceAudioFocus.exclusive)
                    Text("Duck").tag(LiveVoiceAudioFocus.duckOthers)
                }
                .pickerStyle(.segmented)
                .disabled(pending != nil)
            }
            DemoSection("Lock Screen and Control Center") {
                // Turn them off if your app shows its own media controls. Only
                // `.exclusive` shows them: the system has none for mixed audio.
                Toggle("System media controls", isOn: setting(\.showsSystemMediaControls))
                    .disabled(pending != nil || demoSession.audioSettings.audioFocus != .exclusive)
                if demoSession.audioSettings.audioFocus != .exclusive {
                    DemoNote("With Duck, iOS shows no system controls: it shows them only for audio that doesn't mix with other apps.", systemImage: "info.circle", tint: .secondary)
                }
                HStack {
                    // The SDK draws it fitted, with a margin, on a white square.
                    Button("App image") { LiveVoice.shared.nowPlayingArtwork = UIImage(named: "DemoArtwork") }
                    // `nil` shows the event's logo from the dashboard, or none.
                    Button("Event logo") { LiveVoice.shared.nowPlayingArtwork = nil }
                }
                .buttonStyle(.bordered)
            }
            DemoSection("Channels") {
                LiveVoiceView()
            }
        }
    }

    /// One of the settings, as shown; changing it applies all of them.
    private func setting<Value>(_ keyPath: WritableKeyPath<DemoAudioSettings, Value>) -> Binding<Value> {
        Binding(
            get: { (pending ?? demoSession.audioSettings)[keyPath: keyPath] },
            set: { value in
                var settings = pending ?? demoSession.audioSettings
                settings[keyPath: keyPath] = value
                Task { await apply(settings) }
            }
        )
    }

    /// `initialize` takes a changed configuration only while no event is
    /// joined: leave, initialize with the new values, and join again.
    private func apply(_ settings: DemoAudioSettings) async {
        guard pending == nil, settings != demoSession.audioSettings else { return }
        // The event picked in the toolbar.
        let event = demoSession.selectedPreset
        pending = settings
        failure = nil
        defer { pending = nil }
        do throws(LiveVoiceError) {
            let wasJoined = switch LiveVoice.shared.connection {
            case .idle, .failed: false
            default: true
            }
            if wasJoined { try await LiveVoice.shared.leaveEvent() }
            try LiveVoice.shared.initialize(
                audioFocus: settings.audioFocus,
                showsSystemMediaControls: settings.showsSystemMediaControls
            )
            demoSession.rememberAudioSettings(settings)
            if wasJoined {
                _ = try await LiveVoice.shared.joinEvent(joinCode: event.joinCode, password: event.password, apiKey: event.apiKey)
            }
        } catch {
            // A newer join, such as one from the toolbar, took over.
            guard error.code != .cancelled, error.code != .superseded else { return }
            failure = error
        }
    }
}

#Preview {
    DemoStackNavigation {
        LockScreenScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
