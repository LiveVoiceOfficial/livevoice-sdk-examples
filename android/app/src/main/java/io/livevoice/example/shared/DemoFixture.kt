package io.livevoice.example.shared

import androidx.compose.runtime.saveable.Saver

data class DemoApiKeyPreset(
    val title: String,
    val summary: String,
    val joinCode: String,
    val password: String?,
    val apiKey: String,
    val isCustom: Boolean = false,
) {
    companion object {
        val Saver: Saver<DemoApiKeyPreset, String> = Saver(
            save = { it.title },
            restore = { title ->
                DemoFixture.apiKeyPresets.firstOrNull { it.title == title } ?: DemoFixture.defaultPreset
            }
        )
    }
}

/**
 * User-entered credentials for the "Use your own event" picker option. Persisted
 * so the editor pre-fills on reopen; see [DemoSession].
 */
data class DemoCredentials(
    val joinCode: String,
    /** Empty string means "no password"; some events are password-protected. */
    val password: String,
    val apiKey: String,
)

object DemoFixture {
    const val joinCode = "123456"
    val password: String? = null

    val defaultPreset = DemoApiKeyPreset(
        title = "Default",
        summary = "Branding visible, custom UI disabled.",
        joinCode = joinCode,
        password = password,
        apiKey = "HD4cQklUOQKOBWimG54j2kRnxFklDL"
    )

    val hideBrandingPreset = DemoApiKeyPreset(
        title = "Hide branding",
        summary = "Branding hidden, custom UI disabled.",
        joinCode = joinCode,
        password = password,
        apiKey = "uFlkcGkUJEcb7jK6qFcdygreFRTXVh"
    )

    val allClaimsPreset = DemoApiKeyPreset(
        title = "Full customization",
        summary = "Branding hidden, custom UI enabled.",
        joinCode = joinCode,
        password = password,
        apiKey = "s09WEG5y3caQ6R2PDaG4i8R1aTooTd"
    )

    val apiKeyPresets = listOf(
        defaultPreset,
        hideBrandingPreset,
        allClaimsPreset
    )

    /**
     * Builds the dynamic preset selected when a tester enters their own event
     * credentials. An empty password is treated as "no password".
     */
    fun customPreset(credentials: DemoCredentials): DemoApiKeyPreset =
        DemoApiKeyPreset(
            title = "Your own event",
            summary = "Join code ${credentials.joinCode} with your own API key.",
            joinCode = credentials.joinCode,
            password = credentials.password.ifEmpty { null },
            apiKey = credentials.apiKey,
            isCustom = true
        )
}
