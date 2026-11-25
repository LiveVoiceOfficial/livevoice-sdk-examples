// Diagnostics log
//
// The SDK reports what it does as named events, such as `LV_JOIN_RESULT` or
// `LV_CHANNEL_RESULT`, each with a level and a few fields; a failure carries
// its error `code`. They go to the system log, and `addLogListener` forwards
// them to your own logging. Tap a channel to see some.
//
// Differs from iOS: any number of listeners, each with its own subscription
// that `remove()` ends, in place of the single `setLogListener`. Entries
// arrive on the JavaScript thread from `initialize()` on and are not
// replayed, so add a listener early to see everything. The stream also holds
// the React Native package's own entries, such as `LV_COMMAND_ERROR` for a
// default control's failure without `onCommandError`, and `LV_USAGE_ERROR`
// explaining an `invalid_argument` or `not_initialized`.
//
// Uses: addLogListener(listener), LiveVoiceLogEntry, LiveVoiceLogLevel
// See also: Joining an event, Localization and accessibility (error messages).

import React, { useEffect, useRef, useState } from "react";
import { StyleSheet, Text, View } from "react-native";
import {
  addLogListener,
  LiveVoiceView,
  type LiveVoiceLogEntry,
} from "livevoice-sdk-react-native";
import { DemoPlaceholder } from "../../demo/DemoRows";
import { DemoScreen, DemoSection } from "../../demo/DemoScreen";
import { demoMonospace, useDemoTheme } from "../../demo/DemoTheme";

export const DiagnosticsScreen: React.FC = () => {
  /** The latest entries, newest first, each numbered to key its row. */
  const [entries, setEntries] = useState<{ id: number; entry: LiveVoiceLogEntry }[]>([]);

  const count = useRef(0);

  useEffect(() => {
    // Return quickly, and never call the SDK from the listener.
    const subscription = addLogListener((entry) => {
      const id = ++count.current;
      setEntries((latest) => [{ id, entry }, ...latest].slice(0, 100));
    });
    // Leaving the screen ends the subscription.
    return () => subscription.remove();
  }, []);

  return (
    <DemoScreen
      title="Diagnostics log"
      caption="Read what the SDK did, and why a call failed."
    >
      <DemoSection title="Channels">
        <LiveVoiceView />
      </DemoSection>
      <DemoSection title="Log">
        {entries.length === 0 && (
          <DemoPlaceholder text="Nothing logged yet: tap a channel." />
        )}
        {entries.map(({ id, entry }) => (
          <LogEntryRow key={id} entry={entry} />
        ))}
      </DemoSection>
    </DemoScreen>
  );
};

/**
 * One entry: its event, level, time and fields. Entries never contain a
 * password or an API key.
 */
const LogEntryRow: React.FC<{ entry: LiveVoiceLogEntry }> = ({ entry }) => {
  const theme = useDemoTheme();
  const fields = Object.entries(entry.fields)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, value]) => `${key}=${value}`)
    .join(" ");
  return (
    <View style={styles.entry}>
      <View style={styles.heading}>
        <Text
          style={[
            styles.event,
            { color: entry.level === "error" ? theme.red : theme.text },
          ]}
        >
          {entry.event}
        </Text>
        <Text style={[styles.time, { color: theme.secondaryText }]}>
          {entry.timestamp.toLocaleTimeString()}
        </Text>
      </View>
      <Text style={[styles.fields, { color: theme.secondaryText }]}>{fields}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  entry: {
    gap: 4,
  },
  heading: {
    flexDirection: "row",
    justifyContent: "space-between",
    gap: 8,
  },
  event: {
    flexShrink: 1,
    fontSize: 15,
    fontWeight: "600",
    fontFamily: demoMonospace,
  },
  time: {
    fontSize: 12,
  },
  fields: {
    fontSize: 12,
    fontFamily: demoMonospace,
  },
});
