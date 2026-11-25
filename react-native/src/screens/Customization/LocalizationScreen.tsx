// Localization and accessibility
//
// The SDK's default UI, its password prompt and every error's `message` come
// in English, German and Spanish, following the app's or device's language.
// Use `Translations` in your own parts to match the default UI's wording,
// its `accessibility…` texts for accessibility labels, and show errors by
// their `message`.
//
// Differs from iOS: `Translations` has functions with their own names in
// place of the `LiveVoiceLocalization` constants; each reads the text from
// the native SDK at the call and needs no join. Error codes are snake_case
// strings. An error you create carries its code's text whatever its
// `detail`; errors the SDK rejects with carry the native SDK's text.
//
// Uses: Translations, LiveVoiceError.message
// See also: Custom channel cell (uses the accessibility texts), Custom view
// states (parts that show these texts).

import React from "react";
import { LiveVoiceError, Translations } from "livevoice-sdk-react-native";
import { DemoTextRow } from "../../demo/DemoRows";
import { DemoScreen, DemoSection } from "../../demo/DemoScreen";

export const LocalizationScreen: React.FC = () => (
  <DemoScreen
    title="Localization and accessibility"
    caption="The SDK's own texts, in the app's language, for your custom parts."
  >
    <DemoSection title="UI texts">
      <DemoTextRow name="errorRetryNowButton()" text={Translations.errorRetryNowButton()} />
      <DemoTextRow name="noChannels()" text={Translations.noChannels()} />
      <DemoTextRow name="channelStatusOffline()" text={Translations.channelStatusOffline()} />
      <DemoTextRow name="isAiChannelStatusMessage()" text={Translations.isAiChannelStatusMessage()} />
      <DemoTextRow name="errorScreenRetrying()" text={Translations.errorScreenRetrying()} />
      <DemoTextRow name="errorScreenRetryingIn(30)" text={Translations.errorScreenRetryingIn(30)} />
      <DemoTextRow name="sdkNoMatchingChannels()" text={Translations.sdkNoMatchingChannels()} />
      <DemoTextRow name="streamingByTitle()" text={Translations.streamingByTitle()} />
    </DemoSection>
    {/* The SDK takes care of its default parts' accessibility; the parts you
        provide are yours: give them labels and roles, and reflect the cell's
        `isEnabled` and the channel's `playingState`. */}
    <DemoSection title="Accessibility labels">
      <DemoTextRow name="accessibilityChannelPlay()" text={Translations.accessibilityChannelPlay()} />
      <DemoTextRow name="accessibilityChannelStop()" text={Translations.accessibilityChannelStop()} />
      <DemoTextRow name="accessibilityChannelStatusMuted()" text={Translations.accessibilityChannelStatusMuted()} />
    </DemoSection>
    {/* Show `message` to the listener, and decide by `code`, never by the text. */}
    <DemoSection title="Error messages">
      <DemoTextRow name="channel_offline" text={new LiveVoiceError("channel_offline").message} />
      <DemoTextRow name="event_inactive" text={new LiveVoiceError("event_inactive").message} />
      <DemoTextRow name="event_not_found" text={new LiveVoiceError("event_not_found").message} />
      <DemoTextRow name="listener_limit_reached" text={new LiveVoiceError("listener_limit_reached").message} />
      <DemoTextRow name="no_network" text={new LiveVoiceError("no_network").message} />
      <DemoTextRow name="network_failed" text={new LiveVoiceError("network_failed").message} />
      <DemoTextRow name="wrong_password" text={new LiveVoiceError("wrong_password").message} />
      {/* Errors from a mistake in your code carry a generic text; the SDK log
          explains them (see Diagnostics log). */}
      <DemoTextRow name="api_key_invalid" text={new LiveVoiceError("api_key_invalid").message} />
      <DemoTextRow name="generic" text={new LiveVoiceError("generic").message} />
    </DemoSection>
  </DemoScreen>
);
