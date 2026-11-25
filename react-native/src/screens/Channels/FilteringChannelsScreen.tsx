// Filtering channels
//
// LiveVoiceView's `filter` decides which channels it shows: it gets each
// channel and returns `true` to keep it. Filter on any channel property;
// the look, playback and reconnection stay the same. A filter that matches
// nothing shows the view's "no matching channels" state.
//
// Differs from iOS: `filter` is a prop. The view runs it on every render, so
// a new function per render is fine; it must not have side effects.
//
// Uses: LiveVoiceView filter, LiveVoiceChannel
// See also: Default interface, Custom view states (your own empty part).

import React, { useState } from "react";
import { LiveVoiceView } from "livevoice-sdk-react-native";
import { DemoSegmentedControl } from "../../demo/DemoControls";
import { DemoScreen, DemoSection } from "../../demo/DemoScreen";

type Filter = "all" | "online" | "withSubtitles" | "none";

export const FilteringChannelsScreen: React.FC = () => {
  const [filter, setFilter] = useState<Filter>("all");

  return (
    <DemoScreen
      title="Filtering channels"
      caption="Show only the channels you want."
    >
      <DemoSection title="Filter">
        <DemoSegmentedControl
          options={[
            { label: "All", value: "all" },
            { label: "Online", value: "online" },
            { label: "Subtitles", value: "withSubtitles" },
            { label: "None", value: "none" },
          ]}
          value={filter}
          onChange={setFilter}
        />
      </DemoSection>
      <DemoSection title="Channels">
        <LiveVoiceView
          filter={(channel) => {
            switch (filter) {
              case "all":
                return true;
              case "online":
                return channel.isOnline;
              case "withSubtitles":
                return channel.hasSubtitles;
              case "none":
                return false;
            }
          }}
        />
        {/* More filters:
            - A single channel, by its ID from the dashboard's "Show Options":
              `channel.id === 137`
            - A source channel with the AI translations derived from it:
              `channel.id === sourceId || channel.aiTranslationInfo?.sourceChannelId === sourceId` */}
      </DemoSection>
    </DemoScreen>
  );
};
