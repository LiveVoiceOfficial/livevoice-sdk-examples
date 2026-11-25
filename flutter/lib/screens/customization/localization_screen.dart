// Localization and accessibility
//
// The SDK's default UI, its password prompt and every error's `message` come
// in English, German and Spanish, following the app's or device's language.
// Use `translations` in your own parts to match the default UI's wording,
// its `accessibility…` texts for accessibility labels, and show errors by
// their `message`.
//
// In Flutter, `translations` come from the native SDK, so each text is a
// Future: read it once (here when the screen is created), not in `build`.
// An error's `message` is synchronous; the localized texts load from the
// native SDK once the plugin starts, and until then `message` is English.
// The language is the device's or the app's on the native side, not your
// MaterialApp's `locale`.
//
// Uses: translations, LiveVoiceException.message
// See also: Custom channel cell (uses the accessibility texts), Custom view
// states (parts that show these texts).

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';

class LocalizationScreen extends StatefulWidget {
  const LocalizationScreen({super.key});

  @override
  State<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends State<LocalizationScreen> {
  final _uiTexts = {
    'errorRetryNowButton()': translations.errorRetryNowButton(),
    'noChannels()': translations.noChannels(),
    'channelStatusOffline()': translations.channelStatusOffline(),
    'isAiChannelStatusMessage()': translations.isAiChannelStatusMessage(),
    'errorScreenRetrying()': translations.errorScreenRetrying(),
    'errorScreenRetryingIn(30)': translations.errorScreenRetryingIn(30),
    'sdkNoMatchingChannels()': translations.sdkNoMatchingChannels(),
    'streamingByTitle()': translations.streamingByTitle(),
  };

  final _accessibilityTexts = {
    'accessibilityChannelPlay()': translations.accessibilityChannelPlay(),
    'accessibilityChannelStop()': translations.accessibilityChannelStop(),
    'accessibilityChannelStatusMuted()': translations
        .accessibilityChannelStatusMuted(),
  };

  @override
  Widget build(BuildContext context) => DemoScreen(
    title: 'Localization and accessibility',
    caption:
        "The SDK's own texts, in the app's language, for your custom parts.",
    children: [
      DemoSection(
        'UI texts',
        children: [
          for (final MapEntry(:key, :value) in _uiTexts.entries)
            DemoTextRow.future(key, value),
        ],
      ),
      // The SDK takes care of its default parts' accessibility; the parts
      // you provide are yours: give them labels and semantics, and reflect
      // the cell's `isEnabled` and the channel's `playingState`.
      DemoSection(
        'Accessibility labels',
        children: [
          for (final MapEntry(:key, :value) in _accessibilityTexts.entries)
            DemoTextRow.future(key, value),
        ],
      ),
      // Show `message` to the listener, and decide by `code`, never by the
      // text.
      DemoSection(
        'Error messages',
        children: [
          DemoTextRow('.channelOffline', _message(.channelOffline)),
          DemoTextRow('.eventInactive', _message(.eventInactive)),
          DemoTextRow('.eventNotFound', _message(.eventNotFound)),
          DemoTextRow('.listenerLimitReached', _message(.listenerLimitReached)),
          DemoTextRow('.noNetwork', _message(.noNetwork)),
          DemoTextRow(
            '.networkFailed, HTTP 500',
            LiveVoiceException(
              .networkFailed,
              detail: const LiveVoiceErrorDetail(httpStatus: 500),
            ).message,
          ),
          DemoTextRow('.wrongPassword', _message(.wrongPassword)),
          // Errors from a mistake in your code carry a generic text; the SDK
          // log explains them (see Diagnostics log).
          DemoTextRow('.apiKeyInvalid', _message(.apiKeyInvalid)),
          DemoTextRow('.generic', _message(.generic)),
        ],
      ),
    ],
  );

  String _message(LiveVoiceErrorCode code) => LiveVoiceException(code).message;
}
