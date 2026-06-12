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
import '../theme.dart';

class AudioOutputScreen extends StatelessWidget {
  const AudioOutputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoScreen(
      title: 'Audio output picker',
      summary:
          'Place an audio output control wherever it fits in your app and bind '
          'it to the SDK. Here are three styles — all driving the same output.',
      children: [
        DemoCardSection(
          title: 'Live sample',
          children: [
            DemoDefaultLiveVoiceView(child: LiveVoiceView()),
          ],
        ),
        DemoCardSection(
          title: 'Output controls',
          children: [
            _Variant(
              title: 'Compact icons',
              detail: 'An icon-only segmented picker that stays compact.',
              child: CompactAudioOutputPicker(),
            ),
            SizedBox(height: 20),
            _Variant(
              title: 'Pop-up menu',
              detail: 'A field that opens a menu — handy when space is tight.',
              child: MenuAudioOutputPicker(),
            ),
            SizedBox(height: 20),
            _Variant(
              title: 'Toggle button',
              detail: 'A single button that flips straight to the other output.',
              child: ToggleAudioOutputButton(),
            ),
          ],
        ),
        DemoCardSection(
          title: 'Implementation notes',
          children: [
            DemoNotes(
              notes: [
                'The Flutter SDK exposes the current audio output and an onAudioOutputChanged stream.',
                'Every control here drives that single value, so they all stay in sync.',
                'Bind a picker, menu, or toggle to it wherever it makes sense in the screen.',
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Variant extends StatelessWidget {
  const _Variant({
    required this.title,
    required this.detail,
    required this.child,
  });

  final String title;
  final String detail;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: TextStyle(color: theme.secondaryText, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Align(alignment: Alignment.centerLeft, child: child),
      ],
    );
  }
}
