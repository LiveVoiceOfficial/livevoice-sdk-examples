// Branding and entitlements
//
// What an API key may do is set for your account. `hideBranding` says
// whether LiveVoiceView leaves out the LiveVoice logo, `customUiAllowed`
// whether you may replace its parts with your own. The SDK enforces both;
// read them only to adapt your own UI. Both are `false` until an event is joined.
//
// Differs from iOS: both come together from `useLiveVoiceFeatures()`.
//
// Uses: useLiveVoiceFeatures(), LiveVoiceFeatures
// See also: Custom channel cell, Custom view states (the parts custom UI allows).

import React from "react";
import { LiveVoiceView, useLiveVoiceFeatures } from "livevoice-sdk-react-native";
import { DemoApiKeyPresetList } from "../../demo/DemoEventPicker";
import { DemoValueRow } from "../../demo/DemoRows";
import { DemoScreen, DemoSection } from "../../demo/DemoScreen";

export const BrandingScreen: React.FC = () => {
  const { hideBranding, customUiAllowed } = useLiveVoiceFeatures();
  return (
    <DemoScreen
      title="Branding and entitlements"
      caption="See what the joined event's API key permits."
    >
      <DemoSection title="This API key">
        <DemoValueRow label="Branding" value={hideBranding ? "Hidden" : "Shown"} />
        <DemoValueRow label="Custom UI" value={customUiAllowed ? "Allowed" : "Not allowed"} />
      </DemoSection>
      {/* The demo event's three keys: branding shown and no custom UI,
          branding hidden and no custom UI, branding hidden and custom UI. */}
      <DemoSection title="Demo API keys">
        <DemoApiKeyPresetList />
      </DemoSection>
      <DemoSection title="Channels">
        {/* Shows or hides the branding by itself. */}
        <LiveVoiceView />
      </DemoSection>
    </DemoScreen>
  );
};
