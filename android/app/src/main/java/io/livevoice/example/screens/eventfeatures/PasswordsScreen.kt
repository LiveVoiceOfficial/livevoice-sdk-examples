// Password-protected channels
//
// A protected channel needs its password when it starts. Without any setup,
// the SDK asks with its own prompt and remembers the password until the app
// quits. `passwordProvider` asks with your own UI instead, and
// `passwordStore` keeps passwords longer: the SDK asks it first, saves a
// password the server accepted and removes one it rejected.
//
// On Android both are interfaces with suspend functions, and the SDK calls
// them off the main thread: switch to the main thread before you touch UI
// state. The SDK cancels the provider's call when it no longer needs the
// answer, for example after a leave: close your prompt then. The SDK's own
// prompt shows in the most recently shown LiveVoiceView still on screen;
// without one on screen, a request gives up. "Until the app quits" means
// until the process ends.
//
// Needs: your own event with a password on a channel.
// Uses: LiveVoice.passwordProvider, passwordStore, LiveVoicePasswordProvider,
// LiveVoicePasswordStore, LiveVoicePasswordRequest, LiveVoicePasswordSubject
// See also: Subtitles (a protected channel's subtitles use the same password).

package io.livevoice.example.screens.eventfeatures

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import io.livevoice.example.demo.DemoNeed
import io.livevoice.example.demo.DemoNote
import io.livevoice.example.demo.DemoNoteKind
import io.livevoice.example.demo.DemoPlaceholder
import io.livevoice.example.demo.DemoRequirement
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.LocalDemoSession
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoicePasswordProvider
import io.livevoice.sdk.android.publicApi.core.model.LiveVoicePasswordRequest
import io.livevoice.sdk.android.publicApi.core.model.LiveVoicePasswordStore
import io.livevoice.sdk.android.publicApi.core.model.LiveVoicePasswordSubject
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@Composable
fun PasswordsScreen() {
    val demoSession = LocalDemoSession.current
    val prompt = remember { PasswordPrompt() }
    val store = remember { MemoryPasswordStore() }

    // A real app sets both once, at launch. This screen sets them only
    // while it shows, so the other screens keep the SDK's own prompt.
    DisposableEffect(prompt, store) {
        LiveVoice.passwordProvider = LiveVoicePasswordProvider { request -> prompt.ask(request) }
        LiveVoice.passwordStore = store
        onDispose {
            LiveVoice.passwordProvider = null
            LiveVoice.passwordStore = null
            // A request still open gets its answer: the SDK would wait for it.
            prompt.giveUp()
        }
    }

    DemoScreen("Password-protected channels", caption = "Ask for channel passwords with your own UI, and keep them.") {
        // The SDK lists an event's channels only in LiveVoiceView, so the note
        // can only tell the demo event apart.
        DemoRequirement(DemoNeed.OwnEvent("Password-protected channels"), isMet = demoSession.usesOwnEvent)
        DemoSection("Channels") {
            // The SDK keeps an accepted password in memory for the app's run
            // and forgets one only when the server rejects it. Starting a
            // protected channel looks in memory, then asks the store, then
            // the provider.
            DemoNote(
                "Once a password is accepted, the SDK remembers it until the app quits and won't ask again. Restart the app to see the prompt again.",
                DemoNoteKind.Info,
            )
            LiveVoiceView()
        }
        DemoSection("Saved passwords") {
            if (store.passwords.isEmpty()) {
                DemoPlaceholder("None yet: play a protected channel.")
            }
            store.passwords.keys.forEach { subject ->
                Text(description(subject), style = MaterialTheme.typography.bodyLarge)
            }
        }
    }

    // Each dialog answers its own request: a retry after a wrong password
    // arrives as a new request with a fresh dialog.
    prompt.pending?.let { pending ->
        key(pending) {
            PasswordPromptDialog(pending.request) { password -> prompt.answer(pending, password) }
        }
    }
}

private fun description(subject: LiveVoicePasswordSubject): String = when (subject) {
    is LiveVoicePasswordSubject.Channel -> "Channel ${subject.channelId} of event ${subject.joinCode}"
    is LiveVoicePasswordSubject.Event -> "Event ${subject.joinCode}"
    else -> "Password"
}

/** Hands the SDK's password requests to your UI and waits for the answer. */
private class PasswordPrompt {
    /** The request the dialog shows, with the way to answer it. */
    class Pending(val request: LiveVoicePasswordRequest, val answer: CompletableDeferred<String?>)

    var pending by mutableStateOf<Pending?>(null)
        private set

    /**
     * The provider: returns the password, or `null` to give up, which fails
     * the start with `CHANNEL_PASSWORD_REQUIRED`.
     */
    suspend fun ask(request: LiveVoicePasswordRequest): String? = withContext(Dispatchers.Main) {
        // A newer request replaces one still open, which gives up.
        pending?.answer?.complete(null)
        val next = Pending(request, CompletableDeferred())
        pending = next
        try {
            next.answer.await()
        } finally {
            // Answered, or the SDK cancelled the request: close the dialog.
            if (pending === next) pending = null
        }
    }

    /** Gives up the open request, if there is one. */
    fun giveUp() {
        pending?.let { answer(it, null) }
    }

    /** Answers [request]. A late answer to an older request does nothing. */
    fun answer(request: Pending, password: String?) {
        if (pending === request) pending = null
        request.answer.complete(password)
    }
}

/**
 * Your own password prompt. `isRetry` is `true` after a rejected password.
 * Back and a tap outside count as Cancel, so every request gets its answer.
 */
@Composable
private fun PasswordPromptDialog(request: LiveVoicePasswordRequest, answer: (String?) -> Unit) {
    var password by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = { answer(null) },
        title = { Text("Password") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Password") },
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    modifier = Modifier.fillMaxWidth(),
                )
                if (request.isRetry) {
                    Text("Wrong password. Try again.", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.error)
                }
            }
        },
        confirmButton = {
            TextButton(onClick = { answer(password) }, enabled = password.isNotEmpty()) { Text("Listen") }
        },
        dismissButton = {
            TextButton(onClick = { answer(null) }) { Text("Cancel") }
        },
    )
}

/**
 * Keeps passwords in memory, keyed by what they belong to. A real app keeps
 * them securely, for example encrypted with a key from the Android Keystore,
 * so they outlive the app. Storing is best effort: an error you throw is
 * logged and fails nothing.
 */
private class MemoryPasswordStore : LiveVoicePasswordStore {
    val passwords = mutableStateMapOf<LiveVoicePasswordSubject, String>()

    override suspend fun load(subject: LiveVoicePasswordSubject): String? = withContext(Dispatchers.Main) {
        passwords[subject]
    }

    override suspend fun save(subject: LiveVoicePasswordSubject, password: String) {
        withContext(Dispatchers.Main) { passwords[subject] = password }
    }

    override suspend fun remove(subject: LiveVoicePasswordSubject) {
        withContext(Dispatchers.Main) { passwords.remove(subject) }
    }
}
