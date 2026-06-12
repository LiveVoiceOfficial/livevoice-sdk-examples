import SwiftUI
import LiveVoiceSDK

struct AudioOutputPickerScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DemoScreenHeader(
                    title: "Audio output picker",
                    summary: "Place an audio output control wherever it fits in your app and bind it to the SDK. Here are three styles — all driving the same output."
                )

                DemoCardSection(title: "Live sample") {
                    LiveVoiceView()
                }

                DemoCardSection(title: "Output controls") {
                    VStack(alignment: .leading, spacing: 20) {
                        // The shared LiveVoice object exposes audioOutput; bind any control you like to it.
                        variant(
                            "Compact icons",
                            detail: "An icon-only segmented picker that stays compact."
                        ) {
                            CompactAudioOutputPicker()
                        }

                        variant(
                            "Pop-up menu",
                            detail: "A button that opens a menu — handy when space is tight."
                        ) {
                            MenuAudioOutputPicker()
                        }

                        variant(
                            "Toggle button",
                            detail: "A single button that flips straight to the other output."
                        ) {
                            ToggleAudioOutputButton()
                        }
                    }
                }

                DemoCardSection(title: "Implementation notes") {
                    DemoNoteList(
                        notes: [
                            "The iOS SDK exposes audioOutput on the shared LiveVoice object.",
                            "Every control here binds to that single value, so they all stay in sync.",
                            "Bind a picker, menu, or toggle to it wherever it makes sense in your screen.",
                        ]
                    )
                }

            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func variant(
        _ title: String,
        detail: String,
        @ViewBuilder control: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(detail)
                .font(.footnote)
                .foregroundStyle(.secondary)
            control()
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    DemoStackNavigation {
        AudioOutputPickerScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(
        joinCode: DemoFixture.joinCode,
        password: DemoFixture.password,
        apiKey: DemoFixture.apiKey
    )
}
