// Linked events
//
// An event can be linked to others, for example the rooms of a conference.
// `linkedEvents` lists them, and `switchToLinkedEvent` leaves the joined
// event and joins the linked one with the same API key. LiveVoiceView then
// shows the new event's channels.
//
// On Android the switch is a suspend function that leaves the current event
// at once. Cancelling its coroutine cancels the switch and leaves no event,
// so it runs in the app's scope, not the screen's.
//
// Needs: your own event with another event linked to it in the dashboard,
// and an API key that permits custom UI.
// Uses: LiveVoice.linkedEvents, switchToLinkedEvent(event), currentEvent, LiveVoiceLinkedEvent
// See also: Joining an event.

package io.livevoice.example.screens.eventfeatures

import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import io.livevoice.example.applicationScope
import io.livevoice.example.demo.DemoItemRow
import io.livevoice.example.demo.DemoNeed
import io.livevoice.example.demo.DemoRequirement
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.DemoValueRow
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceErrorCode
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceLinkedEvent
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.launch

@Composable
fun LinkedEventsScreen() {
    val customUiAllowed by LiveVoice.customUiAllowed.collectAsState()
    val linkedEvents by LiveVoice.linkedEvents.collectAsState()
    val currentEvent by LiveVoice.currentEvent.collectAsState()
    var failure by remember { mutableStateOf<LiveVoiceException?>(null) }

    /**
     * Returns once the linked event is ready. A failed switch doesn't return
     * to the previous event; `reconnect()` tries the linked event again.
     */
    suspend fun switchTo(event: LiveVoiceLinkedEvent) {
        failure = null
        try {
            LiveVoice.switchToLinkedEvent(event)
        } catch (error: LiveVoiceException) {
            // A leave or a newer join or switch ended this one.
            if (error.code == LiveVoiceErrorCode.CANCELLED || error.code == LiveVoiceErrorCode.SUPERSEDED) return
            failure = error
        }
    }

    DemoScreen("Linked events", caption = "Switch to an event linked to this one.", error = failure) {
        DemoRequirement(DemoNeed.CustomUi, isMet = customUiAllowed)
        // `null`: no event is ready, or the API key doesn't permit custom
        // UI, which the note above covers.
        DemoRequirement(DemoNeed.OwnEvent("Linked events"), isMet = !customUiAllowed || linkedEvents?.isEmpty() == false)
        DemoSection("Events") {
            DemoValueRow("Joined", currentEvent?.name ?: "None")
            linkedEvents.orEmpty().forEach { event ->
                key(event.eventId) {
                    DemoItemRow(event.name) {
                        TextButton(onClick = { applicationScope.launch { switchTo(event) } }) { Text("Switch") }
                    }
                }
            }
        }
        DemoSection("Channels") {
            LiveVoiceView()
        }
    }
}
