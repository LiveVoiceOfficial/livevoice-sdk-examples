import SwiftUI
import LiveVoiceSDK

struct DemoScreenHeader: View {
    let title: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.largeTitle.weight(.semibold))
            Text(summary)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .demoApiKeyToolbar(compactOnly: true)
    }
}

struct DemoCustomUiWarning: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared

    var body: some View {
        if !liveVoice.customUiAllowed {
            DemoWarningBanner(
                text: "This API key does not allow custom styling. Pick one of the preset API keys from the top-right menu to try the custom examples."
            )
        }
    }
}

/// A placeholder shown in a subtitle view while no channel is providing subtitles.
struct DemoSubtitleUnavailableHint: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "captions.bubble")
                .foregroundStyle(.secondary)

            Text("Your channels need to provide subtitles to see them here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.gray.opacity(0.12))
        )
    }
}

private struct DemoWarningBanner: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.orange.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.orange.opacity(0.28), lineWidth: 1)
        )
    }
}

private struct DemoApiKeyMenu: View {
    @EnvironmentObject private var demoSession: DemoSession

    var body: some View {
        Button {
            demoSession.isApiKeyPickerPresented = true
        } label: {
            HStack(spacing: 4) {
                Text("API key")
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
            }
            .font(.subheadline.weight(.medium))
        }
    }
}

/// Presents the app-level API key picker sheet.
private struct DemoApiKeyPickerSheet: ViewModifier {
    @EnvironmentObject private var demoSession: DemoSession
    @State private var sheetHeight: CGFloat = 240

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $demoSession.isApiKeyPickerPresented, onDismiss: presentEditorIfRequested) {
                DemoApiKeyPicker(measuredHeight: $sheetHeight)
                    .environmentObject(demoSession)
                    .demoSheetHeight(sheetHeight)
            }
            .sheet(isPresented: $demoSession.isCustomCredentialsEditorPresented) {
                DemoCustomCredentialsEditor(credentials: demoSession.customCredentials)
                    .environmentObject(demoSession)
            }
    }

    private func presentEditorIfRequested() {
        guard demoSession.pendingCustomCredentialsEditor else { return }
        demoSession.pendingCustomCredentialsEditor = false
        demoSession.isCustomCredentialsEditorPresented = true
    }
}

private struct DemoApiKeyPickerHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct DemoApiKeyPicker: View {
    @EnvironmentObject private var demoSession: DemoSession
    @Environment(\.dismiss) private var dismiss
    @Binding var measuredHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(DemoFixture.apiKeyPresets.enumerated()), id: \.element.id) { index, preset in
                if index > 0 { Divider() }

                Button {
                    demoSession.select(preset)
                    dismiss()
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preset.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(preset.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 8)

                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tint)
                            .opacity(demoSession.selectedPreset == preset ? 1 : 0)
                    }
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Divider()

            Button {
                demoSession.requestCustomCredentialsEditor()
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Use your own event")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(customRowSummary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tint)
                        .opacity(demoSession.selectedPreset.id == DemoFixture.customPresetID ? 1 : 0)
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(key: DemoApiKeyPickerHeightKey.self, value: proxy.size.height)
            }
        }
        .onPreferenceChange(DemoApiKeyPickerHeightKey.self) { measuredHeight = $0 }
    }

    private var customRowSummary: String {
        if let credentials = demoSession.customCredentials {
            return "Join code \(credentials.joinCode) · tap to edit."
        }
        return "Enter your own join code and API key."
    }
}

/// Modal editor for the "Use your own event" credentials. Lets a tester join
/// their own LiveVoice event with their own join code + API key (and optional
/// password) without rebuilding the sample.
private struct DemoCustomCredentialsEditor: View {
    @EnvironmentObject private var demoSession: DemoSession
    @Environment(\.dismiss) private var dismiss

    @State private var joinCode: String
    @State private var apiKey: String
    @State private var password: String

    init(credentials: DemoCredentials?) {
        _joinCode = State(initialValue: credentials?.joinCode ?? "")
        _apiKey = State(initialValue: credentials?.apiKey ?? "")
        _password = State(initialValue: credentials?.password ?? "")
    }

    private var trimmedJoinCode: String { joinCode.trimmingCharacters(in: .whitespaces) }
    private var trimmedApiKey: String { apiKey.trimmingCharacters(in: .whitespaces) }
    private var canUse: Bool { !trimmedJoinCode.isEmpty && !trimmedApiKey.isEmpty }

    var body: some View {
        DemoStackNavigation {
            Form {
                Section {
                    TextField("Join code", text: $joinCode)
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("API key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Password (optional)", text: $password)
                } footer: {
                    Text("Enter the join code and API key for your own LiveVoice event. The password is only needed for password-protected events.")
                }
            }
            .navigationTitle("Use your own event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Use") {
                        demoSession.applyCustomCredentials(
                            joinCode: trimmedJoinCode,
                            apiKey: trimmedApiKey,
                            password: password
                        )
                        dismiss()
                    }
                    .disabled(!canUse)
                }
            }
        }
    }
}

private struct DemoApiKeyToolbar: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let compactOnly: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        // Keep the toolbar content unconditional and gate at the View level
        // instead: a conditional inside `.toolbar` yields an optional
        // ToolbarContent, whose conformance is only available on iOS 16+.
        if !compactOnly || horizontalSizeClass == .compact {
            content.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DemoApiKeyMenu()
                }
            }
        } else {
            content
        }
    }
}

extension View {
    func demoApiKeyToolbar(compactOnly: Bool = false) -> some View {
        modifier(DemoApiKeyToolbar(compactOnly: compactOnly))
    }

    /// Presents the API key picker sheet requested by the `demoApiKeyToolbar` menu buttons.
    func demoApiKeyPickerSheet() -> some View {
        modifier(DemoApiKeyPickerSheet())
    }
}
