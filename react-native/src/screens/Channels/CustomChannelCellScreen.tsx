// Custom channel cell
//
// `renderChannelCell` draws each channel with your own view. The cell gets a
// LiveVoiceChannelCell: the channel, whether it is the last one, whether its
// action may be used now (`isEnabled`), and the action, `togglePlayback()`.
// The SDK keeps the session, playback and reconnection. Both cells read
// out with the SDK's accessibility texts (`Translations.accessibility…()`).
//
// Differs from iOS: the view calls `renderChannelCell` again with a new,
// frozen cell on every change, such as a speaker going online, so a cell
// reads `cell.channel` as given and never keeps an older cell. Each cell is
// keyed by its channel, so state inside it, like the failure line, stays.
// The SDK's texts are functions (`Translations.accessibilityChannelPlay()`),
// not the iOS `LiveVoiceLocalization.a11y_…` constants.
//
// Needs: an API key that permits custom UI.
// Uses: LiveVoiceView renderChannelCell, LiveVoiceChannelCell, LiveVoiceChannel,
// useLiveVoiceFeatures(), Translations
// See also: Custom view states, Localization and accessibility (the SDK's texts
// for your cells).

import React, { useState } from "react";
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from "react-native";
import {
  LiveVoiceView,
  Translations,
  useLiveVoiceFeatures,
  type LiveVoiceChannel,
  type LiveVoiceChannelCell,
  type LiveVoiceError,
  type LiveVoicePlayingState,
} from "livevoice-sdk-react-native";
import { DemoRequirement, DemoScreen, DemoSection, DemoTag } from "../../demo/DemoScreen";
import { useDemoTheme } from "../../demo/DemoTheme";

export const CustomChannelCellScreen: React.FC = () => {
  const { customUiAllowed } = useLiveVoiceFeatures();
  return (
    <DemoScreen
      title="Custom channel cell"
      caption="Draw each channel with your own view."
    >
      <DemoRequirement need="customUI" isMet={customUiAllowed} />
      <DemoSection title="Simple cell">
        <LiveVoiceView renderChannelCell={(cell) => <ChannelCell cell={cell} />} />
      </DemoSection>
      <DemoSection title="Detailed cell">
        <LiveVoiceView
          renderChannelCell={(cell) => <DetailedChannelCell cell={cell} />}
        />
      </DemoSection>
    </DemoScreen>
  );
};

/**
 * A channel row of your own: the name, a status line and a play button.
 * Cells are laid out flush to the view's edges, so the cell sets its own
 * padding and divider.
 */
const ChannelCell: React.FC<{ cell: LiveVoiceChannelCell }> = ({ cell }) => {
  const theme = useDemoTheme();
  const { channel } = cell;
  const [failure, setFailure] = useState<LiveVoiceError | null>(null);

  /**
   * Starts the channel if it is stopped and stops it if it plays, decided
   * when it runs. Resolves once the channel plays or has stopped.
   */
  const togglePlayback = async () => {
    setFailure(null);
    try {
      await cell.togglePlayback();
    } catch (error) {
      setFailure(error as LiveVoiceError);
    }
  };

  return (
    <View>
      <Pressable
        onPress={() => void togglePlayback()}
        // `false` while the channel is offline, has no audio, or the
        // connection recovers: draw the cell as unavailable then.
        disabled={!cell.isEnabled}
        accessibilityRole="button"
        accessibilityState={{ disabled: !cell.isEnabled }}
        accessibilityLabel={channel.name}
        accessibilityValue={{ text: accessibilityStatus(channel, failure) }}
        accessibilityHint={accessibilityHint(channel.playingState)}
        style={[styles.row, !cell.isEnabled && styles.unavailable]}
      >
        <View style={styles.text}>
          <Text style={[styles.name, { color: theme.text }]}>{channel.name}</Text>
          <Text style={[styles.status, { color: theme.secondaryText }]}>
            {failure?.message ?? status(channel)}
          </Text>
        </View>
        <PlaybackIcon state={channel.playingState} color={theme.accent} />
      </Pressable>
      {!cell.isLast && (
        <View style={[styles.divider, { backgroundColor: theme.separator }]} />
      )}
    </View>
  );
};

function status(channel: LiveVoiceChannel): string {
  if (!channel.isOnline) return "Offline";
  // The SDK plays no video: a channel with video and audio plays its audio,
  // one with only video cannot be played (`hasAudio` is false).
  if (!channel.hasAudio) return channel.hasVideo ? "Video only" : "No audio";
  if (channel.aiTranslationInfo) {
    return `AI translation, ${channel.aiTranslationInfo.targetLanguage}`;
  }
  return channel.hasSubtitles ? "With subtitles" : "Ready";
}

/**
 * What a screen reader reads after the name: a failed tap's message, as
 * shown, or the playing state.
 */
function accessibilityStatus(
  channel: LiveVoiceChannel,
  failure: LiveVoiceError | null,
): string {
  if (failure) return failure.message;
  const playing = {
    playing: "Playing",
    transitioning: "Connecting",
    stopped: "Stopped",
  }[channel.playingState];
  return channel.isOnline ? playing : `Offline, ${playing}`;
}

/** The SDK's localized text for the cell's action. */
function accessibilityHint(state: LiveVoicePlayingState): string {
  return state === "stopped"
    ? Translations.accessibilityChannelPlay()
    : Translations.accessibilityChannelStop();
}

/**
 * A richer row that shows what you can read from `LiveVoiceChannel`: the
 * online dot, every Boolean as a tag (faint when false, so all of them stay
 * visible even where a feature doesn't apply), the AI translation, the
 * channels that translate this one, and the playing state. Each channel is
 * a card of its own.
 */
const DetailedChannelCell: React.FC<{ cell: LiveVoiceChannelCell }> = ({
  cell,
}) => {
  const theme = useDemoTheme();
  const { channel } = cell;
  const [failure, setFailure] = useState<LiveVoiceError | null>(null);

  const togglePlayback = async () => {
    setFailure(null);
    try {
      await cell.togglePlayback();
    } catch (error) {
      setFailure(error as LiveVoiceError);
    }
  };

  const tint = cell.isEnabled ? theme.accent : theme.gray;
  return (
    <Pressable
      onPress={() => void togglePlayback()}
      // `false` while the channel is offline, has no audio, or the
      // connection recovers: the cell looks and acts unavailable then.
      disabled={!cell.isEnabled}
      // Read as one element, so the faint tags aren't read out.
      accessible
      accessibilityRole="button"
      accessibilityState={{ disabled: !cell.isEnabled }}
      accessibilityLabel={channel.name}
      accessibilityValue={{ text: detailedAccessibilityValue(channel, failure) }}
      accessibilityHint={accessibilityHint(channel.playingState)}
      style={[
        styles.card,
        { backgroundColor: theme.cardFill, marginBottom: cell.isLast ? 0 : 12 },
      ]}
    >
      <View
        style={[
          styles.dot,
          { backgroundColor: channel.isOnline ? theme.green : theme.gray },
        ]}
      />
      <View style={styles.details}>
        <Text style={[styles.name, { color: theme.text }]}>{channel.name}</Text>
        <Text
          style={[
            styles.status,
            { color: failure ? theme.red : theme.secondaryText },
          ]}
        >
          {failure?.message ?? detailedStatus(channel)}
        </Text>
        <View style={styles.tags}>
          <DemoTag text="Audio" isOn={channel.hasAudio} />
          {/* The SDK plays no video; of a channel with both it plays the audio. */}
          <DemoTag text="Video" isOn={channel.hasVideo} />
          <DemoTag text="Subtitles" isOn={channel.hasSubtitles} />
          <DemoTag text="Muted" isOn={channel.isAudioMuted} />
        </View>
        <View style={styles.tags}>
          <DemoTag text="Password" isOn={channel.isPasswordProtected} />
          <DemoTag text="AI voice" isOn={channel.isAiSpeaker} />
          <DemoTag text="On demand" isOn={channel.isOnDemand} />
        </View>
        {channel.dependentChannels.length > 0 && (
          // Channels that translate this one, such as an AI voice.
          <Text style={[styles.status, { color: theme.secondaryText }]}>
            {`Translations: ${channel.dependentChannels.map((c) => c.name).join(", ")}`}
          </Text>
        )}
      </View>
      <View
        style={[
          styles.playButton,
          { backgroundColor: `${theme.accent}${cell.isEnabled ? "1F" : "0D"}` },
        ]}
      >
        <PlaybackIcon state={channel.playingState} color={tint} />
      </View>
    </Pressable>
  );
};

function detailedStatus(channel: LiveVoiceChannel): string {
  if (!channel.isOnline) return "Inactive";
  if (channel.aiTranslationInfo) {
    return `AI translation into ${channel.aiTranslationInfo.targetLanguage}`;
  }
  switch (channel.playingState) {
    case "playing":
      return "Currently playing";
    case "transitioning":
      return "Connecting…";
    case "stopped":
      return channel.hasAudio ? "Ready to start" : "Nothing to play";
  }
}

/**
 * The status line and only the properties that are true, the way the tags
 * show them at full contrast.
 */
function detailedAccessibilityValue(
  channel: LiveVoiceChannel,
  failure: LiveVoiceError | null,
): string {
  const properties: [boolean, string][] = [
    [channel.hasAudio, "Audio"],
    [channel.hasVideo, "Video"],
    [channel.hasSubtitles, "Subtitles"],
    // The SDK's localized text for a muted channel.
    [channel.isAudioMuted, Translations.accessibilityChannelStatusMuted()],
    [channel.isPasswordProtected, "Password"],
    [channel.isAiSpeaker, "AI voice"],
    [channel.isOnDemand, "On demand"],
  ];
  const line = failure?.message ?? detailedStatus(channel);
  return [line, ...properties.filter(([isOn]) => isOn).map(([, text]) => text)].join(", ");
}

/** Play, connecting or stop, for a channel's `playingState`. */
const PlaybackIcon: React.FC<{ state: LiveVoicePlayingState; color: string }> = ({
  state,
  color,
}) =>
  state === "transitioning" ? (
    <ActivityIndicator size="small" color={color} />
  ) : (
    <Text style={[styles.icon, { color }]}>{state === "playing" ? "■" : "▶"}</Text>
  );

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    paddingVertical: 12,
  },
  unavailable: {
    opacity: 0.4,
  },
  text: {
    flex: 1,
    gap: 4,
  },
  name: {
    fontSize: 17,
    fontWeight: "600",
  },
  status: {
    fontSize: 12,
  },
  divider: {
    height: StyleSheet.hairlineWidth,
  },
  icon: {
    fontSize: 16,
  },
  card: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 12,
    padding: 16,
    borderRadius: 16,
  },
  dot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginTop: 6,
  },
  details: {
    flex: 1,
    gap: 6,
  },
  tags: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 6,
  },
  playButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: "center",
    justifyContent: "center",
  },
});
