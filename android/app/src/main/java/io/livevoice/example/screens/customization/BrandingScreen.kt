// Branding and entitlements
//
// What an API key may do is set for your account. `hideBranding` says
// whether LiveVoiceView leaves out the LiveVoice logo, `customUiAllowed`
// whether you may replace its parts with your own. The SDK enforces both;
// read them only to adapt your own UI. Both are `false` until an event is joined.
//
// On Android both are StateFlows: collect them, don't read `.value` once.
//
// Uses: LiveVoice.hideBranding, customUiAllowed
// See also: Custom channel cell, Custom view states (the parts custom UI allows).

package io.livevoice.example.screens.customization

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import io.livevoice.example.demo.DemoApiKeyPresetList
import io.livevoice.example.demo.DemoScreen
import io.livevoice.example.demo.DemoSection
import io.livevoice.example.demo.DemoValueRow
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.views.LiveVoiceView

@Composable
fun BrandingScreen() {
    val hideBranding by LiveVoice.hideBranding.collectAsState()
    val customUiAllowed by LiveVoice.customUiAllowed.collectAsState()

    DemoScreen("Branding and entitlements", caption = "See what the joined event's API key permits.") {
        DemoSection("This API key") {
            DemoValueRow("Branding", if (hideBranding) "Hidden" else "Shown")
            DemoValueRow("Custom UI", if (customUiAllowed) "Allowed" else "Not allowed")
        }
        // The demo event's three keys: branding shown and no custom UI,
        // branding hidden and no custom UI, branding hidden and custom UI.
        DemoSection("Demo API keys") {
            DemoApiKeyPresetList()
        }
        DemoSection("Channels") {
            // Shows or hides the branding by itself.
            LiveVoiceView()
        }
    }
}
