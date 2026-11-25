// Demo scaffolding — not needed for an integration.
//
// The look every demo screen shares, so that a screen's own file reads as
// LiveVoice SDK usage: the screen shell, the grouped sections and the one-line
// note on what a screen needs from the event.

import SwiftUI
import LiveVoiceSDK

/// A demo screen: a scrolling column of ``DemoSection``s under a title, with
/// a one-sentence caption.
///
/// `error` shows a failed call's message in one line under the caption, the
/// text the SDK provides for it. While subtitles are on, the screen links to
/// the Subtitles screen, unless it is the one that shows them (`showsSubtitles`).
struct DemoScreen<Content: View>: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared
    private let title: String
    private let caption: String
    private let error: LiveVoiceError?
    private let showsSubtitles: Bool
    private let content: Content

    init(
        _ title: String,
        caption: String,
        error: LiveVoiceError? = nil,
        showsSubtitles: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.caption = caption
        self.error = error
        self.showsSubtitles = showsSubtitles
        self.content = content()
    }

    private var subtitlesAreOn: Bool {
        if case .disabled = liveVoice.subtitles { return false }
        return true
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.largeTitle.weight(.semibold))
                    Text(caption)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                if let error {
                    DemoNote(error.message, systemImage: "exclamationmark.circle", tint: .red)
                }
                if subtitlesAreOn && !showsSubtitles {
                    NavigationLink {
                        SubtitlesScreen()
                    } label: {
                        DemoNote(
                            "Go to the Subtitles section to see them in action.",
                            systemImage: "captions.bubble",
                            tint: .accentColor
                        )
                    }
                }
                content
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .demoApiKeyToolbar(compactOnly: true)
    }
}

/// A titled, rounded box that groups part of a demo screen.
struct DemoSection<Content: View>: View {
    private let title: String
    private let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Above the box, like a grouped list's header, so it never reads
            // as part of the content.
            Text(title.uppercased())
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(demoSectionFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(.separator).opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}

private let demoSectionFill = Color(uiColor: UIColor { traits in
    traits.userInterfaceStyle == .dark
        ? .secondarySystemBackground
        : UIColor(red: 232 / 255, green: 232 / 255, blue: 237 / 255, alpha: 1)
})

/// What a demo screen needs beyond the demo event, said in one line while it
/// is missing, with a button to pick another event or API key. Until an event
/// is ready it says it waits instead: permissions and features are only
/// known once joined.
struct DemoRequirement: View {
    enum Need {
        /// An API key that permits custom UI: the "Full customization" preset.
        case customUI
        /// An event with `feature` enabled in the Admin console, which the
        /// demo event lacks. With your own event, the note says that this
        /// event doesn't have it enabled.
        case ownEvent(feature: String)
    }

    @EnvironmentObject private var demoSession: DemoSession
    @ObservedObject private var liveVoice: LiveVoice = .shared
    private let need: Need
    private let isMet: Bool

    init(_ need: Need, isMet: Bool) {
        self.need = need
        self.isMet = isMet
    }

    private var eventIsReady: Bool {
        switch liveVoice.connection {
        case .ready, .reconnecting: true
        case .idle, .joining, .leaving, .failed: false
        @unknown default: false
        }
    }

    var body: some View {
        if !eventIsReady {
            DemoNote("Waiting for the event…", systemImage: "hourglass", tint: .secondary)
        } else if !isMet {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 8) {
                    Text(text)
                        .font(.subheadline)
                    Button(buttonTitle, action: choose)
                        .font(.subheadline.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.orange.opacity(0.12))
            )
        }
    }

    private var text: String {
        switch need {
        case .customUI:
            "Needs an API key that permits custom UI."
        case let .ownEvent(feature):
            demoSession.usesOwnEvent
                ? "This event doesn't have the '\(feature)' feature enabled. Enable this in the Admin console on the web."
                : "The demo event doesn't have the '\(feature)' feature enabled. To try it, use your own event and enable the feature in the Admin console on the web."
        }
    }

    private var buttonTitle: String {
        switch need {
        case .customUI: "Choose an API key"
        case .ownEvent: demoSession.usesOwnEvent ? "Use another event" : "Use your own event"
        }
    }

    private func choose() {
        switch need {
        case .customUI: demoSession.eventSheet = .apiKeyPicker
        case .ownEvent: demoSession.eventSheet = .customCredentialsEditor
        }
    }
}

/// One line of information on a demo screen, with an icon.
struct DemoNote: View {
    private let text: String
    private let systemImage: String
    private let tint: Color

    init(_ text: String, systemImage: String, tint: Color) {
        self.text = text
        self.systemImage = systemImage
        self.tint = tint
    }

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.footnote)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A small outlined label for one of a channel's properties in a custom
/// cell: full contrast when `isOn`, faint when not, so every value stays
/// visible. Your app draws its own.
struct DemoTag: View {
    private let text: String
    private let isOn: Bool

    init(_ text: String, isOn: Bool = true) {
        self.text = text
        self.isOn = isOn
    }

    var body: some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .lineLimit(1)
            .foregroundStyle(Color.primary.opacity(isOn ? 1 : 0.3))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .overlay(Capsule().stroke(Color.primary.opacity(isOn ? 0.85 : 0.16), lineWidth: 0.5))
            .fixedSize()
    }
}
