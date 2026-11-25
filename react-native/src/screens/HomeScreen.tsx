// The home list: every demo screen, grouped into sections.

import React from "react";
import { Image, ScrollView, StyleSheet, Text, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { DemoApiKeyMenu } from "../demo/DemoEventPicker";
import type { NativeStackScreenProps } from "@react-navigation/native-stack";
import { getNativeSdkVersion, getSdkVersion } from "livevoice-sdk-react-native";
import { DemoListRow, DemoListSection, DemoPlatformBadge } from "../demo/DemoListRow";
import type { DemoRoute, DemoStackParamList } from "../demo/DemoNavigation";
import { useDemoTheme } from "../demo/DemoTheme";
import { DefaultInterfaceScreen } from "./GettingStarted/DefaultInterfaceScreen";
import { JoiningEventScreen } from "./GettingStarted/JoiningEventScreen";
import { FilteringChannelsScreen } from "./Channels/FilteringChannelsScreen";
import { CustomChannelCellScreen } from "./Channels/CustomChannelCellScreen";
import { CustomViewStatesScreen } from "./Channels/CustomViewStatesScreen";
import { SubtitlesScreen } from "./Subtitles/SubtitlesScreen";
import { AudioOutputScreen } from "./AudioAndSystem/AudioOutputScreen";
import { LockScreenScreen } from "./AudioAndSystem/LockScreenScreen";
import { PasswordsScreen } from "./EventFeatures/PasswordsScreen";
import { LanguageRequestsScreen } from "./EventFeatures/LanguageRequestsScreen";
import { LinkedEventsScreen } from "./EventFeatures/LinkedEventsScreen";
import { BrandingScreen } from "./Customization/BrandingScreen";
import { LocalizationScreen } from "./Customization/LocalizationScreen";
import { DiagnosticsScreen } from "./Customization/DiagnosticsScreen";

interface Demo {
  route: DemoRoute;
  screen: React.FC;
  title: string;
  summary: string;
  needsOwnEvent?: boolean;
}

export const demoSections: { title: string; demos: Demo[] }[] = [
  {
    title: "Getting started",
    demos: [
      {
        route: "DefaultInterface",
        screen: DefaultInterfaceScreen,
        title: "Default interface",
        summary: "The smallest integration: the event's channels, ready to play.",
      },
      {
        route: "JoiningEvent",
        screen: JoiningEventScreen,
        title: "Joining an event",
        summary: "Join, reconnect and leave, and follow the connection.",
      },
    ],
  },
  {
    title: "Channels",
    demos: [
      {
        route: "FilteringChannels",
        screen: FilteringChannelsScreen,
        title: "Filtering channels",
        summary: "Show only the channels you want.",
      },
      {
        route: "CustomChannelCell",
        screen: CustomChannelCellScreen,
        title: "Custom channel cell",
        summary: "Draw each channel with your own view.",
      },
      {
        route: "CustomViewStates",
        screen: CustomViewStatesScreen,
        title: "Custom view states",
        summary: "Your own loading, reconnecting, error and empty views.",
      },
    ],
  },
  {
    title: "Subtitles",
    demos: [
      {
        route: "Subtitles",
        screen: SubtitlesScreen,
        title: "Subtitles",
        summary: "Show a channel's live subtitles in your own view.",
      },
    ],
  },
  {
    title: "Audio and system",
    demos: [
      {
        route: "AudioOutput",
        screen: AudioOutputScreen,
        title: "Audio output",
        summary: "Prefer the loudspeaker, or let the system choose.",
      },
      {
        route: "LockScreen",
        screen: LockScreenScreen,
        title: "Lock screen and audio sharing",
        summary:
          "Share the audio with other apps, and show the channel on the Lock Screen.",
      },
    ],
  },
  {
    title: "Event features",
    demos: [
      {
        route: "Passwords",
        screen: PasswordsScreen,
        title: "Password-protected channels",
        summary: "Ask for channel passwords with your own UI, and keep them.",
        needsOwnEvent: true,
      },
      {
        route: "LanguageRequests",
        screen: LanguageRequestsScreen,
        title: "Language requests",
        summary: "Ask the event for a language it doesn't offer yet.",
        needsOwnEvent: true,
      },
      {
        route: "LinkedEvents",
        screen: LinkedEventsScreen,
        title: "Linked events",
        summary: "Switch to an event linked to this one.",
        needsOwnEvent: true,
      },
    ],
  },
  {
    title: "Customization and diagnostics",
    demos: [
      {
        route: "Branding",
        screen: BrandingScreen,
        title: "Branding and entitlements",
        summary: "See what the joined event's API key permits.",
      },
      {
        route: "Localization",
        screen: LocalizationScreen,
        title: "Localization and accessibility",
        summary:
          "The SDK's own texts, in the app's language, for your custom parts.",
      },
      {
        route: "Diagnostics",
        screen: DiagnosticsScreen,
        title: "Diagnostics log",
        summary: "Read what the SDK did, and why a call failed.",
      },
    ],
  },
];

const logo = require("../assets/logo.png");
const logoDark = require("../assets/logo-dark.png");

type Props = NativeStackScreenProps<DemoStackParamList, "Home">;

export const HomeScreen: React.FC<Props> = ({ navigation }) => {
  const theme = useDemoTheme();
  return (
    <SafeAreaView edges={["top"]} style={[styles.screen, { backgroundColor: theme.pageBackground }]}>
      <View style={styles.topBar}>
        <DemoPlatformBadge />
        <DemoApiKeyMenu />
      </View>
      <ScrollView
        style={{ backgroundColor: theme.pageBackground }}
        contentContainerStyle={styles.content}
      >
        <View style={styles.header}>
          <Image
            source={theme.dark ? logoDark : logo}
            style={styles.logo}
            resizeMode="contain"
            accessibilityIgnoresInvertColors
          />
          <Text style={[styles.version, { color: theme.secondaryText }]}>
            {`SDK ${getSdkVersion()} · native SDK ${getNativeSdkVersion()}`}
          </Text>
          <Text style={[styles.tagline, { color: theme.text }]}>
            A quick tour of LiveVoice SDK features.
          </Text>
        </View>
        {demoSections.map((section) => (
          <DemoListSection key={section.title} title={section.title}>
            {section.demos.map((demo, index) => (
              <DemoListRow
                key={demo.route}
                title={demo.title}
                summary={demo.summary}
                needsOwnEvent={demo.needsOwnEvent}
                showsDivider={index < section.demos.length - 1}
                onPress={() => navigation.navigate(demo.route)}
              />
            ))}
          </DemoListSection>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  screen: { flex: 1 },
  // As high as Flutter's app bar, so the badge sits in the same place.
  topBar: {
    height: 56,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: 16,
  },
  content: {
    paddingHorizontal: 16,
    paddingBottom: 32,
    gap: 24,
  },
  header: {
    alignItems: "center",
    gap: 4,
    paddingTop: 24,
  },
  logo: {
    width: 129.5,
    aspectRatio: 129.5 / 88.7,
  },
  version: {
    fontSize: 11,
  },
  tagline: {
    marginTop: 8,
    fontSize: 15,
    textAlign: "center",
    paddingHorizontal: 24,
  },
});
