/*
 * This source file is part of the LiveVoice SDK project
 *
 * Copyright (c) LiveVoice GmbH
 * Licensed under the MIT license
 *
 * See LICENSE for license information
 *
 * SPDX-License-Identifier: MIT
 */

import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { Translations } from "livevoice-sdk-react-native";
import {
  DemoCardSection,
  DemoNotes,
  DemoScreen,
} from "../shared/DemoComponents";
import { useDemoTheme } from "../theme";

function str(read: () => string): string {
  try {
    return read();
  } catch {
    return "";
  }
}

const LOCALIZED_ROWS: Array<[string, string]> = [
  ["action_retry_now", str(() => Translations.errorRetryNowButton())],
  ["channel_status_offline", str(() => Translations.channelStatusOffline())],
  ["error_screen_retrying", str(() => Translations.errorScreenRetrying())],
  ["error_screen_retrying_in(12)", str(() => Translations.errorScreenRetryingIn(12))],
  ["sdk_error_generic", str(() => Translations.sdkErrorGeneric())],
  ["sdk_error_inactive", str(() => Translations.sdkErrorInactive())],
  ["sdk_error_invalid_api_key", str(() => Translations.sdkErrorInvalidApiKey())],
  ["sdk_error_listener_limit_reached", str(() => Translations.sdkErrorListenerLimitReached())],
  ["sdk_error_no_network", str(() => Translations.sdkErrorNoNetwork())],
  ["sdk_error_not_found", str(() => Translations.sdkErrorNotFound())],
  ['sdk_error_request_failed("500")', str(() => Translations.sdkErrorRequestFailed(500))],
  ["sdk_error_wrong_password", str(() => Translations.sdkErrorWrongPassword())],
  ["sdk_no_matching_channels", str(() => Translations.sdkNoMatchingChannels())],
  ["streaming_by_title", str(() => Translations.streamingByTitle())],
  ["a11y_channel_play", str(() => Translations.accessibilityChannelPlay())],
  ["a11y_channel_status_muted", str(() => Translations.accessibilityChannelStatusMuted())],
  ["a11y_channel_stop", str(() => Translations.accessibilityChannelStop())],
  ["channel_list_empty", str(() => Translations.noChannels())],
  ["channel_status_is_ai", str(() => Translations.isAiChannelStatusMessage())],
];

export const LocalizationScreen: React.FC = () => {
  const theme = useDemoTheme();
  return (
    <DemoScreen summary="The SDK ships reusable strings and accessibility labels in English, German, and Spanish. They follow the app or device language — reuse them in your custom UI.">
      <DemoCardSection title="Strings">
        <View style={styles.rows}>
          {LOCALIZED_ROWS.map(([key, value]) => (
            <View key={key} style={styles.row}>
              <Text style={[styles.key, { color: theme.secondaryText }]}>
                {key}
              </Text>
              <Text style={[styles.value, { color: theme.text }]}>{value}</Text>
            </View>
          ))}
        </View>
      </DemoCardSection>

      <DemoCardSection title="Implementation notes">
        <DemoNotes
          notes={[
            "Reuse SDK-provided strings and accessibility labels in your custom UI instead of writing separate copy.",
            "The SDK does not expose a runtime language switch. The strings follow the app or device language.",
            "These values come from the SDK's Translations helper, so they reflect the device's current language.",
          ]}
        />
      </DemoCardSection>
    </DemoScreen>
  );
};

const styles = StyleSheet.create({
  rows: {
    gap: 16,
  },
  row: {
    gap: 4,
  },
  key: {
    fontSize: 12,
    fontFamily: "Courier",
  },
  value: {
    fontSize: 15,
    lineHeight: 20,
  },
});
