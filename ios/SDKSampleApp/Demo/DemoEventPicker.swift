// Demo scaffolding — not needed for an integration.
// The toolbar's event picker: the demo API keys, your own event's credentials, and the sheets that pick them.

import SwiftUI

private struct DemoApiKeyMenu: View {
    @EnvironmentObject private var demoSession: DemoSession

    var body: some View {
        Button {
            demoSession.eventSheet = .apiKeyPicker
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
            // A changed item makes SwiftUI close the list and open the editor.
            .sheet(item: $demoSession.eventSheet) { sheet in
                switch sheet {
                case .apiKeyPicker:
                    DemoApiKeyPicker(measuredHeight: $sheetHeight)
                        .environmentObject(demoSession)
                        .demoSheetHeight(sheetHeight)
                case .customCredentialsEditor:
                    DemoCustomCredentialsEditor(credentials: demoSession.customCredentials)
                        .environmentObject(demoSession)
                }
            }
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
            DemoApiKeyPresetList(onSelect: { dismiss() })

            Divider()

            DemoPickerRow(
                title: "Use your own event",
                summary: customRowSummary,
                isSelected: demoSession.selectedPreset.id == DemoFixture.customPresetID,
                action: demoSession.requestCustomCredentialsEditor
            )
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

/// The demo event's three API keys, each with what it permits; tapping one
/// joins the demo event with it.
struct DemoApiKeyPresetList: View {
    @EnvironmentObject private var demoSession: DemoSession
    var onSelect: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(DemoFixture.apiKeyPresets.enumerated()), id: \.element.id) { index, preset in
                if index > 0 { Divider() }

                DemoPickerRow(
                    title: preset.title,
                    summary: preset.summary,
                    isSelected: demoSession.selectedPreset == preset
                ) {
                    demoSession.select(preset)
                    onSelect()
                }
            }
        }
    }
}

private struct DemoPickerRow: View {
    let title: String
    let summary: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tint)
                    .opacity(isSelected ? 1 : 0)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                    // Join codes have digits and letters, in any case.
                    TextField("Join code", text: $joinCode)
                        .keyboardType(.asciiCapable)
                        .textInputAutocapitalization(.characters)
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
