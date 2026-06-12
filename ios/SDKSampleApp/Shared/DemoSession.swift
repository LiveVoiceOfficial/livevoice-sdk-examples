import Foundation
import LiveVoiceSDK

@MainActor
final class DemoSession: ObservableObject {
    @Published private(set) var selectedPreset: DemoApiKeyPreset

    /// Drives the app-level API key picker sheet.
    @Published var isApiKeyPickerPresented = false

    /// Drives the "Use your own event" credentials editor sheet.
    @Published var isCustomCredentialsEditorPresented = false

    /// Last credentials a tester entered via "Use your own event".
    @Published private(set) var customCredentials: DemoCredentials?

    /// Set when the picker asks for the editor.
    var pendingCustomCredentialsEditor = false

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

    func select(_ preset: DemoApiKeyPreset) {
        guard preset != selectedPreset else { return }
        selectedPreset = preset
        joinSelectedPreset()
    }

    /// Called from the picker's "Use your own event" row.
    func requestCustomCredentialsEditor() {
        pendingCustomCredentialsEditor = true
        isApiKeyPickerPresented = false
    }

    /// Applies credentials entered in the editor: persists them, selects the
    /// custom event, and (re)joins. An empty password means "no password".
    func applyCustomCredentials(joinCode: String, apiKey: String, password: String) {
        let credentials = DemoCredentials(joinCode: joinCode, password: password, apiKey: apiKey)
        customCredentials = credentials
        persistCustomCredentials(credentials)
        select(DemoFixture.customPreset(from: credentials))
    }

    private func joinSelectedPreset() {
        let preset = selectedPreset
        Task {
            await LiveVoice.shared.joinEvent(
                joinCode: preset.joinCode,
                password: preset.password,
                apiKey: preset.apiKey
            )
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
