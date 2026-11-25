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
import { SafeAreaProvider } from "react-native-safe-area-context";
import {
  DarkTheme,
  DefaultTheme,
  NavigationContainer,
} from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { DemoApiKeyMenu, DemoEventPickerModal } from "./demo/DemoEventPicker";
import type { DemoStackParamList } from "./demo/DemoNavigation";
import { DemoSessionProvider } from "./demo/DemoSession";
import { useDemoTheme } from "./demo/DemoTheme";
import { demoSections, HomeScreen } from "./screens/HomeScreen";

const Stack = createNativeStackNavigator<DemoStackParamList>();

export default function App() {
  const theme = useDemoTheme();
  return (
    <SafeAreaProvider>
      {/* Initializes the SDK and joins the event picked in the header. */}
      <DemoSessionProvider>
        <NavigationContainer theme={theme.dark ? DarkTheme : DefaultTheme}>
          <Stack.Navigator
            screenOptions={{
              // Each screen shows its title in its content, as on iOS.
              title: "",
              headerRight: () => <DemoApiKeyMenu />,
              headerShadowVisible: false,
              headerStyle: { backgroundColor: theme.pageBackground },
              headerTintColor: theme.accent,
              contentStyle: { backgroundColor: theme.pageBackground },
              headerBackButtonDisplayMode: "minimal",
            }}
          >
            <Stack.Screen
              name="Home"
              component={HomeScreen}
              // The home screen draws its own flat top row: iOS's navigation bar
              // would put the badge and the key button into glass buttons.
              options={{ headerShown: false }}
            />
            {demoSections.flatMap((section) =>
              section.demos.map((demo) => (
                <Stack.Screen
                  key={demo.route}
                  name={demo.route}
                  component={demo.screen}
                />
              )),
            )}
          </Stack.Navigator>
        </NavigationContainer>
        <DemoEventPickerModal />
      </DemoSessionProvider>
    </SafeAreaProvider>
  );
}
