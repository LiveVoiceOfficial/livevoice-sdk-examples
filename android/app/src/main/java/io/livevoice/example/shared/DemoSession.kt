package io.livevoice.example.shared

import android.content.Context
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class DemoSession(
    private val scope: CoroutineScope,
    context: Context,
    initialPreset: DemoApiKeyPreset = DemoFixture.defaultPreset,
) {
    private val prefs = context.applicationContext
        .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private val _selectedPreset = MutableStateFlow(initialPreset)
    val selectedPreset: StateFlow<DemoApiKeyPreset> = _selectedPreset.asStateFlow()

    // Last credentials a tester entered via "Use your own event".
    private val _customCredentials = MutableStateFlow(loadCustomCredentials())
    val customCredentials: StateFlow<DemoCredentials?> = _customCredentials.asStateFlow()

    private var joinJob: Job? = null

    fun start() {
        joinSelectedPreset(_selectedPreset.value)
    }

    fun select(preset: DemoApiKeyPreset) {
        if (preset == _selectedPreset.value) return
        _selectedPreset.value = preset
        joinSelectedPreset(preset)
    }

    /**
     * Applies credentials entered in the editor: persists them, selects the
     * custom event, and (re)joins. An empty password means "no password".
     */
    fun applyCustomCredentials(credentials: DemoCredentials) {
        _customCredentials.value = credentials
        persistCustomCredentials(credentials)
        select(DemoFixture.customPreset(credentials))
    }

    fun stop() {
        joinJob?.cancel()
        joinJob = null
        LiveVoice.leaveEvent()
    }

    private fun joinSelectedPreset(preset: DemoApiKeyPreset) {
        joinJob?.cancel()
        LiveVoice.leaveEvent()

        joinJob = scope.launch {
            LiveVoice.joinEvent(
                joinCode = preset.joinCode,
                password = preset.password,
                apiKey = preset.apiKey
            )
        }
    }

    private fun persistCustomCredentials(credentials: DemoCredentials) {
        prefs.edit()
            .putString(KEY_JOIN_CODE, credentials.joinCode)
            .putString(KEY_PASSWORD, credentials.password)
            .putString(KEY_API_KEY, credentials.apiKey)
            .apply()
    }

    private fun loadCustomCredentials(): DemoCredentials? {
        val joinCode = prefs.getString(KEY_JOIN_CODE, null) ?: return null
        val apiKey = prefs.getString(KEY_API_KEY, null) ?: return null
        val password = prefs.getString(KEY_PASSWORD, "").orEmpty()
        return DemoCredentials(joinCode = joinCode, password = password, apiKey = apiKey)
    }

    private companion object {
        const val PREFS_NAME = "demo_session"
        const val KEY_JOIN_CODE = "custom_join_code"
        const val KEY_PASSWORD = "custom_password"
        const val KEY_API_KEY = "custom_api_key"
    }
}
