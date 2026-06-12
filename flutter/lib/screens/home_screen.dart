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

import '../shared/ui.dart';
import '../theme.dart';
import 'audio_output_screen.dart';
import 'branding_screen.dart';
import 'custom_channel_cell_screen.dart';
import 'default_participant_screen.dart';
import 'demos.dart';
import 'filtered_channels_screen.dart';
import 'localization_screen.dart';
import 'subtitle_only_screen.dart';

/// The sample's landing screen: a branded header over a grouped list of demos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);

    return Scaffold(
      backgroundColor: theme.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [PlatformBadge(), DemoApiKeyMenu()],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      const LiveVoiceLogo(),
                      const SizedBox(height: 6),
                      const SdkVersionLabel(),
                      const SizedBox(height: 14),
                      Text(
                        'A quick tour of LiveVoice SDK features.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  const SizedBox(height: 24),
                  for (final section in demoSections) ...[
                    SectionHeader(title: section.title),
                    DemoListSection(
                      children: [
                        for (var i = 0; i < section.items.length; i++)
                          DemoListRow(
                            title: section.items[i].title,
                            summary: section.items[i].summary,
                            showDivider: i < section.items.length - 1,
                            onTap: () => _open(context, section.items[i]),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, DemoItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => _screenFor(item.route)),
    );
  }

  Widget _screenFor(DemoRoute route) {
    switch (route) {
      case DemoRoute.defaultParticipant:
        return const DefaultParticipantScreen();
      case DemoRoute.filteredChannels:
        return const FilteredChannelsScreen();
      case DemoRoute.audioOutput:
        return const AudioOutputScreen();
      case DemoRoute.subtitleOnly:
        return const SubtitleOnlyScreen();
      case DemoRoute.branding:
        return const BrandingScreen();
      case DemoRoute.customChannel:
        return const CustomChannelCellScreen();
      case DemoRoute.localization:
        return const LocalizationScreen();
    }
  }
}
