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
import { useColorScheme } from "react-native";
import { SafeAreaProvider } from "react-native-safe-area-context";
import {
  DarkTheme,
  DefaultTheme,
  NavigationContainer,
} from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import {
  initialize,
  serviceEnabledWithMessage,
} from "livevoice-sdk-react-native";
import { DemoSessionProvider } from "./shared/DemoSession";
import { DemoApiKeyMenu } from "./shared/ui";
import { useDemoTheme } from "./theme";
import { HomeScreen } from "./screens/HomeScreen";
import { DefaultParticipantScreen } from "./screens/DefaultParticipantScreen";
import { FilteredChannelsScreen } from "./screens/FilteredChannelsScreen";
import { AudioOutputScreen } from "./screens/AudioOutputScreen";
import { SubtitleOnlyScreen } from "./screens/SubtitleOnlyScreen";
import { BrandingScreen } from "./screens/BrandingScreen";
import { CustomChannelCellScreen } from "./screens/CustomChannelCellScreen";
import { LocalizationScreen } from "./screens/LocalizationScreen";
import { allDemoItems, type DemoRoute } from "./screens/demos";

const DEMO_SCREENS: Record<DemoRoute, React.FC> = {
  DefaultParticipant: DefaultParticipantScreen,
  FilteredChannels: FilteredChannelsScreen,
  AudioOutput: AudioOutputScreen,
  SubtitleOnly: SubtitleOnlyScreen,
  Branding: BrandingScreen,
  CustomChannel: CustomChannelCellScreen,
  Localization: LocalizationScreen,
};

// Initialize the SDK once. On Android this also configures the foreground
// service used while audio is playing.
initialize(serviceEnabledWithMessage("Channel %s is playing!"));

export type RootStackParamList = { Home: undefined } & {
  [K in DemoRoute]: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  const scheme = useColorScheme();
  const theme = useDemoTheme();

  return (
    <SafeAreaProvider>
      <DemoSessionProvider>
        <NavigationContainer
          theme={scheme === "dark" ? DarkTheme : DefaultTheme}
        >
          <Stack.Navigator
            screenOptions={{
              headerRight: () => <DemoApiKeyMenu />,
              headerStyle: { backgroundColor: theme.pageBackground },
              headerTintColor: theme.text,
              contentStyle: { backgroundColor: theme.pageBackground },
              headerBackButtonDisplayMode: "minimal",
            }}
          >
            <Stack.Screen
              name="Home"
              component={HomeScreen}
              options={{ headerShown: false }}
            />
            {allDemoItems.map((item) => {
              const Screen = DEMO_SCREENS[item.route];
              return (
                <Stack.Screen
                  key={item.route}
                  name={item.route}
                  options={{ title: item.title }}
                >
                  {() => <Screen />}
                </Stack.Screen>
              );
            })}
          </Stack.Navigator>
        </NavigationContainer>
      </DemoSessionProvider>
    </SafeAreaProvider>
  );
}
