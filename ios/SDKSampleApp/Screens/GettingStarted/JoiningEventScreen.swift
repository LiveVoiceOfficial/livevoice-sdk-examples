// Joining an event
//
// `joinEvent` joins an event and returns once it is ready; joining again
// leaves the previous one. It returns a LiveVoiceJoinedEvent whose `leave()`
// leaves only that join. `connection` says where the connection is and
// `reconnect` reconnects at once. The demo joins the event picked in the
// toolbar at launch; here you make the calls yourself.
//
// Uses: LiveVoice.joinEvent(joinCode:password:apiKey:), LiveVoiceJoinedEvent.leave(),
// leaveEvent(), connection, reconnect()
// See also: Default interface, Custom view states (how LiveVoiceView shows each state).
// Docs: LiveVoiceSDK documentation › Getting Started

import SwiftUI
import LiveVoiceSDK

struct JoiningEventScreen: View {
    @EnvironmentObject private var demoSession: DemoSession
    @ObservedObject private var liveVoice: LiveVoice = .shared
    // The join made on this screen. A screen that owns its event would leave
    // it with `joined.leave()` in `.onDisappear`; this demo doesn't, because
    // every screen shares the event.
    @State private var joined: LiveVoiceJoinedEvent?
    @State private var failure: LiveVoiceError?

    var body: some View {
        DemoScreen("Joining an event", caption: "Join, reconnect and leave the event yourself.", error: failure) {
            DemoSection("Connection") {
                DemoValueRow("State", value: connectionState)
                DemoValueRow("Joined from this screen", value: joined == nil ? "No" : "Yes")
                HStack {
                    Button("Leave", role: .destructive) { Task { await leave() } }
                        .disabled(!canLeave)
                    Button("Join") { Task { await join() } }
                        .disabled(isBusy)
                    Button("Reconnect") { Task { await reconnect() } }
                        .disabled(!canReconnect)
                }
                .buttonStyle(.bordered)
            }
            DemoSection("Channels") {
                LiveVoiceView()
            }
        }
    }

    private var connectionState: String {
        switch liveVoice.connection {
        case .idle: "Idle"
        case .joining: "Joining"
        case let .ready(eventID): "Ready, event \(eventID)"
        // The SDK reconnects by itself; `reconnect()` tries at once.
        case .reconnecting: "Reconnecting"
        case .leaving: "Leaving"
        case let .failed(error): "Failed: \(error.message)"
        @unknown default: "Unknown"
        }
    }

    private var isBusy: Bool {
        switch liveVoice.connection {
        case .joining, .leaving: true
        default: false
        }
    }

    private var canLeave: Bool {
        switch liveVoice.connection {
        case .idle, .leaving: false
        default: true
        }
    }

    /// `reconnect()` works while the event is ready or reconnecting, and after
    /// a failure that `isRetryable`; otherwise it throws.
    private var canReconnect: Bool {
        switch liveVoice.connection {
        case .ready, .reconnecting: true
        case let .failed(error): error.isRetryable
        default: false
        }
    }

    /// Returns once the event is ready. Joining again leaves the previous event.
    private func join() async {
        // The join code, password and API key of the event picked in the toolbar.
        let event = demoSession.selectedPreset
        failure = nil
        // The new join replaces the old one, so forget the old one now: while
        // this join is pending or after it fails, Leave uses `leaveEvent()`.
        joined = nil
        do throws(LiveVoiceError) {
            joined = try await liveVoice.joinEvent(joinCode: event.joinCode, password: event.password, apiKey: event.apiKey)
        } catch {
            // A leave or a newer join ended this one; nothing went wrong.
            guard error.code != .cancelled, error.code != .superseded else { return }
            failure = error
        }
    }

    /// Works while the event is ready or reconnecting, and after a failure
    /// whose error `isRetryable`; the playing channel is restored.
    private func reconnect() async {
        failure = nil
        do throws(LiveVoiceError) {
            try await liveVoice.reconnect()
        } catch {
            // A newer join, switch or reconnect took over, or a leave ended
            // it; nothing went wrong.
            guard error.code != .cancelled, error.code != .superseded else { return }
            failure = error
        }
    }

    /// After a join on this screen, leaves only that join: never a newer
    /// one, such as after you pick another event in the toolbar (then it does
    /// nothing). Before it, leaves whatever is joined: here the event the
    /// toolbar joined.
    private func leave() async {
        failure = nil
        do throws(LiveVoiceError) {
            if let joined {
                try await joined.leave()
            } else {
                try await liveVoice.leaveEvent()
            }
            joined = nil
        } catch {
            failure = error
        }
    }
}

#Preview {
    DemoStackNavigation {
        JoiningEventScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
