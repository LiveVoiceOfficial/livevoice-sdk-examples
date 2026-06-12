/*
 * This source file is part of the LiveVoice SDK project
 *
 * Copyright (c) LiveVoice GmbH
 * Licensed under the MIT license
 *
 * See LICENSE for license information
 *
 * SPDX-License-Identifier: MIT
 */

import React from "react";
import { View } from "react-native";
import { LiveVoiceView } from "livevoice-sdk-react-native";
import {
  DemoCardSection,
  DemoNotes,
  DemoScreen,
} from "../shared/DemoComponents";
import { AudioOutputRow } from "../shared/AudioOutputControls";
import { DetailedCustomChannelRow } from "../shared/CustomChannelViews";

export const CustomChannelCellScreen: React.FC = () => {
  return (
    <DemoScreen summary="Replace the built-in channel row with your own React Native view while keeping the LiveVoice session logic.">
      <DemoCardSection title="Live sample">
        {/* Keep audio output reachable right above the list, so playback is never silent. */}
        <View style={{ gap: 12 }}>
          <AudioOutputRow />
          <LiveVoiceView
            renderChannel={(channel, { isLastInList, onAudioPress }) => (
              <DetailedCustomChannelRow
                channel={channel}
                isLast={isLastInList}
                onAudioPress={onAudioPress}
              />
            )}
          />
        </View>
      </DemoCardSection>

      <DemoCardSection title="Implementation notes">
        <DemoNotes
          notes={[
            "Pass a renderChannel render-prop to LiveVoiceView to replace the built-in cell.",
            "The closure receives each channel plus { isLastInList, onAudioPress }; call onAudioPress to keep playback connected to LiveVoice.",
            "The channel's Booleans are surfaced — isOnline as the status dot, the rest as badges (solid when true, faint when false) — so you can see which values you can read even when a feature doesn't apply to your own design.",
            "The row is tappable — and its play control active — only when the channel can be started (online and with audio); otherwise the cell is inert.",
            "Custom cells require an API key that allows custom UI — otherwise the SDK shows the invalid-api-key error. Switch keys from the connection menu to compare.",
          ]}
        />
      </DemoCardSection>
    </DemoScreen>
  );
};
