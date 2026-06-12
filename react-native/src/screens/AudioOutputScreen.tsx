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
import { StyleSheet, Text, View } from "react-native";
import { LiveVoiceView } from "livevoice-sdk-react-native";
import {
  DemoCardSection,
  DemoNotes,
  DemoScreen,
} from "../shared/DemoComponents";
import {
  CompactAudioOutputPicker,
  MenuAudioOutputPicker,
  ToggleAudioOutputButton,
} from "../shared/AudioOutputControls";
import { useDemoTheme } from "../theme";

const Variant: React.FC<{
  title: string;
  detail: string;
  children: React.ReactNode;
}> = ({ title, detail, children }) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.variant}>
      <Text style={[styles.variantTitle, { color: theme.text }]}>{title}</Text>
      <Text style={[styles.variantDetail, { color: theme.secondaryText }]}>
        {detail}
      </Text>
      <View>{children}</View>
    </View>
  );
};

export const AudioOutputScreen: React.FC = () => {
  return (
    <DemoScreen summary="Place an audio output control wherever it fits in your app and bind it to the SDK. Here are three styles — all driving the same output.">
      <DemoCardSection title="Live sample">
        <LiveVoiceView />
      </DemoCardSection>

      <DemoCardSection title="Output controls">
        <View style={styles.variants}>
          <Variant
            title="Compact icons"
            detail="An icon-only segmented picker that stays compact."
          >
            <CompactAudioOutputPicker />
          </Variant>
          <Variant
            title="Pop-up menu"
            detail="A button that opens a menu — handy when space is tight."
          >
            <MenuAudioOutputPicker />
          </Variant>
          <Variant
            title="Toggle button"
            detail="A single button that flips straight to the other output."
          >
            <ToggleAudioOutputButton />
          </Variant>
        </View>
      </DemoCardSection>

      <DemoCardSection title="Implementation notes">
        <DemoNotes
          notes={[
            "The React Native SDK exposes the current audio output and an onAudioOutputChanged handler.",
            "Every control here drives that single value, so they all stay in sync.",
            "Bind a picker, menu, or toggle to it wherever it makes sense in the screen.",
          ]}
        />
      </DemoCardSection>
    </DemoScreen>
  );
};

const styles = StyleSheet.create({
  variants: {
    gap: 20,
  },
  variant: {
    gap: 6,
  },
  variantTitle: {
    fontSize: 15,
    fontWeight: "600",
  },
  variantDetail: {
    fontSize: 13,
  },
});
