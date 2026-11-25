// Subtitles
//
// `startSubtitles` with no channel follows whatever channel plays; with a
// channel from `useLiveVoiceAvailableSubtitles` it shows that subtitle stream,
// playing or not. `useLiveVoiceSubtitles` holds the state and its fragments
// for your own view, and `stopSubtitles` ends them. You don't need
// LiveVoiceView for subtitles.
//
// Differs from iOS: the options are one object, `{ channelId, password }`,
// with `channelId` a number. The feed is a ScrollView inside the screen's
// ScrollView, which on Android scrolls only with `nestedScrollEnabled`.
//
// Uses: useLiveVoiceAvailableSubtitles(), startSubtitles({ channelId, password }),
// stopSubtitles(), useLiveVoiceSubtitles(), LiveVoiceSubtitleState
// See also: Filtering channels (channels with subtitles), Password-protected
// channels (subtitles of a protected channel).

import React, { useRef, useState } from "react";
import { ScrollView, StyleSheet, Text } from "react-native";
import {
  LiveVoiceView,
  startSubtitles,
  stopSubtitles,
  useLiveVoiceAvailableSubtitles,
  useLiveVoiceSubtitles,
  type LiveVoiceError,
} from "livevoice-sdk-react-native";
import { DemoButton, DemoButtonRow, DemoMenuPicker } from "../../demo/DemoControls";
import { DemoPlaceholder } from "../../demo/DemoRows";
import { DemoScreen, DemoSection } from "../../demo/DemoScreen";
import { useDemoTheme } from "../../demo/DemoTheme";

export const SubtitlesScreen: React.FC = () => {
  // `null` until known, `[]` when the event has none.
  const availableSubtitles = useLiveVoiceAvailableSubtitles();
  /** `null` follows the playing channel. */
  const [channelId, setChannelId] = useState<number | null>(null);
  const [failure, setFailure] = useState<LiveVoiceError | null>(null);

  /**
   * One subtitle stream at a time: starting another replaces it, without a
   * stop in between. Subtitles never start, stop or switch playback.
   */
  const start = async () => {
    setFailure(null);
    try {
      await startSubtitles({ channelId });
    } catch (error) {
      setFailure(error as LiveVoiceError);
    }
  };

  const stop = async () => {
    setFailure(null);
    try {
      await stopSubtitles();
    } catch (error) {
      setFailure(error as LiveVoiceError);
    }
  };

  return (
    <DemoScreen
      title="Subtitles"
      caption="Show a channel's live subtitles in your own view."
      error={failure}
      showsSubtitles
    >
      <DemoSection title="Subtitles">
        <SubtitleView />
      </DemoSection>
      <DemoSection title="Source">
        <DemoMenuPicker
          label="Subtitles"
          value={channelId}
          onChange={setChannelId}
          options={[
            { label: "Playing channel", value: null },
            // A `null` language is the channel's original transcript.
            ...(availableSubtitles ?? []).map((subtitle) => ({
              label:
                subtitle.language === null
                  ? `${subtitle.name} (original)`
                  : subtitle.name,
              value: subtitle.channelId,
            })),
          ]}
        />
        <DemoButtonRow>
          <DemoButton title="Start" onPress={() => void start()} />
          <DemoButton title="Stop" onPress={() => void stop()} />
        </DemoButtonRow>
      </DemoSection>
      <DemoSection title="Channels">
        {/* Following subtitles show the channel playing here. */}
        <LiveVoiceView />
      </DemoSection>
    </DemoScreen>
  );
};

/**
 * Your own subtitle view: the fragments of `useLiveVoiceSubtitles()` in a
 * fixed-height scroll view that shows the newest text.
 *
 * It scrolls to the end on every change, also when the last fragment only
 * grows (the SDK appends an unfinished sentence to it) and also when you
 * scrolled up to read. A real app would usually follow only while the
 * reader is at the bottom.
 */
const SubtitleView: React.FC = () => {
  const subtitles = useLiveVoiceSubtitles();
  if (subtitles.kind === "disabled") {
    return <DemoPlaceholder text="Start subtitles to see them here." />;
  }
  if (subtitles.fragments.length === 0) {
    return <DemoPlaceholder text="Waiting for the first words…" />;
  }
  return <Feed fragments={subtitles.fragments} />;
};

const Feed: React.FC<{ fragments: string[] }> = ({ fragments }) => {
  const theme = useDemoTheme();
  const scrollView = useRef<ScrollView>(null);
  return (
    <ScrollView
      ref={scrollView}
      style={styles.feed}
      // Lets the feed scroll inside the screen's scroll view on Android.
      nestedScrollEnabled
      // After the layout of the changed text, so the end is where it now is.
      onContentSizeChange={() => scrollView.current?.scrollToEnd({ animated: true })}
    >
      {fragments.map((fragment, index) => (
        <Text key={index} style={[styles.fragment, { color: theme.text }]}>
          {fragment}
        </Text>
      ))}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  feed: {
    height: 220,
  },
  fragment: {
    fontSize: 17,
    lineHeight: 22,
    marginBottom: 8,
  },
});
