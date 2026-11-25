// Demo scaffolding — not needed for an integration.
// Joins the event picked in the toolbar at launch and whenever the pick changes,
// and remembers what the app last passed to `initialize`.

import Foundation
import LiveVoiceSDK

/// What the app-level event sheet shows.
enum DemoEventSheet: Identifiable {
    case apiKeyPicker
    case customCredentialsEditor

    var id: Self { self }
}

@MainActor
final class DemoSession: ObservableObject {
    @Published private(set) var selectedPreset: DemoApiKeyPreset

    /// The app-level sheet that picks the event: the API key list or the
    /// "Use your own event" editor. One sheet shows both, so switching from
    /// the list to the editor needs no handoff between two sheets, which
    /// iOS 15 drops.
    @Published var eventSheet: DemoEventSheet?

    /// Last credentials a tester entered via "Use your own event".
    @Published private(set) var customCredentials: DemoCredentials?

    /// What the app last passed to `initialize`. The SDK has no getter for it,
    /// so the app keeps it (see Lock screen and audio sharing).
    @Published private(set) var audioSettings = DemoAudioSettings.atLaunch

    private static let customCredentialsDefaultsKey = "DemoSession.customCredentials"

    init(
        selectedPreset: DemoApiKeyPreset = DemoFixture.defaultPreset,
        joinOnInit: Bool = true
    ) {
        self.selectedPreset = selectedPreset
        self.customCredentials = Self.loadCustomCredentials()

        if joinOnInit {
            joinSelectedPreset()
        }
    }

    /// Whether the picked event is your own rather than the demo event.
    var usesOwnEvent: Bool { selectedPreset.id == DemoFixture.customPresetID }

    func select(_ preset: DemoApiKeyPreset) {
        guard preset != selectedPreset else { return }
        selectedPreset = preset
        joinSelectedPreset()
    }

    /// Called from the picker's "Use your own event" row.
    func requestCustomCredentialsEditor() {
        eventSheet = .customCredentialsEditor
    }

    /// Applies credentials entered in the editor: persists them, selects the
    /// custom event, and (re)joins. An empty password means "no password".
    func applyCustomCredentials(joinCode: String, apiKey: String, password: String) {
        let credentials = DemoCredentials(joinCode: joinCode, password: password, apiKey: apiKey)
        customCredentials = credentials
        persistCustomCredentials(credentials)
        select(DemoFixture.customPreset(from: credentials))
    }

    /// Call after a successful `initialize` with `settings`.
    func rememberAudioSettings(_ settings: DemoAudioSettings) {
        audioSettings = settings
    }

    private var joinTask: Task<Void, Never>?

    private func joinSelectedPreset() {
        joinTask?.cancel()
        let preset = selectedPreset
        joinTask = Task {
            do {
                _ = try await LiveVoice.shared.joinEvent(
                    joinCode: preset.joinCode, password: preset.password, apiKey: preset.apiKey
                )
            } catch let error as LiveVoiceError {
                // The SDK view displays connection failures. Never log credentials.
                if error.code != .cancelled && error.code != .superseded {
                    print("LiveVoice join failed: \(error.code)")
                }
            } catch is CancellationError {
                // The owner was replaced.
            } catch {
                print("LiveVoice join failed")
            }
        }
    }

    private func persistCustomCredentials(_ credentials: DemoCredentials) {
        guard let data = try? JSONEncoder().encode(credentials) else { return }
        UserDefaults.standard.set(data, forKey: Self.customCredentialsDefaultsKey)
    }

    private static func loadCustomCredentials() -> DemoCredentials? {
        guard let data = UserDefaults.standard.data(forKey: customCredentialsDefaultsKey) else {
            return nil
        }
        return try? JSONDecoder().decode(DemoCredentials.self, from: data)
    }

    static var preview: DemoSession {
        DemoSession(joinOnInit: false)
    }
}

/// The settings `LiveVoice.initialize` takes, which only another `initialize`
/// changes.
struct DemoAudioSettings: Equatable {
    var audioFocus: LiveVoiceAudioFocus
    var showsSystemMediaControls: Bool

    /// What the app initializes LiveVoice with at launch: the SDK's defaults.
    static let atLaunch = DemoAudioSettings(audioFocus: .exclusive, showsSystemMediaControls: true)
}
