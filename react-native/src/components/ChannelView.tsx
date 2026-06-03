import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  useColorScheme,
} from 'react-native';
import {PlayingState} from 'livevoice-sdk-react-native';
import PlayButtonView from './PlayButtonView';

export interface ChannelProps {
  channelName: string;
  playingState: PlayingState;
  muted: boolean;
  isOnline: boolean;
  aiSpeaker: boolean;
  isDarkMode?: boolean;
  onPress: () => void;
}

export const ChannelView: React.FC<ChannelProps> = ({
  channelName,
  playingState,
  muted,
  isOnline,
  aiSpeaker,
  isDarkMode = useColorScheme() === 'dark',
  onPress,
}) => {
  const [collapsed, setCollapsed] = useState(true);

  return (
    <View
      style={[
        styles.container,
        {
          backgroundColor: isDarkMode ? '#191919' : '#fff',
          borderColor: isDarkMode ? '#77392421' : '#f5623021',
        },
      ]}>
      {muted && (
       <Text>🎤</Text>
      )}
      <View style={{flex: 1, marginLeft: 10}}>
        <TouchableOpacity
          onPress={() => setCollapsed(!collapsed)}
          activeOpacity={0.8}>
          <Text
            numberOfLines={collapsed ? 1 : undefined}
            ellipsizeMode="tail"
            style={[styles.text, {color: isDarkMode ? '#fff' : '#000'}]}>
            {channelName}
          </Text>
        </TouchableOpacity>
        {aiSpeaker && (
          <View style={styles.aiContainer}>
            <Text>[AI]</Text>
            <Text
              style={[styles.aiText, {color: isDarkMode ? '#fff' : '#000'}]}>
              ai speaker
            </Text>
          </View>
        )}
      </View>
      <PlayButtonView
        playingState={playingState}
        onPress={onPress}
        isDarkMode={isDarkMode}
        isChannelOnline={isOnline}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 18,
    borderRadius: 10,
    borderWidth: 2,
    outlineStyle: 'solid',
    outlineWidth: 3,
    marginBottom: 10,
  },
  text: {
    fontSize: 16,
    fontWeight: '500',
  },
  aiContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  aiText: {
    fontSize: 12,
    fontWeight: '400',
    marginLeft: 4,
  },
});
