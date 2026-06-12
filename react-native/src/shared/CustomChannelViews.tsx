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
import {
  type Channel,
  PlayingState,
  Translations,
} from "livevoice-sdk-react-native";
import { useDemoTheme } from "../theme";

function channelStatus(channel: Channel): string {
  if (!channel.isOnline) {
    return Translations.channelStatusOffline();
  }
  if (channel.aiTranslationInfo != null) {
    return `AI ${channel.aiTranslationInfo.targetLanguage}`;
  }
  return channel.playingState === PlayingState.PLAYING
    ? "Currently playing"
    : "Ready to start";
}

/** A fully custom channel row, replacing the built-in cell. */
export const BasicCustomChannelRow: React.FC<{
  channel: Channel;
  /** Toggles audio for this channel — provided by the SDK through renderChannel. */
  onAudioPress: () => void;
  /** Last row in the list — drop the trailing gap so the cells sit flush in the section. */
  isLast?: boolean;
}> = ({ channel, onAudioPress, isLast = false }) => {
  const theme = useDemoTheme();
  const playing = channel.playingState === PlayingState.PLAYING;
  return (
    <Pressable
      onPress={onAudioPress}
      style={[
        styles.row,
        { backgroundColor: theme.liveSample, marginBottom: isLast ? 0 : 12 },
      ]}
    >
      <View style={styles.rowText}>
        <Text style={[styles.rowTitle, { color: theme.text }]}>
          {channel.name}
        </Text>
        <Text style={[styles.rowStatus, { color: theme.secondaryText }]}>
          {channelStatus(channel)}
        </Text>
      </View>
      {/* Non-brand accent (iOS system blue): custom cells aren't tied to LiveVoice colors. */}
      <View style={[styles.iconCircle, { backgroundColor: "#007AFF1F" }]}>
        <Text style={{ color: "#007AFF", fontSize: 15 }}>
          {playing ? "■" : "▶"}
        </Text>
      </View>
    </Pressable>
  );
};

/**
 * A pill for one Boolean property: full-contrast when true, faint when false, so every
 * readable value stays visible even when the feature doesn't apply.
 */
const BoolBadge: React.FC<{ label: string; isOn: boolean }> = ({
  label,
  isOn,
}) => {
  const theme = useDemoTheme();
  return (
    <View
      style={[
        styles.boolBadge,
        { borderColor: theme.text, opacity: isOn ? 1 : 0.3 },
      ]}
    >
      <Text style={[styles.boolBadgeText, { color: theme.text }]}>{label}</Text>
    </View>
  );
};

/**
 * A richer custom channel row that surfaces the channel's Booleans — isOnline as the status
 * dot, the rest as badges (solid when true, faint when false) — so you can see which values
 * you can read even when a feature doesn't apply. The row is tappable, and its play control
 * active, only when the channel can be started (online and with audio).
 */
export const DetailedCustomChannelRow: React.FC<{
  channel: Channel;
  /** Toggles audio for this channel — provided by the SDK through renderChannel. */
  onAudioPress: () => void;
  /** Last row in the list — drop the trailing gap so the cells sit flush in the section. */
  isLast?: boolean;
}> = ({ channel, onAudioPress, isLast = false }) => {
  const theme = useDemoTheme();
  const playing = channel.playingState === PlayingState.PLAYING;
  // The channel can be started only when it is online and has audio.
  const canPlay = channel.isOnline && channel.hasAudio;
  return (
    <Pressable
      onPress={onAudioPress}
      disabled={!canPlay}
      style={[
        styles.detailedRow,
        { backgroundColor: theme.liveSample, marginBottom: isLast ? 0 : 12 },
      ]}
    >
      <View
        style={[
          styles.statusDot,
          { backgroundColor: channel.isOnline ? "#34C759" : "#8E8E93" },
        ]}
      />
      <View style={styles.rowText}>
        <Text style={[styles.rowTitle, { color: theme.text }]}>
          {channel.name}
        </Text>
        <Text style={[styles.rowStatus, { color: theme.secondaryText }]}>
          {channelStatus(channel)}
        </Text>
        {/* isOnline is already shown by the status dot + status line above, so it's not a badge. */}
        <View style={styles.badgeRow}>
          <BoolBadge label="Audio" isOn={channel.hasAudio} />
          <BoolBadge label="Subtitles" isOn={channel.hasSubtitles} />
          <BoolBadge label="Muted" isOn={channel.isAudioMuted} />
        </View>
      </View>
      {/* Non-brand accent (iOS system blue): custom cells aren't tied to LiveVoice colors. */}
      <View
        style={[
          styles.iconCircle,
          {
            backgroundColor: canPlay ? "#007AFF1F" : "#8E8E931F",
            opacity: canPlay ? 1 : 0.4,
          },
        ]}
      >
        <Text style={{ color: canPlay ? "#007AFF" : "#8E8E93", fontSize: 15 }}>
          {playing ? "■" : "▶"}
        </Text>
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
    padding: 16,
    borderRadius: 16,
  },
  detailedRow: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 12,
    padding: 16,
    borderRadius: 16,
  },
  statusDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginTop: 5,
  },
  badgeRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 6,
    marginTop: 8,
  },
  boolBadge: {
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 999,
    paddingHorizontal: 8,
    paddingVertical: 2,
  },
  boolBadgeText: {
    fontSize: 11,
    fontWeight: "500",
  },
  rowText: {
    flex: 1,
    gap: 6,
  },
  rowTitle: {
    fontSize: 16,
    fontWeight: "600",
  },
  rowStatus: {
    fontSize: 12,
  },
  iconCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: "center",
    justifyContent: "center",
  },
});
