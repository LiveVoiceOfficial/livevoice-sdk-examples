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

import '../shared/demo_components.dart';
import '../shared/subtitle_views.dart';
import '../theme.dart';

class SubtitleOnlyScreen extends StatefulWidget {
  const SubtitleOnlyScreen({super.key});

  @override
  State<SubtitleOnlyScreen> createState() => _SubtitleOnlyScreenState();
}

class _SubtitleOnlyScreenState extends State<SubtitleOnlyScreen> {
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
          title: 'Subtitle only',
          summary:
              'Display subtitles on their own, without showing any of the '
              'event channels.',
          children: [
            DemoCardSection(
              title: 'Live sample',
              children: [
                Text(
                  'Subtitle view',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
                    placeholder:
                        'Start subtitles to render fragments in this dedicated view.',
                  ),
                  secondChild: const DemoSubtitleUnavailableHint(),
                ),
              ],
            ),
            SubtitleControls(controller: _controller),
            const DemoCardSection(
              title: 'Implementation notes',
              children: [
                DemoNotes(
                  notes: [
                    'Your app provides the subtitle view and chooses which subtitle stream to start or stop.',
                    'You can use this without rendering the LiveVoice channel list at all.',
                    'The subtitle change stream gives you the current subtitle fragments for your custom view.',
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
