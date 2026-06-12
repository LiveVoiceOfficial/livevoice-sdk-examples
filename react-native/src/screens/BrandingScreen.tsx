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

import React, { useEffect, useRef, useState } from "react";
import { StyleSheet, Text, View } from "react-native";
import {
  LiveVoiceView,
  getCurrentFeatures,
  onFeaturesChanged,
  type Channel,
  type Features,
} from "livevoice-sdk-react-native";
import { DemoCardSection, DemoNotes, DemoScreen } from "../shared/DemoComponents";
import { BasicCustomChannelRow } from "../shared/CustomChannelViews";
import { useDemoSession } from "../shared/DemoSession";
import { useDemoTheme } from "../theme";

const EntitlementRow: React.FC<{ label: string; value: string }> = ({
  label,
  value,
}) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.row}>
      <Text style={[styles.label, { color: theme.secondaryText }]}>{label}</Text>
      <Text style={[styles.value, { color: theme.text }]}>{value}</Text>
    </View>
  );
};

export const BrandingScreen: React.FC = () => {
  const theme = useDemoTheme();
  const { selectedPreset } = useDemoSession();

  // Live authorization features reported by the SDK for the joined key. Seeded
  // from getCurrentFeatures() and kept current via onFeaturesChanged, so
  // switching the API key preset updates these in place.
  const [features, setFeatures] = useState<Features>(() => getCurrentFeatures());
  useEffect(() => {
    setFeatures(getCurrentFeatures());
    const subscription = onFeaturesChanged(setFeatures);
    return () => subscription.remove();
  }, []);

  const firstChannelId = useRef<number | null>(null);
  useEffect(() => {
    firstChannelId.current = null;
  }, [selectedPreset]);
  const onlyFirstChannel = (channel: Channel): boolean => {
    if (firstChannelId.current == null) {
      firstChannelId.current = channel.id;
    }
    return channel.id === firstChannelId.current;
  };

  return (
    <DemoScreen summary="Switch the preset API key from the toolbar to inspect the real branding and custom UI permissions for this demo event.">
      <DemoCardSection title="Live sample">
        <View style={styles.sample}>
          <Text style={[styles.sampleLabel, { color: theme.text }]}>
            Standard view
          </Text>
          <LiveVoiceView filter={onlyFirstChannel} />
        </View>

        <View style={styles.sample}>
          <Text style={[styles.sampleLabel, { color: theme.text }]}>
            Custom row
          </Text>
          <LiveVoiceView
            filter={onlyFirstChannel}
            renderChannel={(channel, { onAudioPress }) => (
              <BasicCustomChannelRow channel={channel} onAudioPress={onAudioPress} />
            )}
          />
        </View>
      </DemoCardSection>

      <DemoCardSection title="Current features">
        <EntitlementRow label="Selected preset" value={selectedPreset.title} />
        <EntitlementRow
          label="Branding"
          value={features.hideBranding ? "Hidden" : "Visible"}
        />
        <EntitlementRow
          label="Custom UI"
          value={features.customUiAllowed ? "Allowed" : "Not allowed"}
        />
      </DemoCardSection>

      <DemoCardSection title="Implementation notes">
        <DemoNotes
          notes={[
            "Both samples above show only the event's first channel.",
            "Switch the API key preset from the toolbar to compare branding and custom UI entitlements for that same channel.",
          ]}
        />
      </DemoCardSection>
    </DemoScreen>
  );
};

const styles = StyleSheet.create({
  sample: {
    gap: 8,
  },
  sampleLabel: {
    fontSize: 15,
    fontWeight: "600",
  },
  row: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  label: {
    fontSize: 15,
  },
  value: {
    fontSize: 15,
    fontWeight: "500",
  },
});
