import SwiftUI
import UIKit

struct DemoCardSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    Color(
                        uiColor: UIColor { traits in
                            switch traits.userInterfaceStyle {
                            case .dark:
                                .secondarySystemBackground
                            default:
                                UIColor(red: 232 / 255, green: 232 / 255, blue: 237 / 255, alpha: 1)
                            }
                        }
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.separator).opacity(0.08), lineWidth: 1)
                )
        )
    }
}
