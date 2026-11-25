// Demo scaffolding — not needed for an integration.
//
// The look every demo screen shares, so that a screen's own file reads as
// LiveVoice SDK usage: the screen shell, the grouped sections and the one-line
// note on what a screen needs from the event.

import React from "react";
import {
  ActivityIndicator,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from "react-native";
import { useNavigation } from "@react-navigation/native";
import type { NativeStackNavigationProp } from "@react-navigation/native-stack";
import {
  useLiveVoiceConnection,
  useLiveVoiceSubtitles,
  type LiveVoiceError,
} from "livevoice-sdk-react-native";
import type { DemoStackParamList } from "./DemoNavigation";
import { useDemoSession } from "./DemoSession";
import { useDemoTheme } from "./DemoTheme";

/**
 * A demo screen: a scrolling column of `DemoSection`s under a title, with a
 * one-sentence caption.
 *
 * `error` shows a failed call's message in one line under the caption, the
 * text the SDK provides for it. While subtitles are on, the screen links to
 * the Subtitles screen, unless it is the one that shows them (`showsSubtitles`).
 */
export const DemoScreen: React.FC<{
  title: string;
  caption: string;
  error?: LiveVoiceError | null;
  showsSubtitles?: boolean;
  children: React.ReactNode;
}> = ({ title, caption, error, showsSubtitles = false, children }) => {
  const theme = useDemoTheme();
  const subtitles = useLiveVoiceSubtitles();
  const navigation =
    useNavigation<NativeStackNavigationProp<DemoStackParamList>>();

  return (
    <ScrollView
      style={{ backgroundColor: theme.pageBackground }}
      contentContainerStyle={styles.page}
      keyboardShouldPersistTaps="handled"
    >
      <View style={styles.heading}>
        <Text
          accessibilityRole="header"
          style={[styles.title, { color: theme.text }]}
        >
          {title}
        </Text>
        <Text style={[styles.caption, { color: theme.secondaryText }]}>
          {caption}
        </Text>
      </View>
      {error != null && (
        <DemoNote text={error.message} icon="error" tint={theme.red} />
      )}
      {subtitles.kind !== "disabled" && !showsSubtitles && (
        <Pressable
          accessibilityRole="link"
          onPress={() => navigation.push("Subtitles")}
        >
          <DemoNote
            text="Go to the Subtitles section to see them in action."
            icon="subtitles"
            tint={theme.accent}
          />
        </Pressable>
      )}
      {children}
    </ScrollView>
  );
};

/** A titled, rounded box that groups part of a demo screen. */
export const DemoSection: React.FC<{
  title: string;
  children: React.ReactNode;
}> = ({ title, children }) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.section}>
      {/* Above the box, like a grouped list's header, so it never reads as
          part of the content. */}
      <Text
        accessibilityRole="header"
        style={[styles.sectionTitle, { color: theme.secondaryText }]}
      >
        {title.toUpperCase()}
      </Text>
      <View
        style={[
          styles.sectionBox,
          { backgroundColor: theme.sectionFill, borderColor: theme.sectionStroke },
        ]}
      >
        {children}
      </View>
    </View>
  );
};

/**
 * What a demo screen needs beyond the demo event:
 * - `"customUI"`: an API key that permits custom UI, the "Full
 *   customization" preset.
 * - `{ ownEvent: feature }`: an event with `feature` enabled in the Admin
 *   console, which the demo event lacks. With your own event, the note says
 *   that this event doesn't have it enabled.
 */
export type DemoNeed = "customUI" | { ownEvent: string };

/**
 * What a demo screen needs beyond the demo event, said in one line while it
 * is missing, with a button to pick another event or API key. Until an event
 * is ready it says it waits instead: permissions and features are only
 * known once joined.
 */
export const DemoRequirement: React.FC<{ need: DemoNeed; isMet: boolean }> = ({
  need,
  isMet,
}) => {
  const theme = useDemoTheme();
  const connection = useLiveVoiceConnection();
  const { usesOwnEvent, presentPicker } = useDemoSession();
  const eventIsReady =
    connection.status === "ready" || connection.status === "reconnecting";

  if (!eventIsReady) {
    return (
      <DemoNote
        text="Waiting for the event…"
        icon="waiting"
        tint={theme.secondaryText}
      />
    );
  }
  if (isMet) return null;

  const text =
    need === "customUI"
      ? "Needs an API key that permits custom UI."
      : usesOwnEvent
        ? `This event doesn't have the '${need.ownEvent}' feature enabled. Enable this in the Admin console on the web.`
        : `The demo event doesn't have the '${need.ownEvent}' feature enabled. To try it, use your own event and enable the feature in the Admin console on the web.`;
  const buttonTitle =
    need === "customUI"
      ? "Choose an API key"
      : usesOwnEvent
        ? "Use another event"
        : "Use your own event";

  return (
    <View style={[styles.requirement, { backgroundColor: `${theme.orange}1F` }]}>
      <DemoIcon kind="warning" tint={theme.orange} />
      <View style={styles.requirementText}>
        <Text style={[styles.subheadline, { color: theme.text }]}>{text}</Text>
        <Pressable
          accessibilityRole="button"
          hitSlop={8}
          onPress={() =>
            presentPicker(need === "customUI" ? "apiKeys" : "ownEvent")
          }
        >
          <Text style={[styles.requirementButton, { color: theme.accent }]}>
            {buttonTitle}
          </Text>
        </Pressable>
      </View>
    </View>
  );
};

export type DemoIconKind = "info" | "error" | "warning" | "subtitles" | "waiting";

/** One line of information on a demo screen, with an icon. */
export const DemoNote: React.FC<{
  text: string;
  icon: DemoIconKind;
  tint: string;
}> = ({ text, icon, tint }) => (
  <View style={styles.note}>
    <DemoIcon kind={icon} tint={tint} />
    <Text style={[styles.noteText, { color: tint }]}>{text}</Text>
  </View>
);

/**
 * A small outlined label for one of a channel's properties in a custom cell:
 * full contrast when `isOn`, faint when not, so every value stays visible.
 * Your app draws its own.
 */
export const DemoTag: React.FC<{ text: string; isOn?: boolean }> = ({
  text,
  isOn = true,
}) => {
  const theme = useDemoTheme();
  const primary = (alpha: number) =>
    theme.dark ? `rgba(255,255,255,${alpha})` : `rgba(0,0,0,${alpha})`;
  return (
    <View style={[styles.tag, { borderColor: primary(isOn ? 0.85 : 0.16) }]}>
      <Text
        numberOfLines={1}
        style={[styles.tagText, { color: primary(isOn ? 1 : 0.3) }]}
      >
        {text}
      </Text>
    </View>
  );
};

/** A small drawn icon, the same on iOS and Android. */
const DemoIcon: React.FC<{ kind: DemoIconKind; tint: string }> = ({
  kind,
  tint,
}) => {
  switch (kind) {
    case "waiting":
      return (
        <View style={styles.icon}>
          <ActivityIndicator size="small" color={tint} style={styles.spinner} />
        </View>
      );
    case "warning":
      return (
        <View style={[styles.icon, styles.round, { backgroundColor: tint }]}>
          <Text style={[styles.iconGlyph, { color: "#FFFFFF" }]}>!</Text>
        </View>
      );
    case "subtitles":
      return (
        <View style={[styles.icon, styles.box, { borderColor: tint }]}>
          <Text style={[styles.iconGlyphSmall, { color: tint }]}>CC</Text>
        </View>
      );
    case "info":
    case "error":
      return (
        <View style={[styles.icon, styles.round, styles.outline, { borderColor: tint }]}>
          <Text style={[styles.iconGlyph, { color: tint }]}>
            {kind === "info" ? "i" : "!"}
          </Text>
        </View>
      );
  }
};

const styles = StyleSheet.create({
  page: {
    padding: 20,
    gap: 24,
  },
  heading: {
    gap: 10,
  },
  title: {
    fontSize: 34,
    fontWeight: "600",
  },
  caption: {
    fontSize: 17,
    lineHeight: 22,
  },
  section: {
    gap: 8,
  },
  sectionTitle: {
    fontSize: 13,
    fontWeight: "600",
    paddingHorizontal: 4,
  },
  sectionBox: {
    gap: 12,
    padding: 16,
    borderRadius: 16,
    borderWidth: 1,
  },
  requirement: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 12,
    padding: 14,
    borderRadius: 14,
  },
  requirementText: {
    flex: 1,
    gap: 8,
    alignItems: "flex-start",
  },
  requirementButton: {
    fontSize: 15,
    fontWeight: "600",
  },
  subheadline: {
    fontSize: 15,
    lineHeight: 20,
  },
  note: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 8,
  },
  noteText: {
    flex: 1,
    fontSize: 13,
    lineHeight: 18,
  },
  tag: {
    borderWidth: 0.5,
    borderRadius: 999,
    paddingHorizontal: 8,
    paddingVertical: 2,
  },
  tagText: {
    fontSize: 11,
    fontWeight: "500",
  },
  icon: {
    width: 16,
    height: 16,
    marginTop: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  spinner: {
    transform: [{ scale: 0.7 }],
  },
  round: {
    borderRadius: 8,
  },
  outline: {
    borderWidth: 1.2,
  },
  box: {
    borderWidth: 1.2,
    borderRadius: 3,
  },
  iconGlyph: {
    fontSize: 10,
    fontWeight: "800",
  },
  iconGlyphSmall: {
    fontSize: 7,
    fontWeight: "800",
  },
});
