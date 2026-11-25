// Language requests
//
// A listener can ask the event for a language it doesn't offer yet.
// `requestableLanguages` lists those languages with where each request
// stands; `requestLanguage` asks for one and `cancelLanguageRequest` takes
// the request back. Once the event fulfils a request, its new channel
// appears in LiveVoiceView like any other; the language is then `.available`.
//
// Needs: your own event with language requests enabled in the dashboard,
// and an API key that permits custom UI.
// Uses: LiveVoice.requestableLanguages, requestLanguage(_:), cancelLanguageRequest(_:)
// See also: Default interface (where a new channel appears).
// Docs: LiveVoiceSDK documentation › LiveVoice.requestLanguage(_:)

import SwiftUI
import LiveVoiceSDK

struct LanguageRequestsScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared
    @State private var failure: LiveVoiceError?

    var body: some View {
        DemoScreen("Language requests", caption: "Ask the event for a language it doesn't offer yet.", error: failure) {
            DemoRequirement(.customUI, isMet: liveVoice.customUiAllowed)
            // `nil`: the event takes no requests, or the API key doesn't permit
            // custom UI, which the note above covers.
            DemoRequirement(
                .ownEvent(feature: "Language requests"),
                isMet: !liveVoice.customUiAllowed || liveVoice.requestableLanguages != nil
            )
            DemoSection("Languages") {
                // `[]`: the event takes requests but has nothing to request.
                if liveVoice.requestableLanguages?.isEmpty == true {
                    DemoPlaceholder("The event offers no other languages to request right now.")
                }
                ForEach(liveVoice.requestableLanguages ?? [], id: \.languageCode) { language in
                    HStack {
                        Text(language.localizedName)
                        Spacer()
                        switch language.state {
                        case .requestable:
                            Button("Request") { Task { await request(language) } }
                        case .requested:
                            Button("Cancel request") { Task { await cancelRequest(language) } }
                        case .available:
                            Text("Added")
                        case .unavailable:
                            Text("Not available")
                        @unknown default:
                            // A state a later SDK version adds.
                            EmptyView()
                        }
                    }
                }
            }
        }
    }

    /// Returns once the event has the request; it may still decline it,
    /// which `requestableLanguages` then shows.
    private func request(_ language: LiveVoiceRequestableLanguage) async {
        failure = nil
        do throws(LiveVoiceError) {
            try await liveVoice.requestLanguage(language.languageCode)
        } catch {
            failure = error
        }
    }

    private func cancelRequest(_ language: LiveVoiceRequestableLanguage) async {
        failure = nil
        do throws(LiveVoiceError) {
            try await liveVoice.cancelLanguageRequest(language.languageCode)
        } catch {
            failure = error
        }
    }
}

#Preview {
    DemoStackNavigation {
        LanguageRequestsScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
