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

import { useColorScheme } from "react-native";

/** Colors for the demo app chrome: a dimmer page background with brighter cards on top. */
export interface DemoTheme {
  dark: boolean;
  pageBackground: string;
  card: string;
  /** Content card on the detail screens (one step up from the page). */
  sectionCard: string;
  /** Container around the default LiveVoice view (the brightest level). */
  liveSample: string;
  /** Floating popover/menu surface (lighter than the page so it stands out). */
  popover: string;
  popoverBorder: string;
  separator: string;
  text: string;
  secondaryText: string;
  primary: string;
  chevron: string;
  warning: string;
}

const lightTheme: DemoTheme = {
  dark: false,
  pageBackground: "#F2F2F7",
  card: "#FFFFFF",
  sectionCard: "#E8E8ED",
  liveSample: "#FFFFFF",
  popover: "#FFFFFF",
  popoverBorder: "#E4E4E9",
  separator: "#E4E4E9",
  text: "#000000",
  secondaryText: "#6C6C70",
  primary: "#F1521B",
  chevron: "#C4C4C6",
  warning: "#E08600",
};

const darkTheme: DemoTheme = {
  dark: true,
  pageBackground: "#000000",
  card: "#1C1C1E",
  sectionCard: "#1C1C1E",
  liveSample: "#212429",
  popover: "#2C2C2E",
  popoverBorder: "#3A3A3C",
  separator: "#2C2C2E",
  text: "#FFFFFF",
  secondaryText: "#9A9AA0",
  primary: "#F1521B",
  chevron: "#48484A",
  warning: "#F5A623",
};

export function useDemoTheme(): DemoTheme {
  return useColorScheme() === "dark" ? darkTheme : lightTheme;
}
