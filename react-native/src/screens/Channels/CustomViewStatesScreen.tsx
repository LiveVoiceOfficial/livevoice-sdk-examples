// Custom view states
//
// LiveVoiceView takes your own views for its states: `renderLoading`,
// `renderReconnecting`, `renderError` and `renderEmpty`; the parts you leave
// out keep the SDK's design. `onCommandError` receives the errors of the
// SDK's own controls. LiveVoiceView shows a part only while its state lasts,
// so the screen shows each of your views with sample values first. Below,
// LiveVoiceView uses them: turn on flight mode while a channel plays to see
// reconnecting and errors.
//
// Differs from iOS: the parts are render props, not modifiers. A scheduled
// retry carries a `Date`, and React Native has no self-updating relative
// time, so the reconnecting view counts down itself. `retry` is a function
// returning a promise, or `null` when trying again can't help.
//
// Needs: an API key that permits custom UI (except for `renderLoading`).
// Uses: LiveVoiceView renderLoading, renderReconnecting, renderError,
// renderEmpty, onCommandError, LiveVoiceRetry, LiveVoiceEmptyReason
// See also: Custom channel cell, Joining an event (connection and reconnect),
// Localization and accessibility (error messages).

import React, { useEffect, useState } from "react";
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from "react-native";
import {
  LiveVoiceError,
  LiveVoiceView,
  useLiveVoiceFeatures,
  type LiveVoiceEmptyReason,
  type LiveVoiceRetry,
} from "livevoice-sdk-react-native";
import { DemoLabeled } from "../../demo/DemoRows";
import {
  DemoNote,
  DemoRequirement,
  DemoScreen,
  DemoSection,
} from "../../demo/DemoScreen";
import { useDemoTheme } from "../../demo/DemoTheme";

export const CustomViewStatesScreen: React.FC = () => {
  const theme = useDemoTheme();
  const { customUiAllowed } = useLiveVoiceFeatures();
  const [failure, setFailure] = useState<LiveVoiceError | null>(null);
  // Sample values for the views below.
  const [sampleRetry] = useState<LiveVoiceRetry>(() => ({
    kind: "scheduled",
    at: new Date(Date.now() + 8000),
  }));

  return (
    <DemoScreen
      title="Custom view states"
      caption="Show loading, reconnecting, errors and no channels your way."
      error={failure}
    >
      <DemoRequirement need="customUI" isMet={customUiAllowed} />
      <DemoSection title="Your views, with sample values">
        <DemoLabeled label="Loading">
          <LoadingView />
        </DemoLabeled>
        <DemoLabeled label="Reconnecting">
          <ReconnectingView retry={sampleRetry} />
        </DemoLabeled>
        <DemoLabeled label="Error">
          <ErrorView error={new LiveVoiceError("no_network")} retry={async () => {}} />
        </DemoLabeled>
        <DemoLabeled label="No channels">
          <NoChannelsView reason="noChannels" />
        </DemoLabeled>
      </DemoSection>
      <DemoSection title="In LiveVoiceView">
        <DemoNote
          text="Your views show while their state lasts; while connected, the channels do."
          icon="info"
          tint={theme.secondaryText}
        />
        <LiveVoiceView
          renderLoading={() => <LoadingView />}
          renderReconnecting={(retry) => <ReconnectingView retry={retry} />}
          renderError={(error, retry) => <ErrorView error={error} retry={retry} />}
          renderEmpty={(reason) => <NoChannelsView reason={reason} />}
          // `cancelled` and `superseded` never arrive here. Your own parts get
          // their errors from their actions instead.
          onCommandError={setFailure}
        />
      </DemoSection>
    </DemoScreen>
  );
};

/** While the event loads. */
const LoadingView: React.FC = () => (
  <StateRow title="Loading channels…">
    <ActivityIndicator />
  </StateRow>
);

/**
 * Shown after the SDK kept the channel list, drawn disabled, for the first
 * seconds of a reconnection. The SDK reconnects by itself.
 */
const ReconnectingView: React.FC<{ retry: LiveVoiceRetry }> = ({ retry }) => {
  const seconds = useSecondsUntil(retry.kind === "scheduled" ? retry.at : null);
  const detail =
    retry.kind === "inProgress" || seconds === 0
      ? "Trying now…"
      : `Next try in ${seconds} s`;
  return (
    <StateRow title="Reconnecting" detail={detail}>
      <ActivityIndicator />
    </StateRow>
  );
};

/** The whole seconds until `date`, updated every second; `0` once it passed. */
function useSecondsUntil(date: Date | null): number {
  // Every delivery has a `Date` of its own; the time it holds is what counts.
  const time = date?.getTime() ?? null;
  const [seconds, setSeconds] = useState(() => secondsUntil(time));
  useEffect(() => {
    setSeconds(secondsUntil(time));
    if (time === null) return;
    const timer = setInterval(() => setSeconds(secondsUntil(time)), 1000);
    return () => clearInterval(timer);
  }, [time]);
  return seconds;
}

function secondsUntil(time: number | null): number {
  return time === null ? 0 : Math.max(0, Math.ceil((time - Date.now()) / 1000));
}

/**
 * Shows the error's `message`, the SDK's text for it. `retry` is there
 * exactly when trying again can help.
 */
const ErrorView: React.FC<{
  error: LiveVoiceError;
  retry: (() => Promise<void>) | null;
}> = ({ error, retry }) => {
  const theme = useDemoTheme();
  return (
    <StateRow title="Couldn't connect" detail={error.message} symbol="!">
      {retry && (
        <Pressable
          accessibilityRole="button"
          // A failed retry shows up as the view's next error.
          onPress={() => void retry().catch(() => {})}
          style={[styles.retry, { backgroundColor: theme.accent }]}
        >
          <Text style={styles.retryText}>Try again</Text>
        </Pressable>
      )}
    </StateRow>
  );
};

const NoChannelsView: React.FC<{ reason: LiveVoiceEmptyReason }> = ({
  reason,
}) => (
  <StateRow
    title={
      reason === "noChannels"
        ? "This event has no channels yet."
        : // The view's filter matches none of the event's channels.
          "No matching channels."
    }
    symbol="∅"
  />
);

/**
 * The look the state views share with a channel row: an icon, a title, a
 * detail line, and an accessory on the trailing side, in a card.
 */
const StateRow: React.FC<{
  title: string;
  detail?: string;
  symbol?: string;
  children?: React.ReactNode;
}> = ({ title, detail, symbol, children }) => {
  const theme = useDemoTheme();
  return (
    <View style={[styles.card, { backgroundColor: theme.cardFill }]}>
      {symbol != null && (
        <Text style={[styles.symbol, { color: theme.secondaryText }]}>{symbol}</Text>
      )}
      <View style={styles.text}>
        <Text style={[styles.title, { color: theme.text }]}>{title}</Text>
        {detail != null && (
          <Text style={[styles.detail, { color: theme.secondaryText }]}>{detail}</Text>
        )}
      </View>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    padding: 16,
    borderRadius: 16,
  },
  symbol: {
    width: 24,
    textAlign: "center",
    fontSize: 17,
    fontWeight: "700",
  },
  text: {
    flex: 1,
    gap: 4,
  },
  title: {
    fontSize: 17,
    fontWeight: "600",
  },
  detail: {
    fontSize: 12,
  },
  retry: {
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 7,
  },
  retryText: {
    color: "#FFFFFF",
    fontSize: 15,
    fontWeight: "600",
  },
});
