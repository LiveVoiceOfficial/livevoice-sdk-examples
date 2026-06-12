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

import '../shared/audio_output_controls.dart';
import '../shared/custom_channel_views.dart';
import '../shared/demo_components.dart';

class CustomChannelCellScreen extends StatelessWidget {
  const CustomChannelCellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoScreen(
      title: 'Custom channel cell',
      summary:
          'Replace the built-in channel row with your own Flutter widget while '
          'keeping the LiveVoice session logic.',
      children: [
        DemoCardSection(
          title: 'Live sample',
          children: [
            // Keep audio output reachable right above the list, so playback is never silent.
            AudioOutputRow(),
            SizedBox(height: 12),
            CustomChannelList(detailed: true),
          ],
        ),
        DemoCardSection(
          title: 'Implementation notes',
          children: [
            DemoNotes(
              notes: [
                'Pass a cellBuilder to LiveVoiceView to render each channel with your own Flutter widget.',
                'Wire your row to the cell.onAudioPressed callback to keep playback connected to LiveVoice.',
                "The channel's Booleans are surfaced — isOnline as the status dot, the rest as badges (solid when true, faint when false) — so you can see which values you can read even when a feature doesn't apply to your own design.",
                'The row is tappable — and its play control active — only when the channel can be started (online and with audio); otherwise the cell is inert.',
                'You can replace the row design without changing the built-in session behavior.',
              ],
            ),
          ],
        ),
      ],
    );
  }
}
