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

import { TouchableOpacity, ScrollView, Text, View } from "react-native";
import {
  getCurrentSubtitles,
  onSubtitlesChanged,
  stopSubtitles,
  LiveVoiceView,
  AudioOutputSwitchView,
} from "livevoice-sdk-react-native";
import type { DemoProps } from "./DemoProps";
import { useEffect, useRef, useState } from "react";

export const LiveDemo: React.FC<DemoProps> = ({ isDarkMode }) => {
  const [subtitles, setSubtitles] = useState<[String]>(() =>
    getCurrentSubtitles(),
  );
  const scrollViewRef = useRef<React.ElementRef<typeof ScrollView> | null>(
    null,
  );

  useEffect(() => {
    let subscription: { remove: () => void } | undefined = onSubtitlesChanged(
      (data: [String]) => {
        setSubtitles(data);
      },
    );
    return () => {
      subscription?.remove();
      subscription = undefined;
    };
  }, []);

  return (
    <View style={{ flex: 1, rowGap: 20, alignItems: "center" }}>
      <AudioOutputSwitchView isDarkMode={isDarkMode} />

      <LiveVoiceView isDarkMode={isDarkMode} />

      {subtitles && (
        <View style={{ flex: 1, alignItems: "center", rowGap: 10 }}>
          <TouchableOpacity
            onPress={() => {
              stopSubtitles();
              console.log("Stopping subtitles");
            }}
          >
            <Text style={{ fontSize: 12, color: "orange" }}>
              Stop Subtitles
            </Text>
          </TouchableOpacity>
          <ScrollView
            style={{ width: "100%", flex: 1 }}
            ref={scrollViewRef}
            onContentSizeChange={() =>
              scrollViewRef.current?.scrollToEnd({ animated: false })
            }
          >
            {subtitles.map((subtitle, idx) => (
              <View key={idx}>
                <Text
                  style={{ color: isDarkMode ? "#FFF" : "#000", fontSize: 16 }}
                >
                  {subtitle}
                </Text>
              </View>
            ))}
          </ScrollView>
        </View>
      )}
    </View>
  );
};
