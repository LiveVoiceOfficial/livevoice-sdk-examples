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

import React, { useEffect, useMemo, useState } from "react";
import { StyleSheet, Text } from "react-native";
import {
  LiveVoiceView,
  type AvailableSubtitle,
  type Channel,
  getCurrentSubtitleConfiguration,
  onAvailableSubtitleConfigsChanged,
} from "livevoice-sdk-react-native";
import {
  DemoCardSection,
  DemoNotes,
  DemoScreen,
  MenuPicker,
  type MenuOption,
  SegmentedControl,
} from "../shared/DemoComponents";
import { useDemoTheme } from "../theme";

type FilterMode = "all" | "hasSubtitles" | "noMatchingChannels";

const FILTER_OPTIONS = [
  { label: "All", value: "all" as const },
  { label: "Has subtitles", value: "hasSubtitles" as const },
  { label: "No match", value: "noMatchingChannels" as const },
];

const PREDICATE_DESCRIPTION: Record<FilterMode, string> = {
  all: "Predicate: () => true",
  hasSubtitles: "Predicate: (channel) => channel.hasSubtitles",
  noMatchingChannels: "Predicate: () => false",
};

function safeConfig(): AvailableSubtitle[] {
  try {
    return getCurrentSubtitleConfiguration() ?? [];
  } catch {
    return [];
  }
}

interface SourceOption {
  id: number;
  name: string;
}

export const FilteredChannelsScreen: React.FC = () => {
  const theme = useDemoTheme();
  const [filterMode, setFilterMode] = useState<FilterMode>("all");
  const [availableSubtitles, setAvailableSubtitles] = useState<
    AvailableSubtitle[]
  >(() => safeConfig());
  const [selectedSourceId, setSelectedSourceId] = useState<number | null>(null);

  useEffect(() => {
    const sub = onAvailableSubtitleConfigsChanged((data) => {
      setAvailableSubtitles(data ?? []);
    });
    return () => sub.remove();
  }, []);

  // Derive the selectable source channels from the event's subtitle config.
  const sourceOptions = useMemo<SourceOption[]>(() => {
    const namesById = new Map(availableSubtitles.map((s) => [s.id, s.name]));
    const rootIds = new Set(availableSubtitles.map((s) => s.parent ?? s.id));
    return [...rootIds]
      .map((id) => ({ id, name: namesById.get(id) ?? `Channel ${id}` }))
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [availableSubtitles]);

  // Keep the selection pointed at a current option. When the subtitle config reloads and the
  // selected source is no longer available, fall back to the first option (or clear it) instead
  // of leaving a stale id that the picker can't resolve and shows as "Choose source channel".
  useEffect(() => {
    if (!sourceOptions.some((o) => o.id === selectedSourceId)) {
      setSelectedSourceId(sourceOptions[0]?.id ?? null);
    }
  }, [sourceOptions, selectedSourceId]);

  const channelFilter = (channel: Channel): boolean => {
    switch (filterMode) {
      case "all":
        return true;
      case "hasSubtitles":
        return channel.hasSubtitles;
      case "noMatchingChannels":
        return false;
    }
  };

  const featuredFilter = (channel: Channel): boolean => {
    if (selectedSourceId == null) {
      return true;
    }
    return (
      channel.id === selectedSourceId ||
      channel.aiTranslationInfo?.sourceID === selectedSourceId
    );
  };

  const menuOptions: MenuOption[] = sourceOptions.map((option) => ({
    id: option.id,
    title: option.name,
  }));
  const selectedLabel =
    sourceOptions.find((o) => o.id === selectedSourceId)?.name ??
    "Choose source channel";

  return (
    <DemoScreen summary="Keep the standard LiveVoice list, but choose which channels appear — by any property, the empty state, or a source channel with its AI subtitles.">
      <DemoCardSection title="Filter by property">
        <LiveVoiceView filter={channelFilter} />
      </DemoCardSection>

      <DemoCardSection title="Controls">
        <SegmentedControl
          options={FILTER_OPTIONS}
          value={filterMode}
          onChange={setFilterMode}
        />
        <Text style={[styles.predicate, { color: theme.secondaryText }]}>
          {PREDICATE_DESCRIPTION[filterMode]}
        </Text>
      </DemoCardSection>

      <DemoCardSection title="Source and AI subtitles">
        {sourceOptions.length === 0 ? (
          <Text style={{ color: theme.secondaryText, fontSize: 15 }}>
            This event has no source channel with derived AI subtitles. The
            filter keeps the source channel plus any channel whose
            aiTranslationInfo.sourceID matches it.
          </Text>
        ) : (
          <>
            <LiveVoiceView filter={featuredFilter} />
            <MenuPicker
              selectedLabel={selectedLabel}
              options={menuOptions}
              selectedId={selectedSourceId}
              onSelect={(id) => setSelectedSourceId(id as number)}
            />
          </>
        )}
      </DemoCardSection>

      <DemoCardSection title="Implementation notes">
        <DemoNotes
          notes={[
            "You provide the filter to the LiveVoiceView.",
            "You can filter by any channel property and not just hard-coded IDs.",
            "A predicate that always returns false is useful for checking the no-matching-channels state.",
            "The source picker is derived from the demo event's available subtitle configuration.",
            "To feature a source channel, keep it plus any channel whose aiTranslationInfo.sourceID matches.",
          ]}
        />
      </DemoCardSection>
    </DemoScreen>
  );
};

const styles = StyleSheet.create({
  predicate: {
    fontSize: 13,
    fontFamily: "Courier",
  },
});
