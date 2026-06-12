import SwiftUI
import LiveVoiceSDK

struct CustomErrorCard: View {
    let error: LiveVoiceSDKError
    let retry: (() async -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(error.localizedDescription, bundle: .liveVoiceSDK)
                .font(.subheadline.weight(.semibold))

            if let retry {
                Button("Retry now") {
                    Task {
                        await retry()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}
