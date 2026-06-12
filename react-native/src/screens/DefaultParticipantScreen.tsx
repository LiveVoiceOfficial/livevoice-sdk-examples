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
import { Pressable, StyleSheet, Text, View } from "react-native";
import { LiveVoiceView } from "livevoice-sdk-react-native";
import {
  DemoCardSection,
  DemoFadeIn,
  DemoNotes,
  DemoScreen,
  DemoSubtitleUnavailableHint,
} from "../shared/DemoComponents";
import { AudioOutputRow } from "../shared/AudioOutputControls";
import { SubtitleFeed, useSubtitles } from "../shared/SubtitleViews";
import { useDemoTheme } from "../theme";

export const DefaultParticipantScreen: React.FC = () => {
  const theme = useDemoTheme();
  const controller = useSubtitles();
  const showFeed =
    controller.availableSubtitles == null ||
    controller.availableSubtitles.length > 0;

  return (
    <DemoScreen summary="The simplest LiveVoice integration. The default view manages channels and audio; tap a channel's subtitle button and the fragments stream into your own subtitle view.">
      <DemoCardSection title="Live sample">
        {/* Keep audio output reachable right above the list, so playback is never silent. */}
        <View style={{ gap: 12 }}>
          <AudioOutputRow />
          <LiveVoiceView />
        </View>
      </DemoCardSection>

      <DemoCardSection title="Your subtitle view">
        <Text style={[styles.explainer, { color: theme.secondaryText }]}>
          Tap a channel's subtitle button above and its subtitles stream into
          this view, which your app provides.
        </Text>
        {showFeed ? (
          <DemoFadeIn key="feed">
            <SubtitleFeed
              fragments={controller.fragments}
              placeholder="Subtitles will appear here."
            />
          </DemoFadeIn>
        ) : (
          <DemoFadeIn key="hint">
            <DemoSubtitleUnavailableHint />
          </DemoFadeIn>
        )}
        <Pressable
          onPress={controller.enabled ? controller.stop : undefined}
          disabled={!controller.enabled}
          style={[
            styles.stopButton,
            {
              backgroundColor: theme.chevron,
              opacity: controller.enabled ? 1 : 0.4,
            },
          ]}
        >
          <Text style={[styles.stopButtonText, { color: theme.text }]}>
            Stop subtitles
          </Text>
        </Pressable>
      </DemoCardSection>

      <DemoCardSection title="Implementation notes">
        <DemoNotes
          notes={[
            "Join the event once at app startup or before presenting the screen.",
            "LiveVoiceView handles loading, errors, reconnecting, and branding for you.",
            "Tapping a channel's subtitle button starts its subtitles; your app provides the view that renders the fragments.",
            "Automatic subtitle mode follows whichever channel is currently playing.",
          ]}
        />
      </DemoCardSection>
    </DemoScreen>
  );
};

const styles = StyleSheet.create({
  explainer: {
    fontSize: 14,
    lineHeight: 19,
  },
  stopButton: {
    alignSelf: "flex-start",
    borderRadius: 999,
    paddingVertical: 8,
    paddingHorizontal: 16,
  },
  stopButtonText: {
    fontSize: 14,
    fontWeight: "600",
  },
});
