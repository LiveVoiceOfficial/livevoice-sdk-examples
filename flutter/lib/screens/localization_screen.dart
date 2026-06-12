//===----------------------------------------------------------------------===//
//
// This source file is part of the LiveVoice SDK project
//
// Copyright (c) LiveVoice GmbH
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../shared/demo_components.dart';
import '../theme.dart';

/// The translation keys shown on this screen, paired with the [translations]
/// call that resolves each one.
final Map<String, Future<String> Function()> _localizedRows = {
  'action_retry_now': translations.errorRetryNowButton,
  'channel_status_offline': translations.channelStatusOffline,
  'error_screen_retrying': translations.errorScreenRetrying,
  'error_screen_retrying_in(12)': () => translations.errorScreenRetryingIn(12),
  'sdk_error_generic': translations.sdkErrorGeneric,
  'sdk_error_inactive': translations.sdkErrorInactive,
  'sdk_error_invalid_api_key': translations.sdkErrorInvalidApiKey,
  'sdk_error_listener_limit_reached': translations.sdkErrorListenerLimitReached,
  'sdk_error_no_network': translations.sdkErrorNoNetwork,
  'sdk_error_not_found': translations.sdkErrorNotFound,
  'sdk_error_request_failed("500")': () => translations.sdkErrorRequestFailed(500),
  'sdk_error_wrong_password': translations.sdkErrorWrongPassword,
  'sdk_no_matching_channels': translations.sdkNoMatchingChannels,
  'streaming_by_title': translations.streamingByTitle,
  'a11y_channel_play': translations.accessibilityChannelPlay,
  'a11y_channel_status_muted': translations.accessibilityChannelStatusMuted,
  'a11y_channel_stop': translations.accessibilityChannelStop,
  'channel_list_empty': translations.noChannels,
  'channel_status_is_ai': translations.isAiChannelStatusMessage,
};

class LocalizationScreen extends StatefulWidget {
  const LocalizationScreen({super.key});

  @override
  State<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends State<LocalizationScreen> {
  Map<String, String> _values = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = <String, String>{};
    for (final entry in _localizedRows.entries) {
      try {
        entries[entry.key] = await entry.value();
      } catch (_) {
        entries[entry.key] = '';
      }
    }
    if (mounted) setState(() => _values = entries);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return DemoScreen(
      title: 'Localization and accessibility',
      summary:
          'The SDK ships reusable strings and accessibility labels in English, '
          'German, and Spanish. They follow the app or device language — reuse '
          'them in your custom UI.',
      children: [
        DemoCardSection(
          title: 'Strings',
          children: [
            for (final key in _localizedRows.keys)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key,
                      style: TextStyle(
                        color: theme.secondaryText,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _values[key] ?? '',
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 15,
                        height: 20 / 15,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const DemoCardSection(
          title: 'Implementation notes',
          children: [
            DemoNotes(
              notes: [
                'Reuse SDK-provided strings and accessibility labels in your custom UI instead of writing separate copy.',
                'The SDK does not expose a runtime language switch. The strings follow the app or device language.',
                "These values come from the SDK's translations helper, so they reflect the device's current language.",
              ],
            ),
          ],
        ),
      ],
    );
  }
}
