// Custom view states
//
// LiveVoiceView takes your own views for its states: `loading`,
// `reconnecting`, `error` and `empty`; the parts you leave out keep the SDK's
// design. `onCommandError` receives the errors of the SDK's own controls.
// LiveVoiceView shows a part only while its state lasts, so the screen shows
// each of your views with sample values first. Below, LiveVoiceView uses them:
// turn on flight mode while a channel plays to see reconnecting and errors.
//
// Needs: an API key that permits custom UI (except for `loading`).
// Uses: LiveVoiceView.loading(_:), reconnecting(_:), error(_:), empty(_:),
// onCommandError(_:), LiveVoiceRetry, LiveVoiceEmptyReason
// See also: Custom channel cell, Joining an event (connection and reconnect),
// Localization and accessibility (error messages).
// Docs: LiveVoiceSDK documentation › LiveVoiceView

import SwiftUI
import LiveVoiceSDK

struct CustomViewStatesScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared
    @State private var failure: LiveVoiceError?

    var body: some View {
        DemoScreen("Custom view states", caption: "Show loading, reconnecting, errors and no channels your way.", error: failure) {
            DemoRequirement(.customUI, isMet: liveVoice.customUiAllowed)
            DemoSection("Your views, with sample values") {
                DemoLabeled("Loading") { LoadingView() }
                DemoLabeled("Reconnecting") { ReconnectingView(retry: .scheduled(at: Date().addingTimeInterval(8))) }
                DemoLabeled("Error") { ErrorView(error: LiveVoiceError(.noNetwork), retry: {}) }
                DemoLabeled("No channels") { NoChannelsView(reason: .noChannels) }
            }
            DemoSection("In LiveVoiceView") {
                DemoNote("Your views show while their state lasts; while connected, the channels do.", systemImage: "info.circle", tint: .secondary)
                LiveVoiceView()
                    // Call the parts directly on LiveVoiceView, before other modifiers.
                    .loading {
                        LoadingView()
                    }
                    .reconnecting { retry in
                        ReconnectingView(retry: retry)
                    }
                    .error { error, retry in
                        ErrorView(error: error, retry: retry)
                    }
                    .empty { reason in
                        NoChannelsView(reason: reason)
                    }
                    // `.cancelled` and `.superseded` never arrive here. Your own
                    // parts get their errors from their actions instead.
                    .onCommandError { error in
                        failure = error
                    }
            }
        }
    }
}

/// While the event loads.
private struct LoadingView: View {
    var body: some View {
        StateRow(title: "Loading channels…", detail: nil) {
            ProgressView()
        }
    }
}

/// Shown after the SDK kept the channel list, drawn disabled, for the first
/// seconds of a reconnection. The SDK reconnects by itself.
private struct ReconnectingView: View {
    let retry: LiveVoiceRetry

    var body: some View {
        StateRow(title: "Reconnecting", detail: detail) {
            ProgressView()
        }
    }

    private var detail: Text {
        switch retry {
        case .inProgress:
            Text("Trying now…")
        case let .scheduled(date):
            Text("Next try \(Text(date, style: .relative))")
        @unknown default:
            Text("Trying again soon…")
        }
    }
}

/// Shows the error's `message`, the SDK's text for it. `retry` is there
/// exactly when trying again can help.
private struct ErrorView: View {
    let error: LiveVoiceError
    let retry: (() async throws -> Void)?

    var body: some View {
        StateRow(title: "Couldn't connect", detail: Text(error.message), symbol: "exclamationmark.triangle.fill") {
            if let retry {
                Button("Try again") {
                    // A failed retry shows up as the view's next error.
                    Task { try? await retry() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

private struct NoChannelsView: View {
    let reason: LiveVoiceEmptyReason

    var body: some View {
        StateRow(title: title, detail: nil, symbol: "tray") {
            EmptyView()
        }
    }

    private var title: String {
        switch reason {
        case .noChannels:
            "This event has no channels yet."
        case .noMatches:
            // The view's filter matches none of the event's channels.
            "No matching channels."
        @unknown default:
            "No channels."
        }
    }
}

/// The look the state views share with a channel row: an icon, a title, a
/// detail line, and an accessory on the trailing side, in a card.
private struct StateRow<Accessory: View>: View {
    let title: String
    let detail: Text?
    var symbol: String? = nil
    @ViewBuilder let accessory: Accessory

    var body: some View {
        HStack(spacing: 12) {
            if let symbol {
                Image(systemName: symbol)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                detail?
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            accessory
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.tertiarySystemBackground)))
    }
}

#Preview {
    DemoStackNavigation {
        CustomViewStatesScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
