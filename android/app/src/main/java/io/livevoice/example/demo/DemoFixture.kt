// Demo scaffolding — not needed for an integration.
// The demo event's join code, its three API keys, and your own event's credentials.

package io.livevoice.example.demo

data class DemoApiKeyPreset(
    val id: String,
    val title: String,
    val summary: String,
    val joinCode: String,
    val password: String?,
    val apiKey: String,
)

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
    const val JOIN_CODE = "123456"
    val password: String? = null

    /**
     * Identifies the dynamic "Use your own event" selection (built from
     * user-entered [DemoCredentials], not part of [apiKeyPresets]).
     */
    const val CUSTOM_PRESET_ID = "custom"

    val defaultPreset = DemoApiKeyPreset(
        id = "default",
        title = "Default",
        summary = "Branding visible, custom UI disabled.",
        joinCode = JOIN_CODE,
        password = password,
        apiKey = "HD4cQklUOQKOBWimG54j2kRnxFklDL",
    )

    val hideBrandingPreset = DemoApiKeyPreset(
        id = "hide-branding",
        title = "Hide branding",
        summary = "Branding hidden, custom UI disabled.",
        joinCode = JOIN_CODE,
        password = password,
        apiKey = "uFlkcGkUJEcb7jK6qFcdygreFRTXVh",
    )

    val fullCustomizationPreset = DemoApiKeyPreset(
        id = "full-customization",
        title = "Full customization",
        summary = "Branding hidden, custom UI enabled.",
        joinCode = JOIN_CODE,
        password = password,
        apiKey = "s09WEG5y3caQ6R2PDaG4i8R1aTooTd",
    )

    val apiKeyPresets = listOf(
        defaultPreset,
        hideBrandingPreset,
        fullCustomizationPreset,
    )

    /**
     * Builds the dynamic preset selected when a tester enters their own event
     * credentials. An empty password is treated as "no password".
     */
    fun customPreset(credentials: DemoCredentials) = DemoApiKeyPreset(
        id = CUSTOM_PRESET_ID,
        title = "Your own event",
        summary = "Join code ${credentials.joinCode} with your own API key.",
        joinCode = credentials.joinCode,
        password = credentials.password.ifEmpty { null },
        apiKey = credentials.apiKey,
    )
}
