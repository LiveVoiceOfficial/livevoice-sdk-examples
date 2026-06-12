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

import React from "react";
import { ScrollView, StyleSheet, Text, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import type { NativeStackScreenProps } from "@react-navigation/native-stack";
import { getSdkVersion } from "livevoice-sdk-react-native";
import { useDemoTheme } from "../theme";
import {
  DemoApiKeyMenu,
  DemoListRow,
  DemoListSection,
  LiveVoiceLogo,
  PlatformBadge,
  SectionHeader,
} from "../shared/ui";
import { demoSections } from "./demos";
import type { RootStackParamList } from "../App";

type Props = NativeStackScreenProps<RootStackParamList, "Home">;

export const HomeScreen: React.FC<Props> = ({ navigation }) => {
  const theme = useDemoTheme();

  return (
    <SafeAreaView
      edges={["top"]}
      style={[styles.container, { backgroundColor: theme.pageBackground }]}
    >
      <View style={styles.topBar}>
        <PlatformBadge />
        <DemoApiKeyMenu />
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <LiveVoiceLogo />
          <Text style={[styles.version, { color: theme.secondaryText }]}>
            SDK {getSdkVersion()}
          </Text>
          <Text style={[styles.tagline, { color: theme.secondaryText }]}>
            A quick tour of LiveVoice SDK features.
          </Text>
        </View>

        {demoSections.map((section) => (
          <View key={section.title} style={styles.section}>
            <SectionHeader title={section.title} />
            <DemoListSection>
              {section.items.map((item, index) => (
                <DemoListRow
                  key={item.route}
                  title={item.title}
                  summary={item.summary}
                  showDivider={index < section.items.length - 1}
                  onPress={() => navigation.navigate(item.route)}
                />
              ))}
            </DemoListSection>
          </View>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  topBar: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingTop: 4,
  },
  content: {
    paddingHorizontal: 20,
    paddingBottom: 32,
    gap: 28,
  },
  header: {
    alignItems: "center",
    gap: 14,
    paddingTop: 8,
    paddingBottom: 4,
  },
  version: {
    fontSize: 13,
    textAlign: "center",
  },
  tagline: {
    fontSize: 16,
    textAlign: "center",
  },
  section: {
    gap: 0,
  },
});
