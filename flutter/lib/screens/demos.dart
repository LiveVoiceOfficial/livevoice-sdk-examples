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

/// The set of demos shown on the home screen.
enum DemoRoute {
  defaultParticipant,
  filteredChannels,
  audioOutput,
  subtitleOnly,
  branding,
  customChannel,
  localization,
}

class DemoItem {
  const DemoItem({
    required this.route,
    required this.title,
    required this.summary,
  });

  final DemoRoute route;
  final String title;
  final String summary;
}

class DemoSection {
  const DemoSection({required this.title, required this.items});

  final String title;
  final List<DemoItem> items;
}

const List<DemoSection> demoSections = [
  DemoSection(
    title: 'Default UI',
    items: [
      DemoItem(
        route: DemoRoute.defaultParticipant,
        title: 'Default participant interface',
        summary: 'The simplest integration, with subtitles in your own view.',
      ),
      DemoItem(
        route: DemoRoute.filteredChannels,
        title: 'Filtered channel list',
        summary:
            'Show only the channels you want — by property, an empty result, or a source channel with its AI subtitles.',
      ),
      DemoItem(
        route: DemoRoute.audioOutput,
        title: 'Audio output picker',
        summary: 'Place the audio output picker wherever it fits in your app.',
      ),
      DemoItem(
        route: DemoRoute.subtitleOnly,
        title: 'Subtitle only',
        summary: 'Show subtitles without displaying any of the event channels.',
      ),
    ],
  ),
  DemoSection(
    title: 'Custom UI',
    items: [
      DemoItem(
        route: DemoRoute.branding,
        title: 'Branding and entitlements',
        summary:
            'See how API key permissions affect branding and customization.',
      ),
      DemoItem(
        route: DemoRoute.customChannel,
        title: 'Custom channel cell',
        summary:
            'A richer custom channel row with status, translation, and subtitle badges.',
      ),
      DemoItem(
        route: DemoRoute.localization,
        title: 'Localization and accessibility',
        summary:
            'The strings and labels needed for a polished custom integration.',
      ),
    ],
  ),
];
