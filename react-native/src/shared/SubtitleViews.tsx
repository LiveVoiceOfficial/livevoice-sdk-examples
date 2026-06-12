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
import { ScrollView, StyleSheet, Text, View } from "react-native";
import {
  type AvailableSubtitle,
  getCurrentSubtitleConfiguration,
  getCurrentSubtitleState,
  onAvailableSubtitleConfigsChanged,
  onSubtitleStateChanged,
  startSubtitles,
  stopSubtitles,
  type SubtitleState,
} from "livevoice-sdk-react-native";
import { useDemoTheme } from "../theme";
import { DemoCardSection, MenuPicker, type MenuOption } from "./DemoComponents";

function safe<T>(read: () => T, fallback: T): T {
  try {
    return read();
  } catch {
    return fallback;
  }
}

export interface SubtitlesController {
  availableSubtitles: AvailableSubtitle[] | null;
  fragments: string[];
  enabled: boolean;
  selectedChannelId: number | null;
  start: () => void;
  stop: () => void;
  select: (channelId: number | null) => void;
}

/** Wires the SDK's subtitle configuration, fragment feed, and start/stop calls. */
export function useSubtitles(): SubtitlesController {
  const [availableSubtitles, setAvailableSubtitles] = useState<
    AvailableSubtitle[] | null
  >(() => safe(() => getCurrentSubtitleConfiguration(), null));
  const [state, setState] = useState<SubtitleState>(() =>
    safe<SubtitleState>(() => getCurrentSubtitleState(), { type: "disabled" }),
  );
  const [selectedChannelId, setSelectedChannelId] = useState<number | null>(
    null,
  );

  const enabled = state.type !== "disabled";
  const fragments = state.type === "disabled" ? [] : state.fragments;

  useEffect(() => {
    const sub = onAvailableSubtitleConfigsChanged(setAvailableSubtitles);
    return () => sub.remove();
  }, []);

  useEffect(() => {
    const sub = onSubtitleStateChanged((next) => {
      setState(next);
      if (next.type === "specific") setSelectedChannelId(next.channelId);
      else if (next.type === "automatic") setSelectedChannelId(null);
    });
    return () => sub.remove();
  }, []);

  const start = () => startSubtitles(selectedChannelId);
  const stop = () => stopSubtitles();
  // The native API stops any previous stream automatically, so switching the
  // language is just another startSubtitles call.
  const select = (channelId: number | null) => {
    setSelectedChannelId(channelId);
    if (enabled) {
      startSubtitles(channelId);
    }
  };

  return {
    availableSubtitles,
    fragments,
    enabled,
    selectedChannelId,
    start,
    stop,
    select,
  };
}

/** A fixed-height feed that stays pinned to the latest subtitle fragment. */
export const SubtitleFeed: React.FC<{
  fragments: string[];
  placeholder: string;
}> = ({ fragments, placeholder }) => {
  const theme = useDemoTheme();
  const scrollRef = useRef<ScrollView>(null);

  if (fragments.length === 0) {
    return (
      <Text style={[styles.placeholder, { color: theme.secondaryText }]}>
        {placeholder}
      </Text>
    );
  }

  return (
    <ScrollView
      ref={scrollRef}
      style={styles.feed}
      nestedScrollEnabled
      onContentSizeChange={() =>
        scrollRef.current?.scrollToEnd({ animated: true })
      }
    >
      {fragments.map((fragment, index) => (
        <Text key={index} style={[styles.fragment, { color: theme.text }]}>
          {fragment}
        </Text>
      ))}
    </ScrollView>
  );
};

export function mapSubtitleOptions(
  subtitles: AvailableSubtitle[],
): MenuOption[] {
  const namesById = new Map(subtitles.map((s) => [s.id, s.name]));
  const options: MenuOption[] = [{ id: null, title: "Automatic" }];

  const groups = new Map<number, AvailableSubtitle[]>();
  for (const subtitle of subtitles) {
    const rootId = subtitle.parent ?? subtitle.id;
    const list = groups.get(rootId) ?? [];
    list.push(subtitle);
    groups.set(rootId, list);
  }

  const sortedRoots = [...groups.keys()].sort((a, b) => {
    const nameA = namesById.get(a) ?? "";
    const nameB = namesById.get(b) ?? "";
    return nameA.localeCompare(nameB);
  });

  for (const rootId of sortedRoots) {
    const items = (groups.get(rootId) ?? [])
      .slice()
      .sort((a, b) => (a.language ?? "").localeCompare(b.language ?? ""));
    const groupTitle = namesById.get(rootId) ?? `Channel ${rootId}`;
    items.forEach((subtitle, index) => {
      options.push({
        id: subtitle.id,
        title: subtitle.language == null ? "Original transcript" : subtitle.name,
        sectionTitle: index === 0 ? `Based on ${groupTitle}` : undefined,
      });
    });
  }

  return options;
}

/** Start/stop button plus the subtitle source picker. */
export const SubtitleControls: React.FC<{ controller: SubtitlesController }> = ({
  controller,
}) => {
  const theme = useDemoTheme();
  const { availableSubtitles, enabled, selectedChannelId, start, stop, select } =
    controller;
  const configs = availableSubtitles ?? [];
  const hasSubtitles = configs.length > 0;

  const selectedLabel =
    configs.find((s) => s.id === selectedChannelId)?.name ?? "Automatic";

  return (
    <DemoCardSection title="Controls">
      <View style={styles.controls}>
        <Text
          onPress={hasSubtitles ? (enabled ? stop : start) : undefined}
          style={[
            styles.button,
            {
              backgroundColor: theme.primary,
              opacity: hasSubtitles ? 1 : 0.5,
            },
          ]}
        >
          {enabled ? "Stop subtitles" : "Start subtitles"}
        </Text>
        <MenuPicker
          selectedLabel={selectedLabel}
          options={mapSubtitleOptions(configs)}
          selectedId={selectedChannelId}
          onSelect={(id) => select(id as number | null)}
          enabled={hasSubtitles}
        />
      </View>
    </DemoCardSection>
  );
};

const styles = StyleSheet.create({
  placeholder: {
    fontSize: 15,
    lineHeight: 20,
  },
  feed: {
    height: 220,
  },
  fragment: {
    fontSize: 16,
    lineHeight: 22,
    marginBottom: 8,
  },
  controls: {
    gap: 12,
  },
  button: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
    textAlign: "center",
    overflow: "hidden",
    borderRadius: 10,
    paddingVertical: 12,
  },
});
