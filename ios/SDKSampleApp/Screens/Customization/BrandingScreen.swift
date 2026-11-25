// Branding and entitlements
//
// What an API key may do is set for your account. `hideBranding` says
// whether LiveVoiceView leaves out the LiveVoice logo, `customUiAllowed`
// whether you may replace its parts with your own. The SDK enforces both;
// read them only to adapt your own UI. Both are `false` until an event is joined.
//
// Uses: LiveVoice.hideBranding, customUiAllowed
// See also: Custom channel cell, Custom view states (the parts custom UI allows).
// Docs: LiveVoiceSDK documentation › Branding and Entitlements

import SwiftUI
import LiveVoiceSDK

struct BrandingScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared

    var body: some View {
        DemoScreen("Branding and entitlements", caption: "See what the joined event's API key permits.") {
            DemoSection("This API key") {
                DemoValueRow("Branding", value: liveVoice.hideBranding ? "Hidden" : "Shown")
                DemoValueRow("Custom UI", value: liveVoice.customUiAllowed ? "Allowed" : "Not allowed")
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
}

#Preview {
    DemoStackNavigation {
        BrandingScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(joinCode: DemoFixture.joinCode, password: DemoFixture.password, apiKey: DemoFixture.apiKey)
}
