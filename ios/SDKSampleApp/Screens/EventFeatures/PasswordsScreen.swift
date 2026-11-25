// Password-protected channels
//
// A protected channel needs its password when it starts. Without any setup,
// the SDK asks with its own prompt and remembers the password until the app
// quits. `passwordProvider` asks with your own UI instead, and
// `passwordStore` keeps passwords longer: the SDK asks it first, saves a
// password the server accepted and removes one it rejected.
//
// Needs: your own event with a password on a channel.
// Uses: LiveVoice.passwordProvider, passwordStore, LiveVoicePasswordStore,
// LiveVoicePasswordRequest, LiveVoicePasswordSubject
// See also: Subtitles (a protected channel's subtitles use the same password).
// Docs: LiveVoiceSDK documentation › LiveVoice.passwordProvider

import SwiftUI
import LiveVoiceSDK

struct PasswordsScreen: View {
    @EnvironmentObject private var demoSession: DemoSession
    @StateObject private var prompt = PasswordPrompt()
    @StateObject private var store = MemoryPasswordStore()

    var body: some View {
        DemoScreen("Password-protected channels", caption: "Ask for channel passwords with your own UI, and keep them.") {
            // The SDK lists an event's channels only in LiveVoiceView, so the note
            // can only tell the demo event apart.
            DemoRequirement(.ownEvent(feature: "Password-protected channels"), isMet: demoSession.usesOwnEvent)
            DemoSection("Channels") {
                // The SDK keeps an accepted password in memory for the app's run
                // and forgets one only when the server rejects it. Starting a
                // protected channel looks in memory, then asks the store, then
                // the provider.
                DemoNote(
                    "Once a password is accepted, the SDK remembers it until the app quits and won't ask again. Restart the app to see the prompt again.",
                    systemImage: "info.circle",
                    tint: .secondary
                )
                LiveVoiceView()
            }
            DemoSection("Saved passwords") {
                if store.passwords.isEmpty {
                    DemoPlaceholder("None yet: play a protected channel.")
                }
                ForEach(Array(store.passwords.keys), id: \.self) { subject in
                    Text(description(of: subject))
                }
            }
        }
        // A real app sets both once, at launch. This screen sets them only
        // while it shows, so the other screens keep the SDK's own prompt.
        .onAppear {
            LiveVoice.shared.passwordProvider = { [prompt] request in
                await prompt.ask(request)
            }
            LiveVoice.shared.passwordStore = store
        }
        .onDisappear {
            LiveVoice.shared.passwordProvider = nil
            LiveVoice.shared.passwordStore = nil
        }
        // Each sheet answers its own request: a retry after a wrong password
        // can arrive while the previous sheet still closes.
        .sheet(item: $prompt.pending) { pending in
            PasswordPromptView(request: pending.request) { prompt.answer(pending.id, $0) }
        }
    }

    private func description(of subject: LiveVoicePasswordSubject) -> String {
        switch subject {
        case let .channel(joinCode, channelID): "Channel \(channelID) of event \(joinCode)"
        case let .event(joinCode): "Event \(joinCode)"
        @unknown default: "Password"
        }
    }
}

/// Hands the SDK's password requests to your UI and waits for the answer.
@MainActor
private final class PasswordPrompt: ObservableObject {
    /// The request the sheet shows, with the way to answer it.
    struct Pending: Identifiable {
        let id = UUID()
        let request: LiveVoicePasswordRequest
        let continuation: CheckedContinuation<String?, Never>
    }

    @Published var pending: Pending?

    /// The provider: returns the password, or `nil` to give up, which fails
    /// the start with `.channelPasswordRequired`.
    func ask(_ request: LiveVoicePasswordRequest) async -> String? {
        await withCheckedContinuation { continuation in
            // A newer request replaces one still open, which gives up.
            if let older = pending {
                answer(older.id, nil)
            }
            pending = Pending(request: request, continuation: continuation)
        }
    }

    /// Answers the request with `id`. A late answer to an older request,
    /// such as from a sheet that is still closing, does nothing.
    func answer(_ id: UUID, _ password: String?) {
        guard let pending, pending.id == id else { return }
        self.pending = nil
        pending.continuation.resume(returning: password)
    }
}

/// Your own password prompt. `isRetry` is `true` after a rejected password.
/// It closes only through Cancel or Listen, so every request gets its answer.
private struct PasswordPromptView: View {
    let request: LiveVoicePasswordRequest
    let answer: (String?) -> Void
    @State private var password = ""

    var body: some View {
        DemoStackNavigation {
            Form {
                Section {
                    SecureField("Password", text: $password)
                } footer: {
                    if request.isRetry {
                        Text("Wrong password. Try again.")
                    }
                }
            }
            .navigationTitle("Password")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { answer(nil) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listen") { answer(password) }
                        .disabled(password.isEmpty)
                }
            }
        }
    }
}

/// Keeps passwords in memory, keyed by what they belong to. A real app keeps
/// them securely, for example in the Keychain, so they outlive the app.
/// Storing is best effort: an error you throw is logged and fails nothing.
@MainActor
private final class MemoryPasswordStore: LiveVoicePasswordStore, ObservableObject {
    @Published private(set) var passwords: [LiveVoicePasswordSubject: String] = [:]

    func load(_ subject: LiveVoicePasswordSubject) async throws -> String? {
        passwords[subject]
    }

    func save(_ password: String, for subject: LiveVoicePasswordSubject) async throws {
        passwords[subject] = password
    }

    func remove(_ subject: LiveVoicePasswordSubject) async throws {
        passwords[subject] = nil
    }
}

#Preview {
    DemoStackNavigation {
        PasswordsScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
