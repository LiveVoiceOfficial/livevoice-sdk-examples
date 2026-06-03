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

import { useState } from "react";
import {
  View,
  StyleSheet,
  useColorScheme,
  TouchableOpacity,
  Text,
} from "react-native";
import { SafeAreaProvider, SafeAreaView } from "react-native-safe-area-context";
import {
  initialize,
  joinEvent,
  serviceEnabledWithMessage,
} from "livevoice-sdk-react-native";
import { CustomLiveVoiceView } from "./components";
import { LiveDemo } from "./components/LiveDemo";

// On production we can use thi
initialize(serviceEnabledWithMessage("Channel %s is playing!"));

// will show branding underneath the channels
// @ts-ignore
const noClaimsApiKey = "HD4cQklUOQKOBWimG54j2kRnxFklDL";

// Use this key to hide the branding underneath the channels
// @ts-ignore
const allClaimsApiKey = "s09WEG5y3caQ6R2PDaG4i8R1aTooTd";

// Separate call to connect
joinEvent("123456", null, allClaimsApiKey);

type Tab = "Default" | "Custom";

interface TabNavigatorProps {
  isDarkMode: boolean;
}

const TabNavigator: React.FC<TabNavigatorProps> = ({ isDarkMode }) => {
  const [activeTab, setActiveTab] = useState<Tab>("Default");

  // Map tab names to components
  const renderScreen = () => {
    switch (activeTab) {
      case "Default":
        return <LiveDemo isDarkMode={isDarkMode} />;
      case "Custom":
        return <CustomLiveVoiceView isDarkMode={isDarkMode} />;
      default:
        return null;
    }
  };

  return (
    <View style={styles.container}>
      {/* Custom Tab Bar */}
      <View style={styles.tabBar}>
        {(["Default", "Custom"] as Tab[]).map((tab) => (
          <TouchableOpacity
            activeOpacity={0.8}
            key={tab}
            style={[
              styles.tabButton,
              activeTab === tab &&
                (isDarkMode ? styles.activeTabDark : styles.activeTab),
            ]}
            onPress={() => setActiveTab(tab)}
          >
            <Text style={isDarkMode ? styles.tabTextDark : styles.tabText}>
              {tab}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
      {/* Render the active screen */}
      <View style={styles.content}>{renderScreen()}</View>
    </View>
  );
};

export default function App() {
  const theme = useColorScheme();

  const [isDarkMode, setisDarkMode] = useState(theme === "dark");

  return (
    <SafeAreaProvider>
      <SafeAreaView
        style={{
          flex: 1,
          backgroundColor: isDarkMode
            ? styles.safeAreaDark.backgroundColor
            : styles.safeArea.backgroundColor,
        }}
      >
        {/* Switch light/dark mode for testing*/}
        <View
          style={{
            paddingHorizontal: 20,
            paddingVertical: 10,
            flexDirection: "row",
            justifyContent: "flex-end",
          }}
        >
          <TouchableOpacity
            style={styles.button}
            onPress={() => setisDarkMode(!isDarkMode)}
            activeOpacity={0.8}
          >
            <Text style={isDarkMode ? styles.text : { color: "#000" }}>
              Switch to {isDarkMode ? "Light" : "Dark"}
            </Text>
          </TouchableOpacity>
        </View>

        <View style={{ flex: 1, minHeight: 0 }}>
          <TabNavigator isDarkMode={isDarkMode} />
        </View>
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    backgroundColor: "#F5F5F5",
  },
  safeAreaDark: {
    backgroundColor: "#1E1F23",
  },
  container: {
    flex: 1,
    flexDirection: "column",
    overflow: "hidden",
  },
  button: {
    padding: 5,
  },
  text: {
    color: "#fff",
  },
  content: {
    flex: 1,
    minHeight: 0,
    overflow: "hidden",
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  tabBar: {
    flexDirection: "row",
    justifyContent: "flex-start",
    gap: 20,
    paddingVertical: 12,
    paddingHorizontal: 20,
  },
  tabButton: {
    padding: 10,
  },
  activeTab: {
    borderBottomWidth: 2,
    borderBottomColor: "#222",
  },
  activeTabDark: {
    borderBottomWidth: 2,
    borderBottomColor: "#FFF",
  },
  tabText: {
    color: "#222",
    fontSize: 16,
    fontWeight: "500",
  },
  tabTextDark: {
    color: "#FFF",
    fontSize: 16,
    fontWeight: "500",
  },
});
