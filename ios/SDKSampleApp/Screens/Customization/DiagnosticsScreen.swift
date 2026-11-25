// Diagnostics log
//
// The SDK reports what it does as named events, such as `LV_JOIN_RESULT` or
// `LV_CHANNEL_RESULT`, each with a level and a few fields; a failure carries
// its error `code`. They go to the system log (subsystem `io.livevoice.sdk`),
// and `setLogListener` forwards them to your own logging. Tap a channel to
// see some.
//
// Uses: LiveVoice.setLogListener(_:), LiveVoiceLogEntry, LiveVoiceLogLevel
// See also: Joining an event, Localization and accessibility (error messages).
// Docs: LiveVoiceSDK documentation › Reading Diagnostics

import SwiftUI
import LiveVoiceSDK

struct DiagnosticsScreen: View {
    /// The latest entries, newest first.
    @State private var entries: [LiveVoiceLogEntry] = []

    var body: some View {
        DemoScreen("Diagnostics log", caption: "Read what the SDK did, and why a call failed.") {
            DemoSection("Channels") {
                LiveVoiceView()
            }
            DemoSection("Log") {
                if entries.isEmpty {
                    DemoPlaceholder("Nothing logged yet: tap a channel.")
                }
                ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                    LogEntryRow(entry: entry)
                }
            }
        }
        .task {
            // There is one listener: setting one replaces the previous, `nil`
            // removes it. It's called on the thread that logged the event, so
            // it only hands the entry on, and never calls the SDK.
            let (stream, continuation) = AsyncStream.makeStream(of: LiveVoiceLogEntry.self)
            LiveVoice.setLogListener { entry in
                continuation.yield(entry)
            }
            // Leaving the screen cancels the task, which ends the loop.
            defer { LiveVoice.setLogListener(nil) }
            for await entry in stream {
                entries.insert(entry, at: 0)
                entries = Array(entries.prefix(100))
            }
        }
    }
}

/// One entry: its event, level, time and fields. Entries never contain a
/// password or an API key.
private struct LogEntryRow: View {
    let entry: LiveVoiceLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.event)
                    .font(.subheadline.monospaced().weight(.semibold))
                    .foregroundStyle(isError ? .red : .primary)
                Spacer()
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(fields)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
    }

    private var isError: Bool {
        switch entry.level {
        case .info: false
        case .error: true
        @unknown default: false
        }
    }

    private var fields: String {
        entry.fields
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
    }
}

#Preview {
    DemoStackNavigation {
        DiagnosticsScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
