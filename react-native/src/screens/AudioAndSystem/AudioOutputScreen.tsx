// Audio output
//
// The audio output is a preference, not the current route: `'system'`, the
// default, lets the system choose, such as connected headphones or the
// receiver; `'speaker'` prefers the loudspeaker. Set it any time, also before
// `initialize()` and before joining; setting it never fails. The setting is
// the SDK's, so it applies to the whole app, not just this screen.
//
// Differs from iOS: there is no settable property; `setAudioOutput` sets the
// preference and `useLiveVoiceAudioOutput` reads it, so every control bound
// to the hook stays in sync.
//
// Uses: setAudioOutput(output), useLiveVoiceAudioOutput(), LiveVoiceAudioOutput
// See also: Lock screen and audio sharing (with `'hostManaged'` audio focus,
// your app picks the route and this preference has no effect).

import React from "react";
import {
  LiveVoiceView,
  setAudioOutput,
  useLiveVoiceAudioOutput,
} from "livevoice-sdk-react-native";
import { DemoSegmentedControl } from "../../demo/DemoControls";
import { DemoNote, DemoScreen, DemoSection } from "../../demo/DemoScreen";
import { useDemoTheme } from "../../demo/DemoTheme";

export const AudioOutputScreen: React.FC = () => {
  const theme = useDemoTheme();
  const audioOutput = useLiveVoiceAudioOutput();

  return (
    <DemoScreen
      title="Audio output"
      caption="Prefer the loudspeaker, or let the system choose."
    >
      <DemoSection title="Output">
        <DemoNote
          text="These settings apply to the whole app: every demo screen plays with them, and a playing channel keeps playing when you switch screens."
          icon="info"
          tint={theme.secondaryText}
        />
        <DemoSegmentedControl
          options={[
            { label: "System", value: "system" },
            { label: "Speaker", value: "speaker" },
          ]}
          value={audioOutput}
          // It never rejects.
          onChange={(output) => void setAudioOutput(output)}
        />
      </DemoSection>
      <DemoSection title="Channels">
        <LiveVoiceView />
      </DemoSection>
    </DemoScreen>
  );
};
