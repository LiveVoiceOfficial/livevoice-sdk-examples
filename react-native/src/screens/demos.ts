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

/** The set of demos shown on the home screen. */
export type DemoRoute =
  | "DefaultParticipant"
  | "FilteredChannels"
  | "AudioOutput"
  | "SubtitleOnly"
  | "Branding"
  | "CustomChannel"
  | "Localization";

export interface DemoItem {
  route: DemoRoute;
  title: string;
  summary: string;
}

export interface DemoSection {
  title: string;
  items: DemoItem[];
}

export const demoSections: DemoSection[] = [
  {
    title: "Default UI",
    items: [
      {
        route: "DefaultParticipant",
        title: "Default participant interface",
        summary: "The simplest integration, with subtitles in your own view.",
      },
      {
        route: "FilteredChannels",
        title: "Filtered channel list",
        summary:
          "Show only the channels you want — by property, an empty result, or a source channel with its AI subtitles.",
      },
      {
        route: "AudioOutput",
        title: "Audio output picker",
        summary: "Place the audio output picker wherever it fits in your app.",
      },
      {
        route: "SubtitleOnly",
        title: "Subtitle only",
        summary: "Show subtitles without displaying any of the event channels.",
      },
    ],
  },
  {
    title: "Custom UI",
    items: [
      {
        route: "Branding",
        title: "Branding and entitlements",
        summary: "See how API key permissions affect branding and customization.",
      },
      {
        route: "CustomChannel",
        title: "Custom channel cell",
        summary:
          "A richer custom channel row with status, translation, and subtitle badges.",
      },
      {
        route: "Localization",
        title: "Localization and accessibility",
        summary: "The strings and labels needed for a polished custom integration.",
      },
    ],
  },
];

export const allDemoItems: DemoItem[] = demoSections.flatMap(
  (section) => section.items,
);
