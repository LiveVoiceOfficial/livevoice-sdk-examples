import Foundation

struct DemoApiKeyPreset: Identifiable, Equatable {
    let id: String
    let title: String
    let summary: String
    let joinCode: String
    let password: String?
    let apiKey: String
}

/// User-entered credentials for the "Use your own event" picker option. Persisted
/// so the editor pre-fills on reopen; see `DemoSession`.
struct DemoCredentials: Equatable, Codable {
    var joinCode: String
    /// Empty string means "no password"; some events are password-protected.
    var password: String
    var apiKey: String
}

enum DemoFixture {
    static let joinCode = "123456"
    static let password: String? = nil

    /// Identifies the dynamic "Use your own event" selection (built from
    /// user-entered `DemoCredentials`, not part of `apiKeyPresets`).
    static let customPresetID = "custom"

    static let defaultPreset = DemoApiKeyPreset(
        id: "default",
        title: "Default",
        summary: "Branding visible, custom UI disabled.",
        joinCode: joinCode,
        password: password,
        apiKey: "HD4cQklUOQKOBWimG54j2kRnxFklDL"
    )

    static let hideBrandingPreset = DemoApiKeyPreset(
        id: "hide-branding",
        title: "Hide branding",
        summary: "Branding hidden, custom UI disabled.",
        joinCode: joinCode,
        password: password,
        apiKey: "uFlkcGkUJEcb7jK6qFcdygreFRTXVh"
    )

    static let fullCustomizationPreset = DemoApiKeyPreset(
        id: "full-customization",
        title: "Full customization",
        summary: "Branding hidden, custom UI enabled.",
        joinCode: joinCode,
        password: password,
        apiKey: "s09WEG5y3caQ6R2PDaG4i8R1aTooTd"
    )

    static let apiKeyPresets = [
        defaultPreset,
        hideBrandingPreset,
        fullCustomizationPreset,
    ]

    static let apiKey = defaultPreset.apiKey

    /// Builds the dynamic preset selected when a tester enters their own event
    /// credentials. An empty password is treated as "no password".
    static func customPreset(from credentials: DemoCredentials) -> DemoApiKeyPreset {
        DemoApiKeyPreset(
            id: customPresetID,
            title: "Your own event",
            summary: "Join code \(credentials.joinCode) with your own API key.",
            joinCode: credentials.joinCode,
            password: credentials.password.isEmpty ? nil : credentials.password,
            apiKey: credentials.apiKey
        )
    }
}
