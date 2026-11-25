// Demo scaffolding — not needed for an integration.
// A row of the home list.

import SwiftUI

/// A row of the demo list. `needsOwnEvent` tags a demo that the demo event
/// cannot show, so nobody opens it and wonders why nothing happens.
struct DemoListRow: View {
    let title: String
    let summary: String
    var needsOwnEvent = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                if needsOwnEvent {
                    Text("Own event")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.orange.opacity(0.15)))
                }
            }
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
