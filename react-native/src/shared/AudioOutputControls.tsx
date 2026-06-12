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

import React, { useEffect, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import {
  getCurrentAudioState,
  onAudioOutputChanged,
  setLiveVoiceUseSpeaker,
} from "livevoice-sdk-react-native";
import { MenuPicker } from "./DemoComponents";
import { useDemoTheme } from "../theme";

const RECEIVER_GLYPH = "🎧";
const SPEAKER_GLYPH = "🔊";

/** Tracks the SDK's current audio output, so every control below stays in sync. */
function useAudioOutput(): boolean {
  const [useSpeaker, setUseSpeaker] = useState<boolean>(() => {
    try {
      return getCurrentAudioState();
    } catch {
      return false;
    }
  });
  useEffect(() => {
    const sub = onAudioOutputChanged((value) => setUseSpeaker(value));
    return () => sub.remove();
  }, []);
  return useSpeaker;
}

/** The compact output control: an icon-only segmented picker kept narrow so it can sit above a list. */
export const CompactAudioOutputPicker: React.FC = () => {
  const theme = useDemoTheme();
  const useSpeaker = useAudioOutput();
  const outputs = [
    { speaker: false, glyph: RECEIVER_GLYPH },
    { speaker: true, glyph: SPEAKER_GLYPH },
  ];
  return (
    <View style={[styles.compact, { backgroundColor: theme.separator }]}>
      {outputs.map((output) => {
        const selected = output.speaker === useSpeaker;
        return (
          <Pressable
            key={output.glyph}
            onPress={() => setLiveVoiceUseSpeaker(output.speaker)}
            style={[
              styles.compactItem,
              selected && { backgroundColor: theme.liveSample },
            ]}
          >
            <Text style={{ fontSize: 15 }}>{output.glyph}</Text>
          </Pressable>
        );
      })}
    </View>
  );
};

/** A pop-up menu variant: a button that opens a menu listing the outputs. */
export const MenuAudioOutputPicker: React.FC = () => {
  const useSpeaker = useAudioOutput();
  return (
    <MenuPicker
      selectedLabel={useSpeaker ? "Speaker" : "Receiver"}
      selectedId={useSpeaker ? 1 : 0}
      onSelect={(id) => setLiveVoiceUseSpeaker(id === 1)}
      options={[
        { id: 0, title: "Receiver" },
        { id: 1, title: "Speaker" },
      ]}
    />
  );
};

/** A single button that toggles straight between the two outputs. */
export const ToggleAudioOutputButton: React.FC = () => {
  const theme = useDemoTheme();
  const useSpeaker = useAudioOutput();
  return (
    <Pressable
      onPress={() => setLiveVoiceUseSpeaker(!useSpeaker)}
      style={[styles.toggle, { borderColor: theme.separator }]}
    >
      <Text style={{ color: theme.text, fontSize: 15 }}>
        {`${useSpeaker ? SPEAKER_GLYPH : RECEIVER_GLYPH}  ${useSpeaker ? "Speaker" : "Receiver"}`}
      </Text>
    </Pressable>
  );
};

/** An "Audio output" label paired with the compact picker — placed above channel lists. */
export const AudioOutputRow: React.FC = () => {
  const theme = useDemoTheme();
  return (
    <View style={styles.row}>
      <Text style={{ color: theme.secondaryText, fontSize: 14 }}>
        Audio output
      </Text>
      <CompactAudioOutputPicker />
    </View>
  );
};

const styles = StyleSheet.create({
  compact: {
    flexDirection: "row",
    borderRadius: 8,
    padding: 2,
    alignSelf: "flex-start",
    gap: 2,
  },
  compactItem: {
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderRadius: 6,
  },
  toggle: {
    alignSelf: "flex-start",
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 10,
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  row: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
});
