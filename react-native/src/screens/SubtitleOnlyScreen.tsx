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
import {
  DemoCardSection,
  DemoFadeIn,
  DemoNotes,
  DemoScreen,
  DemoSubtitleUnavailableHint,
} from "../shared/DemoComponents";
import {
  SubtitleControls,
  SubtitleFeed,
  useSubtitles,
} from "../shared/SubtitleViews";
import { useDemoTheme } from "../theme";

export const SubtitleOnlyScreen: React.FC = () => {
  const theme = useDemoTheme();
  const controller = useSubtitles();
  const showFeed =
    controller.availableSubtitles == null ||
    controller.availableSubtitles.length > 0;

  return (
    <DemoScreen summary="Display subtitles on their own, without showing any of the event channels.">
      <DemoCardSection title="Live sample">
        <View style={styles.feedHeader}>
          <Text style={[styles.feedTitle, { color: theme.text }]}>
            Subtitle view
          </Text>
          {showFeed ? (
            <DemoFadeIn key="feed">
              <SubtitleFeed
                fragments={controller.fragments}
                placeholder="Start subtitles to render fragments in this dedicated view."
              />
            </DemoFadeIn>
          ) : (
            <DemoFadeIn key="hint">
              <DemoSubtitleUnavailableHint />
            </DemoFadeIn>
          )}
        </View>
      </DemoCardSection>

      <SubtitleControls controller={controller} />

      <DemoCardSection title="Implementation notes">
        <DemoNotes
          notes={[
            "Your app provides the subtitle view and chooses which subtitle stream to start or stop.",
            "You can use this without rendering the LiveVoice channel list at all.",
            "The subtitle change handler gives you the current subtitle fragments for your custom view.",
          ]}
        />
      </DemoCardSection>
    </DemoScreen>
  );
};

const styles = StyleSheet.create({
  feedHeader: {
    gap: 8,
  },
  feedTitle: {
    fontSize: 15,
    fontWeight: "600",
  },
});
