// Lock screen and audio sharing
//
// `audioFocus` decides what happens to other audio while a channel plays.
// With `'exclusive'`, the default, the playing channel appears on the Lock
// Screen and in Control Center, unless `showsSystemMediaControls` is off;
// `setNowPlayingArtwork` replaces the event's logo there. Best tried on a
// device: play a channel, then lock the phone. The settings are the SDK's,
// so they apply to the whole app, not just this screen.
//
// As on iOS, `audioFocus` and `showsSystemMediaControls` are options of
// `initialize()`, here together with `androidServiceConfig`. The SDK doesn't
// report them, so the app keeps them itself. They change
// only while no event is joined (connection `idle` or `failed`); otherwise
// `initialize()` rejects with `invalid_argument`. So this screen leaves,
// initializes again and joins again, which stops the playing channel; a real
// app passes them once, at launch. On Android, `showsSystemMediaControls` is
// ignored: the foreground service (`androidServiceConfig`) shows the media
// notification and keeps playback alive in the background, so the switch
// controls the service there. The artwork shows in that notification too.
// `require()` hands it a bundled image: from Metro in a debug build, from
// the app's bundle or resources in a release build.
//
// Uses: initialize({ audioFocus, showsSystemMediaControls, androidServiceConfig }),
// LiveVoiceAudioFocus, setNowPlayingArtwork(image), getCurrentConnection(),
// leaveEvent(), joinEvent()
// See also: Audio output.

import React, { useState } from "react";
import { Platform, type ImageSourcePropType } from "react-native";
import {
  getCurrentConnection,
  initialize,
  joinEvent,
  leaveEvent,
  LiveVoiceView,
  setNowPlayingArtwork,
  type LiveVoiceAudioFocus,
  type LiveVoiceError,
  type LiveVoiceInitializeOptions,
} from "livevoice-sdk-react-native";
import {
  DemoButton,
  DemoButtonRow,
  DemoSegmentedControl,
  DemoSwitchRow,
} from "../../demo/DemoControls";
import { DemoNote, DemoScreen, DemoSection } from "../../demo/DemoScreen";
import { useDemoSession } from "../../demo/DemoSession";
import { useDemoTheme } from "../../demo/DemoTheme";

type Options = {
  audioFocus: LiveVoiceAudioFocus;
  showsSystemMediaControls: boolean;
  androidServiceConfig: NonNullable<LiveVoiceInitializeOptions["androidServiceConfig"]>;
};

/** The options of the last `initialize()`; the demo launched with the defaults. */
let initializedOptions: Options = {
  audioFocus: "exclusive",
  showsSystemMediaControls: true,
  androidServiceConfig: { kind: "enabled" },
};

export const LockScreenScreen: React.FC = () => {
  const theme = useDemoTheme();
  const { selectedPreset } = useDemoSession();
  const [options, setOptions] = useState(initializedOptions);
  const [isApplying, setIsApplying] = useState(false);
  const [failure, setFailure] = useState<LiveVoiceError | null>(null);

  /** Initializes the SDK again with `changes`, between a leave and a join. */
  const apply = async (changes: Partial<Options>) => {
    const next = { ...options, ...changes };
    setOptions(next);
    setFailure(null);
    setIsApplying(true);
    try {
      const { status } = getCurrentConnection();
      if (status !== "idle" && status !== "failed") await leaveEvent();
      await initialize(next);
      initializedOptions = next;
      // The event picked in the header.
      const { joinCode, password, apiKey } = selectedPreset;
      await joinEvent({ joinCode, password, apiKey });
    } catch (error) {
      const failed = error as LiveVoiceError;
      setOptions(initializedOptions);
      // A newer join, such as one from the header, took over.
      if (failed.code !== "cancelled" && failed.code !== "superseded") {
        setFailure(failed);
      }
    } finally {
      setIsApplying(false);
    }
  };

  /** The SDK draws it fitted, with a margin, on a white square. */
  const setArtwork = async (image: ImageSourcePropType | null) => {
    setFailure(null);
    try {
      await setNowPlayingArtwork(image);
    } catch (error) {
      // `invalid_argument` when the image can't be loaded; the previous one stays.
      setFailure(error as LiveVoiceError);
    }
  };

  return (
    <DemoScreen
      title="Lock screen and audio sharing"
      caption="Share the audio with other apps, and show the playing channel on the Lock Screen."
      error={failure}
    >
      <DemoSection title="Other audio">
        <DemoNote
          text="These settings apply to the whole app: every demo screen plays with them, and a playing channel keeps playing when you switch screens."
          icon="info"
          tint={theme.secondaryText}
        />
        <DemoNote
          text="Changing them leaves the event, initializes the SDK again and joins again, so the playing channel stops."
          icon={isApplying ? "waiting" : "info"}
          tint={theme.secondaryText}
        />
        {/* `'hostManaged'` leaves the audio session to your app: it sets up
            and activates one before a channel starts, and picks the route. */}
        <DemoSegmentedControl
          options={[
            { label: "Pause", value: "exclusive" },
            { label: "Duck", value: "duckOthers" },
          ]}
          value={options.audioFocus}
          onChange={(audioFocus) => !isApplying && void apply({ audioFocus })}
        />
      </DemoSection>
      <DemoSection
        title={Platform.OS === "ios" ? "Lock Screen and Control Center" : "Media notification"}
      >
        {Platform.OS === "ios" ? (
          // Turn them off if your app shows its own media controls. Only
          // `'exclusive'` shows them: the system has none for mixed audio.
          <>
            <DemoSwitchRow
              label="System media controls"
              value={options.showsSystemMediaControls}
              onValueChange={(showsSystemMediaControls) =>
                !isApplying && void apply({ showsSystemMediaControls })
              }
              disabled={options.audioFocus !== "exclusive"}
            />
            {options.audioFocus !== "exclusive" && (
              <DemoNote
                text="With Duck, iOS shows no system controls: it shows them only for audio that doesn't mix with other apps."
                icon="info"
                tint={theme.secondaryText}
              />
            )}
          </>
        ) : (
          // Without the service there is no media notification, and the
          // system may stop playback in the background.
          <DemoSwitchRow
            label="Background playback service"
            value={options.androidServiceConfig.kind === "enabled"}
            onValueChange={(enabled) =>
              !isApplying &&
              void apply({ androidServiceConfig: { kind: enabled ? "enabled" : "disabled" } })
            }
          />
        )}
        <DemoButtonRow>
          <DemoButton
            title="App image"
            onPress={() => void setArtwork(require("../../assets/demo-artwork.png"))}
          />
          {/* `null` shows the event's logo from the dashboard, or none. */}
          <DemoButton title="Event logo" onPress={() => void setArtwork(null)} />
        </DemoButtonRow>
      </DemoSection>
      <DemoSection title="Channels">
        <LiveVoiceView />
      </DemoSection>
    </DemoScreen>
  );
};
