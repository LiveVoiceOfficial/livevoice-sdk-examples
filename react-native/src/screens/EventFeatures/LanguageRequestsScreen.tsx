// Language requests
//
// A listener can ask the event for a language it doesn't offer yet.
// `useLiveVoiceRequestableLanguages` lists those languages with where each
// request stands; `requestLanguage` asks for one and `cancelLanguageRequest`
// takes the request back. Once the event fulfils a request, its new channel
// appears in LiveVoiceView like any other; the language is then `'available'`.
//
// Differs from iOS: the state is a string; a `switch` over it should keep a
// fallback for states a later SDK version adds.
//
// Needs: your own event with language requests enabled in the dashboard,
// and an API key that permits custom UI.
// Uses: useLiveVoiceRequestableLanguages(), requestLanguage(languageCode),
// cancelLanguageRequest(languageCode), useLiveVoiceFeatures()
// See also: Default interface (where a new channel appears).

import React, { useState } from "react";
import { Text } from "react-native";
import {
  cancelLanguageRequest,
  requestLanguage,
  useLiveVoiceFeatures,
  useLiveVoiceRequestableLanguages,
  type LiveVoiceError,
  type LiveVoiceRequestableLanguage,
} from "livevoice-sdk-react-native";
import { DemoButton } from "../../demo/DemoControls";
import { DemoItemRow, DemoPlaceholder } from "../../demo/DemoRows";
import { DemoRequirement, DemoScreen, DemoSection } from "../../demo/DemoScreen";
import { useDemoTheme } from "../../demo/DemoTheme";

export const LanguageRequestsScreen: React.FC = () => {
  const theme = useDemoTheme();
  const { customUiAllowed } = useLiveVoiceFeatures();
  const languages = useLiveVoiceRequestableLanguages();
  const [failure, setFailure] = useState<LiveVoiceError | null>(null);

  /**
   * Resolves once the event has the request; it may still decline it, which
   * `useLiveVoiceRequestableLanguages` then shows.
   */
  const request = async (language: LiveVoiceRequestableLanguage) => {
    setFailure(null);
    try {
      await requestLanguage(language.languageCode);
    } catch (error) {
      setFailure(error as LiveVoiceError);
    }
  };

  const cancelRequest = async (language: LiveVoiceRequestableLanguage) => {
    setFailure(null);
    try {
      await cancelLanguageRequest(language.languageCode);
    } catch (error) {
      setFailure(error as LiveVoiceError);
    }
  };

  return (
    <DemoScreen
      title="Language requests"
      caption="Ask the event for a language it doesn't offer yet."
      error={failure}
    >
      <DemoRequirement need="customUI" isMet={customUiAllowed} />
      {/* `null`: the event takes no requests, or the API key doesn't permit
          custom UI, which the note above covers. */}
      <DemoRequirement
        need={{ ownEvent: "Language requests" }}
        isMet={!customUiAllowed || languages !== null}
      />
      <DemoSection title="Languages">
        {/* `[]`: the event takes requests but has nothing to request. */}
        {languages?.length === 0 && (
          <DemoPlaceholder text="The event offers no other languages to request right now." />
        )}
        {(languages ?? []).map((language) => (
          <DemoItemRow key={language.languageCode} label={language.localizedName}>
            {(() => {
              switch (language.state) {
                case "requestable":
                  return <DemoButton plain title="Request" onPress={() => void request(language)} />;
                case "requested":
                  return <DemoButton plain title="Cancel request" onPress={() => void cancelRequest(language)} />;
                case "available":
                  return <Text style={{ color: theme.text }}>Added</Text>;
                case "unavailable":
                  return <Text style={{ color: theme.text }}>Not available</Text>;
                default:
                  // A state a later SDK version adds.
                  return null;
              }
            })()}
          </DemoItemRow>
        ))}
      </DemoSection>
    </DemoScreen>
  );
};
