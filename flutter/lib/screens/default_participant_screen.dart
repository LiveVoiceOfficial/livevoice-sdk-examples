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

import '../shared/audio_output_controls.dart';
import '../shared/demo_components.dart';
import '../shared/subtitle_views.dart';
import '../theme.dart';

class DefaultParticipantScreen extends StatefulWidget {
  const DefaultParticipantScreen({super.key});

  @override
  State<DefaultParticipantScreen> createState() =>
      _DefaultParticipantScreenState();
}

class _DefaultParticipantScreenState extends State<DefaultParticipantScreen> {
  final SubtitlesController _controller = SubtitlesController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return DemoScreen(
          title: 'Default participant interface',
          summary:
              'The simplest LiveVoice integration. The default view manages '
              'channels and audio; tap a channel’s subtitle button and the '
              'fragments stream into your own subtitle view.',
          children: [
            const DemoCardSection(
              title: 'Live sample',
              children: [
                // Keep audio output reachable right above the list, so playback is never silent.
                AudioOutputRow(),
                SizedBox(height: 12),
                DemoDefaultLiveVoiceView(child: LiveVoiceView()),
              ],
            ),
            DemoCardSection(
              title: 'Your subtitle view',
              children: [
                Text(
                  'Tap a channel’s subtitle button above and its subtitles '
                  'stream into this view, which your app provides.',
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 14,
                    height: 19 / 14,
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 350),
                  crossFadeState:
                      (_controller.availableSubtitles?.isEmpty ?? false)
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: SubtitleFeed(
                    fragments: _controller.fragments,
                    placeholder: 'Subtitles will appear here.',
                  ),
                  secondChild: const DemoSubtitleUnavailableHint(),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: _controller.enabled ? 1 : 0.4,
                    child: GestureDetector(
                      onTap: _controller.enabled ? _controller.stop : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.chevron,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Stop subtitles',
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const DemoCardSection(
              title: 'Implementation notes',
              children: [
                DemoNotes(
                  notes: [
                    'Join the event once at app startup or before presenting the screen.',
                    'LiveVoiceView handles loading, errors, reconnecting, and branding for you.',
                    "Tapping a channel's subtitle button starts its subtitles; your app provides the view that renders the fragments.",
                    'Automatic subtitle mode follows whichever channel is currently playing.',
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
