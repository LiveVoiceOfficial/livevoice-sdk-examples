// Joining an event
//
// `joinEvent` joins an event and resolves once it is ready; joining again
// leaves the previous one. It resolves with a LiveVoiceJoinedEvent whose
// `leave()` leaves only that join. `useLiveVoiceConnection` says where the
// connection is and `reconnect` reconnects at once. The demo joins the event
// picked in the header at launch; here you make the calls yourself.
//
// Differs from iOS: await `initialize()` once before the first join; the demo
// does it at launch (DemoSession). `joinEvent` takes one request object.
// TypeScript types a caught value as `unknown`; the SDK's promises reject
// only with a LiveVoiceError, so the screens cast it.
//
// Uses: joinEvent({ joinCode, password, apiKey }),
// LiveVoiceJoinedEvent.leave(), leaveEvent(), useLiveVoiceConnection(), reconnect()
// See also: Default interface, Custom view states (how LiveVoiceView shows each state).

import React, { useState } from "react";
import {
  joinEvent,
  leaveEvent,
  LiveVoiceView,
  reconnect,
  useLiveVoiceConnection,
  type LiveVoiceConnection,
  type LiveVoiceError,
  type LiveVoiceJoinedEvent,
} from "livevoice-sdk-react-native";
import { DemoButton, DemoButtonRow } from "../../demo/DemoControls";
import { DemoValueRow } from "../../demo/DemoRows";
import { DemoScreen, DemoSection } from "../../demo/DemoScreen";
import { useDemoSession } from "../../demo/DemoSession";

export const JoiningEventScreen: React.FC = () => {
  const { selectedPreset } = useDemoSession();
  const connection = useLiveVoiceConnection();
  // The join made on this screen. A screen that owns its event would leave
  // it with `joined.leave()` in an effect's cleanup; this demo doesn't,
  // because every screen shares the event.
  const [joined, setJoined] = useState<LiveVoiceJoinedEvent | null>(null);
  const [failure, setFailure] = useState<LiveVoiceError | null>(null);

  const isBusy =
    connection.status === "joining" || connection.status === "leaving";
  const canLeave =
    connection.status !== "idle" && connection.status !== "leaving";
  // `reconnect()` works while the event is ready or reconnecting, and after a
  // failure that `isRetryable`; otherwise it rejects.
  const canReconnect =
    connection.status === "ready" ||
    connection.status === "reconnecting" ||
    (connection.status === "failed" && connection.error.isRetryable);

  /** Resolves once the event is ready. Joining again leaves the previous event. */
  const join = async () => {
    // The join code, password and API key of the event picked in the header.
    const { joinCode, password, apiKey } = selectedPreset;
    setFailure(null);
    // The new join replaces the old one, so forget the old one now: while
    // this join is pending or after it fails, Leave uses `leaveEvent()`.
    setJoined(null);
    try {
      setJoined(await joinEvent({ joinCode, password, apiKey }));
    } catch (error) {
      const failed = error as LiveVoiceError;
      // A leave or a newer join ended this one; nothing went wrong.
      if (failed.code === "cancelled" || failed.code === "superseded") return;
      setFailure(failed);
    }
  };

  /**
   * Works while the event is ready or reconnecting, and after a failure
   * whose error `isRetryable`; the playing channel is restored.
   */
  const reconnectNow = async () => {
    setFailure(null);
    try {
      await reconnect();
    } catch (error) {
      const failed = error as LiveVoiceError;
      // A newer join, switch or reconnect took over, or a leave ended it;
      // nothing went wrong.
      if (failed.code === "cancelled" || failed.code === "superseded") return;
      setFailure(failed);
    }
  };

  /**
   * After a join on this screen, leaves only that join: never a newer one,
   * such as after you pick another event in the header (then it does
   * nothing). Before it, leaves whatever is joined: here the event the
   * header joined.
   */
  const leave = async () => {
    setFailure(null);
    try {
      if (joined) {
        await joined.leave();
      } else {
        await leaveEvent();
      }
      setJoined(null);
    } catch (error) {
      setFailure(error as LiveVoiceError);
    }
  };

  return (
    <DemoScreen
      title="Joining an event"
      caption="Join, reconnect and leave the event yourself."
      error={failure}
    >
      <DemoSection title="Connection">
        <DemoValueRow label="State" value={describe(connection)} />
        <DemoValueRow
          label="Joined from this screen"
          value={joined ? "Yes" : "No"}
        />
        <DemoButtonRow>
          <DemoButton title="Leave" destructive disabled={!canLeave} onPress={() => void leave()} />
          <DemoButton title="Join" disabled={isBusy} onPress={() => void join()} />
          <DemoButton title="Reconnect" disabled={!canReconnect} onPress={() => void reconnectNow()} />
        </DemoButtonRow>
      </DemoSection>
      <DemoSection title="Channels">
        <LiveVoiceView />
      </DemoSection>
    </DemoScreen>
  );
};

function describe(connection: LiveVoiceConnection): string {
  switch (connection.status) {
    case "idle":
      return "Idle";
    case "joining":
      return "Joining";
    case "ready":
      return `Ready, event ${connection.eventId}`;
    // The SDK reconnects by itself; `reconnect()` tries at once.
    case "reconnecting":
      return "Reconnecting";
    case "leaving":
      return "Leaving";
    case "failed":
      return `Failed: ${connection.error.message}`;
  }
}
