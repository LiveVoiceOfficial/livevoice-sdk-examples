// Linked events
//
// An event can be linked to others, for example the rooms of a conference.
// `linkedEvents` lists them, and `switchToLinkedEvent` leaves the joined
// event and joins the linked one with the same API key. LiveVoiceView then
// shows the new event's channels.
//
// Needs: your own event with another event linked to it in the dashboard,
// and an API key that permits custom UI.
// Uses: LiveVoice.linkedEvents, switchToLinkedEvent(_:), currentEvent, LiveVoiceLinkedEvent
// See also: Joining an event.
// Docs: LiveVoiceSDK documentation › LiveVoice.switchToLinkedEvent(_:)

import SwiftUI
import LiveVoiceSDK

struct LinkedEventsScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared
    @State private var failure: LiveVoiceError?

    var body: some View {
        DemoScreen("Linked events", caption: "Switch to an event linked to this one.", error: failure) {
            DemoRequirement(.customUI, isMet: liveVoice.customUiAllowed)
            // `nil`: no event is ready, or the API key doesn't permit custom
            // UI, which the note above covers.
            DemoRequirement(
                .ownEvent(feature: "Linked events"),
                isMet: !liveVoice.customUiAllowed || liveVoice.linkedEvents?.isEmpty == false
            )
            DemoSection("Events") {
                DemoValueRow("Joined", value: liveVoice.currentEvent?.name ?? "None")
                ForEach(liveVoice.linkedEvents ?? [], id: \.eventID) { event in
                    HStack {
                        Text(event.name)
                        Spacer()
                        Button("Switch") { Task { await switchTo(event) } }
                    }
                }
            }
            DemoSection("Channels") {
                LiveVoiceView()
            }
        }
    }

    /// Returns once the linked event is ready. A failed switch doesn't return
    /// to the previous event; `reconnect()` tries the linked event again.
    private func switchTo(_ event: LiveVoiceLinkedEvent) async {
        failure = nil
        do throws(LiveVoiceError) {
            try await liveVoice.switchToLinkedEvent(event)
        } catch {
            // A leave or a newer join or switch ended this one.
            guard error.code != .cancelled, error.code != .superseded else { return }
            failure = error
        }
    }
}

#Preview {
    DemoStackNavigation {
        LinkedEventsScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
