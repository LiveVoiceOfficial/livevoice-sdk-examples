import SwiftUI

/// Renders the live subtitle fragment feed inside a fixed-height scroll view that
/// stays pinned to the most recent fragment as new ones arrive.
struct SubtitleFeedView: View {
    let fragments: [String]?
    let placeholder: String

    private static let bottomAnchor = "subtitle-feed-bottom"

    var body: some View {
        if let fragments, !fragments.isEmpty {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(fragments.enumerated()), id: \.offset) { index, fragment in
                            Text(fragment)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(index)
                        }
                        Color.clear
                            .frame(height: 1)
                            .id(Self.bottomAnchor)
                    }
                }
                .frame(height: 220)
                .demoOnChange(of: fragments.count) { _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(Self.bottomAnchor, anchor: .bottom)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        proxy.scrollTo(Self.bottomAnchor, anchor: .bottom)
                    }
                }
            }
        } else {
            Text(placeholder)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
