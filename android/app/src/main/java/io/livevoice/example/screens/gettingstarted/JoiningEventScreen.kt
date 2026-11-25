// Joining an event
//
// `joinEvent` joins an event and returns once it is ready; joining again
// leaves the previous one. It returns a LiveVoiceJoinedEvent whose `leave()`
// leaves only that join. `connection` says where the connection is and
// `reconnect` reconnects at once. The demo joins the event picked in the
// toolbar at launch; here you make the calls yourself.
//
// On Android these are suspend functions and `connection` is a StateFlow.
// Cancelling the coroutine of a pending `joinEvent` cancels that join, so the
// calls here run in the app's scope, not the screen's: leaving the screen
// would otherwise cancel a join that is still on its way. A finished join
// outlives its coroutine; only `leave()` or `leaveEvent()` ends it.
//
// Uses: LiveVoice.joinEvent(joinCode, password, apiKey), LiveVoiceJoinedEvent.leave(),
// leaveEvent(), connection, reconnect()
// See also: Default interface, Custom view states (how LiveVoiceView shows each state).

package io.livevoice.example.screens.gettingstarted

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import io.livevoice.example.applicationScope
import io.livevoice.example.demo.DemoButton
import io.livevoice.example.demo.DemoButtonRow
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.DemoValueRow
import io.livevoice.example.demo.LocalDemoSession
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceConnection
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceErrorCode
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceJoinedEvent
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.launch

@Composable
fun JoiningEventScreen() {
    val demoSession = LocalDemoSession.current
    val connection by LiveVoice.connection.collectAsState()
    // The join made on this screen. A screen that owns its event would leave
    // it with `joined.leave()` when it goes away, in a scope that outlives
    // the screen; this demo doesn't, because every screen shares the event.
    var joined by remember { mutableStateOf<LiveVoiceJoinedEvent?>(null) }
    var failure by remember { mutableStateOf<LiveVoiceException?>(null) }

    /** Returns once the event is ready. Joining again leaves the previous event. */
    suspend fun join() {
        // The join code, password and API key of the event picked in the toolbar.
        val event = demoSession.selectedPreset
        failure = null
        // The new join replaces the old one, so forget the old one now: while
        // this join is pending or after it fails, Leave uses `leaveEvent()`.
        joined = null
        try {
            joined = LiveVoice.joinEvent(joinCode = event.joinCode, password = event.password, apiKey = event.apiKey)
        } catch (error: LiveVoiceException) {
            // A leave or a newer join ended this one; nothing went wrong.
            if (error.code == LiveVoiceErrorCode.CANCELLED || error.code == LiveVoiceErrorCode.SUPERSEDED) return
            failure = error
        }
    }

    /**
     * Works while the event is ready or reconnecting, and after a failure
     * whose error `isRetryable`; the playing channel is restored.
     */
    suspend fun reconnect() {
        failure = null
        try {
            LiveVoice.reconnect()
        } catch (error: LiveVoiceException) {
            // A newer join, switch or reconnect took over, or a leave ended
            // it; nothing went wrong.
            if (error.code == LiveVoiceErrorCode.CANCELLED || error.code == LiveVoiceErrorCode.SUPERSEDED) return
            failure = error
        }
    }

    /**
     * After a join on this screen, leaves only that join: never a newer
     * one, such as after you pick another event in the toolbar (then it does
     * nothing). Before it, leaves whatever is joined: here the event the
     * toolbar joined.
     */
    suspend fun leave() {
        failure = null
        try {
            val join = joined
            if (join != null) {
                join.leave()
            } else {
                LiveVoice.leaveEvent()
            }
            joined = null
        } catch (error: LiveVoiceException) {
            failure = error
        }
    }

    DemoScreen("Joining an event", caption = "Join, reconnect and leave the event yourself.", error = failure) {
        DemoSection("Connection") {
            DemoValueRow("State", connectionState(connection))
            DemoValueRow("Joined from this screen", if (joined == null) "No" else "Yes")
            DemoButtonRow {
                DemoButton("Leave", enabled = canLeave(connection), destructive = true) { applicationScope.launch { leave() } }
                DemoButton("Join", enabled = !isBusy(connection)) { applicationScope.launch { join() } }
                DemoButton("Reconnect", enabled = canReconnect(connection)) { applicationScope.launch { reconnect() } }
            }
        }
        DemoSection("Channels") {
            LiveVoiceView()
        }
    }
}

private fun connectionState(connection: LiveVoiceConnection): String = when (connection) {
    LiveVoiceConnection.Idle -> "Idle"
    LiveVoiceConnection.Joining -> "Joining"
    is LiveVoiceConnection.Ready -> "Ready, event ${connection.eventId}"
    // The SDK reconnects by itself; `reconnect()` tries at once.
    is LiveVoiceConnection.Reconnecting -> "Reconnecting"
    LiveVoiceConnection.Leaving -> "Leaving"
    is LiveVoiceConnection.Failed -> "Failed: ${connection.error.message}"
    else -> "Unknown"
}

private fun isBusy(connection: LiveVoiceConnection): Boolean =
    connection is LiveVoiceConnection.Joining || connection is LiveVoiceConnection.Leaving

private fun canLeave(connection: LiveVoiceConnection): Boolean =
    connection !is LiveVoiceConnection.Idle && connection !is LiveVoiceConnection.Leaving

/**
 * `reconnect()` works while the event is ready or reconnecting, and after
 * a failure that `isRetryable`; otherwise it throws.
 */
private fun canReconnect(connection: LiveVoiceConnection): Boolean = when (connection) {
    is LiveVoiceConnection.Ready, is LiveVoiceConnection.Reconnecting -> true
    is LiveVoiceConnection.Failed -> connection.error.isRetryable
    else -> false
}
