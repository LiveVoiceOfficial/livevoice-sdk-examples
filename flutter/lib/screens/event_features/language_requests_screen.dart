// Language requests
//
// A listener can ask the event for a language it doesn't offer yet.
// `requestableLanguages` lists those languages with where each request
// stands; `requestLanguage` asks for one and `cancelLanguageRequest` takes
// the request back. Once the event fulfils a request, its new channel
// appears in LiveVoiceView like any other; the language is then `available`.
//
// In Flutter, the screen listens to `features` and `requestableLanguages`
// at once with `Listenable.merge`. The language states are an enum, so the
// switch over them has no default: a state a later SDK version adds is a
// compile error, not a silent gap.
//
// Needs: your own event with language requests enabled in the dashboard,
// and an API key that permits custom UI.
// Uses: requestableLanguages, requestLanguage(), cancelLanguageRequest(),
// features
// See also: Default interface (where a new channel appears).

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';

class LanguageRequestsScreen extends StatefulWidget {
  const LanguageRequestsScreen({super.key});

  @override
  State<LanguageRequestsScreen> createState() => _LanguageRequestsScreenState();
}

class _LanguageRequestsScreenState extends State<LanguageRequestsScreen> {
  LiveVoiceException? _failure;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([features, requestableLanguages]),
    builder: (context, _) {
      final customUiAllowed = features.value.customUiAllowed;
      final languages = requestableLanguages.value;
      return DemoScreen(
        title: 'Language requests',
        caption: "Ask the event for a language it doesn't offer yet.",
        error: _failure,
        children: [
          DemoRequirement.customUi(isMet: customUiAllowed),
          // `null`: the event takes no requests, or the API key doesn't
          // permit custom UI, which the note above covers.
          DemoRequirement.ownEvent(
            'Language requests',
            isMet: !customUiAllowed || languages != null,
          ),
          DemoSection(
            'Languages',
            children: [
              // `[]`: the event takes requests but has nothing to request.
              if (languages != null && languages.isEmpty)
                const DemoPlaceholder(
                  'The event offers no other languages to request right now.',
                ),
              for (final language
                  in languages ?? const <LiveVoiceRequestableLanguage>[])
                Row(
                  children: [
                    Expanded(child: Text(language.localizedName)),
                    switch (language.state) {
                      LiveVoiceLanguageRequestState.requestable => DemoButton(
                        'Request',
                        onPressed: () => _request(language),
                      ),
                      LiveVoiceLanguageRequestState.requested => DemoButton(
                        'Cancel request',
                        onPressed: () => _cancelRequest(language),
                      ),
                      LiveVoiceLanguageRequestState.available => const Text(
                        'Added',
                      ),
                      LiveVoiceLanguageRequestState.unavailable => const Text(
                        'Not available',
                      ),
                    },
                  ],
                ),
            ],
          ),
        ],
      );
    },
  );

  /// Returns once the event has the request; it may still decline it, which
  /// `requestableLanguages` then shows.
  Future<void> _request(LiveVoiceRequestableLanguage language) async {
    setState(() => _failure = null);
    try {
      await requestLanguage(language.languageCode);
    } on LiveVoiceException catch (error) {
      if (mounted) setState(() => _failure = error);
    }
  }

  Future<void> _cancelRequest(LiveVoiceRequestableLanguage language) async {
    setState(() => _failure = null);
    try {
      await cancelLanguageRequest(language.languageCode);
    } on LiveVoiceException catch (error) {
      if (mounted) setState(() => _failure = error);
    }
  }
}
