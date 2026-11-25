// Demo scaffolding — not needed for an integration.
// The demo's colours, close to the iOS system colours, in light and dark.

import { Platform, useColorScheme } from "react-native";

export interface DemoTheme {
  dark: boolean;
  pageBackground: string;
  /** A demo section's rounded box. */
  sectionFill: string;
  sectionStroke: string;
  /** A card inside a section, such as a custom cell or a sample view. */
  cardFill: string;
  /** A row of the home list. */
  listRow: string;
  popover: string;
  separator: string;
  text: string;
  secondaryText: string;
  accent: string;
  /** The fill of a bordered button. */
  buttonFill: string;
  red: string;
  orange: string;
  green: string;
  gray: string;
}

const light: DemoTheme = {
  dark: false,
  pageBackground: "#F2F2F7",
  sectionFill: "#E8E8ED",
  sectionStroke: "rgba(60,60,67,0.08)",
  cardFill: "#FFFFFF",
  listRow: "#FFFFFF",
  popover: "#FFFFFF",
  separator: "rgba(60,60,67,0.29)",
  text: "#000000",
  secondaryText: "#6C6C70",
  accent: "#007AFF",
  buttonFill: "rgba(120,120,128,0.12)",
  red: "#FF3B30",
  orange: "#FF9500",
  green: "#34C759",
  gray: "#8E8E93",
};

const dark: DemoTheme = {
  dark: true,
  pageBackground: "#000000",
  sectionFill: "#1C1C1E",
  sectionStroke: "rgba(84,84,88,0.08)",
  cardFill: "#2C2C2E",
  listRow: "#1C1C1E",
  popover: "#2C2C2E",
  separator: "rgba(84,84,88,0.6)",
  text: "#FFFFFF",
  secondaryText: "#9A9AA0",
  accent: "#0A84FF",
  buttonFill: "rgba(120,120,128,0.24)",
  red: "#FF453A",
  orange: "#FF9F0A",
  green: "#30D158",
  gray: "#8E8E93",
};

export function useDemoTheme(): DemoTheme {
  return useColorScheme() === "dark" ? dark : light;
}

/** A monospaced font for names from the code. */
export const demoMonospace = Platform.select({ ios: "Menlo", default: "monospace" });
