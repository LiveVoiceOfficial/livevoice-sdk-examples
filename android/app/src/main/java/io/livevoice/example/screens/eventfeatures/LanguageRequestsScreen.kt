// Language requests
//
// A listener can ask the event for a language it doesn't offer yet.
// `requestableLanguages` lists those languages with where each request
// stands; `requestLanguage` asks for one and `cancelLanguageRequest` takes
// the request back. Once the event fulfils a request, its new channel
// appears in LiveVoiceView like any other; the language is then AVAILABLE.
//
// On Android `requestableLanguages` is a StateFlow. Cancelling the call's
// coroutine, as leaving this screen does, only stops the waiting: the
// request stays.
//
// Needs: your own event with language requests enabled in the dashboard,
// and an API key that permits custom UI.
// Uses: LiveVoice.requestableLanguages, requestLanguage(languageCode),
// cancelLanguageRequest(languageCode)
// See also: Default interface (where a new channel appears).

package io.livevoice.example.screens.eventfeatures

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import io.livevoice.example.demo.DemoItemRow
import io.livevoice.example.demo.DemoNeed
import io.livevoice.example.demo.DemoPlaceholder
import io.livevoice.example.demo.DemoRequirement
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceLanguageRequestState
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceRequestableLanguage
import kotlinx.coroutines.launch

@Composable
fun LanguageRequestsScreen() {
    val customUiAllowed by LiveVoice.customUiAllowed.collectAsState()
    val requestableLanguages by LiveVoice.requestableLanguages.collectAsState()
    var failure by remember { mutableStateOf<LiveVoiceException?>(null) }
    val scope = rememberCoroutineScope()

    /**
     * Returns once the event has the request; it may still decline it,
     * which `requestableLanguages` then shows.
     */
    suspend fun request(language: LiveVoiceRequestableLanguage) {
        failure = null
        try {
            LiveVoice.requestLanguage(language.languageCode)
        } catch (error: LiveVoiceException) {
            failure = error
        }
    }

    suspend fun cancelRequest(language: LiveVoiceRequestableLanguage) {
        failure = null
        try {
            LiveVoice.cancelLanguageRequest(language.languageCode)
        } catch (error: LiveVoiceException) {
            failure = error
        }
    }

    DemoScreen("Language requests", caption = "Ask the event for a language it doesn't offer yet.", error = failure) {
        DemoRequirement(DemoNeed.CustomUi, isMet = customUiAllowed)
        // `null`: the event takes no requests, or the API key doesn't permit
        // custom UI, which the note above covers.
        DemoRequirement(DemoNeed.OwnEvent("Language requests"), isMet = !customUiAllowed || requestableLanguages != null)
        DemoSection("Languages") {
            // Empty: the event takes requests but has nothing to request.
            if (requestableLanguages?.isEmpty() == true) {
                DemoPlaceholder("The event offers no other languages to request right now.")
            }
            requestableLanguages.orEmpty().forEach { language ->
                key(language.languageCode) {
                    DemoItemRow(language.localizedName) {
                        when (language.state) {
                            LiveVoiceLanguageRequestState.REQUESTABLE ->
                                TextButton(onClick = { scope.launch { request(language) } }) { Text("Request") }
                            LiveVoiceLanguageRequestState.REQUESTED ->
                                TextButton(onClick = { scope.launch { cancelRequest(language) } }) { Text("Cancel request") }
                            LiveVoiceLanguageRequestState.AVAILABLE ->
                                Text("Added", style = MaterialTheme.typography.bodyMedium)
                            LiveVoiceLanguageRequestState.UNAVAILABLE ->
                                Text("Not available", style = MaterialTheme.typography.bodyMedium)
                            else -> {
                                // A state a later SDK version adds.
                            }
                        }
                    }
                }
            }
        }
    }
}
