import SwiftUI
import LiveVoiceSDK

struct CustomReconnectCard: View {
    let state: LiveVoice.ViewState.ReconnectState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch state {
            case .retrying:
                Text(LiveVoiceLocalization.error_screen_retrying)
                    .font(.subheadline.weight(.semibold))
            case let .waiting(until):
                Text("Reconnecting in \(Text(until, style: .relative))")
                    .font(.subheadline.weight(.semibold))
            @unknown default:
                Text(LiveVoiceLocalization.error_screen_retrying)
                    .font(.subheadline.weight(.semibold))
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
