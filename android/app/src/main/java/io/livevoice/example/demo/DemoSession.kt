// Demo scaffolding — not needed for an integration.
// Joins the event picked in the toolbar once the app shows, and whenever the pick changes.

package io.livevoice.example.demo

import android.content.Context
import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.core.content.edit
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceErrorCode
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceException
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

/**
 * The demo's event picker state. It belongs to the process, not to an Activity: the join outlives
 * a recreated Activity, and the pick survives process death so a restored screen shows the same
 * event.
 */
class DemoSession(context: Context) {
    private val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    /** Last credentials a tester entered via "Use your own event". */
    var customCredentials by mutableStateOf(loadCustomCredentials())
        private set

    var selectedPreset by mutableStateOf(loadSelectedPreset())
        private set

    /** Drives the app-level API key picker sheet. */
    var isApiKeyPickerPresented by mutableStateOf(false)

    /** Drives the "Use your own event" credentials editor. */
    var isCustomCredentialsEditorPresented by mutableStateOf(false)

    /** Whether the picked event is your own rather than the demo event. */
    val usesOwnEvent: Boolean get() = selectedPreset.id == DemoFixture.CUSTOM_PRESET_ID

    private val scope = MainScope()
    private var joinJob: Job? = null
    private var started = false

    /** Joins the picked event the first time the app shows; later calls do nothing. */
    fun start() {
        if (started) return
        started = true
        joinSelectedPreset()
    }

    fun select(preset: DemoApiKeyPreset) {
        if (preset == selectedPreset) return
        selectedPreset = preset
        prefs.edit { putString(KEY_PRESET, preset.id) }
        joinSelectedPreset()
    }

    /** Joins the picked event again, after something left it. */
    fun rejoin() = joinSelectedPreset()

    /** Called from the picker's "Use your own event" row. */
    fun requestCustomCredentialsEditor() {
        isApiKeyPickerPresented = false
        isCustomCredentialsEditorPresented = true
    }

    /**
     * Applies credentials entered in the editor: persists them, selects the
     * custom event, and (re)joins. An empty password means "no password".
     */
    fun applyCustomCredentials(credentials: DemoCredentials) {
        customCredentials = credentials
        prefs.edit {
            putString(KEY_JOIN_CODE, credentials.joinCode)
            putString(KEY_PASSWORD, credentials.password)
            putString(KEY_API_KEY, credentials.apiKey)
        }
        select(DemoFixture.customPreset(credentials))
    }

    private fun joinSelectedPreset() {
        joinJob?.cancel()
        val preset = selectedPreset
        joinJob = scope.launch {
            try {
                LiveVoice.joinEvent(joinCode = preset.joinCode, password = preset.password, apiKey = preset.apiKey)
            } catch (error: LiveVoiceException) {
                // The SDK view displays connection failures. Never log credentials.
                if (error.code != LiveVoiceErrorCode.CANCELLED && error.code != LiveVoiceErrorCode.SUPERSEDED) {
                    Log.w(TAG, "LiveVoice join failed: ${error.code}")
                }
            }
        }
    }

    private fun loadSelectedPreset(): DemoApiKeyPreset {
        val id = prefs.getString(KEY_PRESET, null)
        val credentials = customCredentials
        if (id == DemoFixture.CUSTOM_PRESET_ID && credentials != null) return DemoFixture.customPreset(credentials)
        return DemoFixture.apiKeyPresets.firstOrNull { it.id == id } ?: DemoFixture.defaultPreset
    }

    private fun loadCustomCredentials(): DemoCredentials? {
        val joinCode = prefs.getString(KEY_JOIN_CODE, null) ?: return null
        val apiKey = prefs.getString(KEY_API_KEY, null) ?: return null
        return DemoCredentials(joinCode = joinCode, password = prefs.getString(KEY_PASSWORD, null).orEmpty(), apiKey = apiKey)
    }

    private companion object {
        const val TAG = "LiveVoiceSample"
        const val PREFS_NAME = "demo_session"
        const val KEY_PRESET = "selected_preset"
        const val KEY_JOIN_CODE = "custom_join_code"
        const val KEY_PASSWORD = "custom_password"
        const val KEY_API_KEY = "custom_api_key"
    }
}

/** The app's [DemoSession], for the demo views that need it. */
val LocalDemoSession = staticCompositionLocalOf<DemoSession> { error("No DemoSession provided") }
