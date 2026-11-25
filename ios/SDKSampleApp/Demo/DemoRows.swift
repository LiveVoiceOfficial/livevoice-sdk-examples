// Demo scaffolding — not needed for an integration.
// Rows that show a value inside a ``DemoSection``, each a single line at its use site.

import SwiftUI

/// A label with its value on the trailing side.
struct DemoValueRow: View {
    private let label: String
    private let value: String

    init(_ label: String, value: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

/// A name from the code, set in monospace, above the text it stands for.
struct DemoTextRow: View {
    private let name: String
    private let text: String

    init(_ name: String, _ text: String) {
        self.name = name
        self.text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
        }
    }
}

/// A secondary line that stands in for content that isn't there yet.
struct DemoPlaceholder: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A small label above a view of your own, such as one of a screen's sample views.
struct DemoLabeled<Content: View>: View {
    private let label: String
    private let content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
