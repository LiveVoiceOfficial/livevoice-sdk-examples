// Linked events
//
// An event can be linked to others, for example the rooms of a conference.
// `useLiveVoiceLinkedEvents` lists them, and `switchToLinkedEvent` leaves the
// joined event and joins the linked one with the same API key. LiveVoiceView
// then shows the new event's channels. The switch keeps your join's handle:
// its `leave()` then leaves the linked event.
//
// Needs: your own event with another event linked to it in the dashboard,
// and an API key that permits custom UI.
// Uses: useLiveVoiceLinkedEvents(), switchToLinkedEvent(event),
// useLiveVoiceCurrentEvent(), LiveVoiceLinkedEvent, useLiveVoiceFeatures()
// See also: Joining an event.

import React, { useState } from "react";
import {
  LiveVoiceView,
  switchToLinkedEvent,
  useLiveVoiceCurrentEvent,
  useLiveVoiceFeatures,
  useLiveVoiceLinkedEvents,
  type LiveVoiceError,
  type LiveVoiceLinkedEvent,
} from "livevoice-sdk-react-native";
import { DemoButton } from "../../demo/DemoControls";
import { DemoItemRow, DemoValueRow } from "../../demo/DemoRows";
import { DemoRequirement, DemoScreen, DemoSection } from "../../demo/DemoScreen";

export const LinkedEventsScreen: React.FC = () => {
  const { customUiAllowed } = useLiveVoiceFeatures();
  const currentEvent = useLiveVoiceCurrentEvent();
  const linkedEvents = useLiveVoiceLinkedEvents();
  const [failure, setFailure] = useState<LiveVoiceError | null>(null);

  /**
   * Resolves once the linked event is ready. A failed switch doesn't return
   * to the previous event; `reconnect()` tries the linked event again.
   */
  const switchTo = async (event: LiveVoiceLinkedEvent) => {
    setFailure(null);
    try {
      await switchToLinkedEvent(event);
    } catch (error) {
      const failed = error as LiveVoiceError;
      // A leave or a newer join or switch ended this one.
      if (failed.code === "cancelled" || failed.code === "superseded") return;
      setFailure(failed);
    }
  };

  return (
    <DemoScreen
      title="Linked events"
      caption="Switch to an event linked to this one."
      error={failure}
    >
      <DemoRequirement need="customUI" isMet={customUiAllowed} />
      {/* `null`: no event is ready, or the API key doesn't permit custom UI,
          which the note above covers. */}
      <DemoRequirement
        need={{ ownEvent: "Linked events" }}
        isMet={!customUiAllowed || (linkedEvents?.length ?? 0) > 0}
      />
      <DemoSection title="Events">
        <DemoValueRow label="Joined" value={currentEvent?.name ?? "None"} />
        {(linkedEvents ?? []).map((event) => (
          <DemoItemRow key={event.eventId} label={event.name}>
            <DemoButton plain title="Switch" onPress={() => void switchTo(event)} />
          </DemoItemRow>
        ))}
      </DemoSection>
      <DemoSection title="Channels">
        <LiveVoiceView />
      </DemoSection>
    </DemoScreen>
  );
};
