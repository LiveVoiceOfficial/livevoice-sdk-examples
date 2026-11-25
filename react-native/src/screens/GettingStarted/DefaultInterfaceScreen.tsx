// Default interface
//
// The smallest integration: LiveVoiceView lists the joined event's channels
// and plays the one a listener taps. It also shows loading, reconnecting,
// errors, an event without channels and the LiveVoice branding by itself.
//
// Differs from iOS: `initialize()` must have resolved before LiveVoiceView can
// play anything; the demo awaits it once at launch (DemoSession) and only
// then renders its screens. Commands before it reject with `not_initialized`.
//
// Uses: LiveVoiceView
// See also: Joining an event (how the event is joined), Filtering channels,
// Custom channel cell, Subtitles, Audio output.

import React from "react";
import { LiveVoiceView } from "livevoice-sdk-react-native";
import { DemoScreen, DemoSection } from "../../demo/DemoScreen";

export const DefaultInterfaceScreen: React.FC = () => (
  <DemoScreen title="Default interface" caption="Tap a channel to listen.">
    <DemoSection title="Channels">
      <LiveVoiceView />
    </DemoSection>
  </DemoScreen>
);
