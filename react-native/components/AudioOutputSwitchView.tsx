import { getCurrentAudioState, getCurrentUiState, onAudioOutputChanged, setLiveVoiceUseSpeaker } from 'livevoice-sdk-react-native';
import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Easing,
  Text,
} from 'react-native';

export interface AudioOutputSwitchProps {
  isDarkMode?: boolean;
  onPress?: () => void;
}

export const AudioOutputSwitchView: React.FC<AudioOutputSwitchProps> = ({
  isDarkMode,
  onPress,
}) => {
  const [isSpeaker, setIsSpeaker] = useState<Boolean>((() => (getCurrentAudioState())))
  const animation = useRef(new Animated.Value(isSpeaker ? 1 : 0)).current;

  useEffect(
    () => {
      onAudioOutputChanged((value: boolean) => {
        console.log('State changed: ' + value);
        setIsSpeaker(value);
      });
    }, []);

  useEffect(() => {
    Animated.timing(animation, {
      toValue: isSpeaker ? 1 : 0,
      duration: 100,
      easing: Easing.out(Easing.circle),
      useNativeDriver: false,
    }).start();
  }, [isSpeaker]);

  const togglePosition = animation.interpolate({
    inputRange: [0, 1],
    outputRange: [0, 58],
  });

  const iconColor = '#000';

  return (
    <TouchableOpacity
      activeOpacity={0.8}
      onPress={() => setLiveVoiceUseSpeaker(!isSpeaker)}
      style={[
        styles.container,
        isDarkMode
          ? { backgroundColor: '#f56230', borderColor: 'transparent', outlineColor: '#77392421' }
          : { backgroundColor: '#f56230', borderColor: 'transparent', outlineColor: '#f5623021' },
      ]}
    >
      <View style={styles.iconContainer}>
        <Text>🎧</Text>
        <Text>🔊</Text>
      </View>

      <Animated.View
        style={[
          styles.toggle,
          isDarkMode
            ? { backgroundColor: '#ffffff', borderColor: '#ffffff', outlineColor: '#ff7433' }
            : { backgroundColor: '#ffffff', borderColor: '#ffffff', outlineColor: '#f56230' },
          { transform: [{ translateX: togglePosition }] },
        ]}
      >
        {isSpeaker ? (
          <Text>🔊</Text>
        ) : (
          <Text>🎧</Text>
        )}
      </Animated.View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    width: 120,
    height: 40,
    borderRadius: 10,
    borderWidth: 2,
    outlineStyle: 'solid',
    outlineWidth: 3,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 8,
    position: 'relative',
  },
  iconContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
    paddingHorizontal: 7,
  },
  toggle: {
    width: 58,
    height: 34,
    borderRadius: 10,
    borderWidth: 0,
    outlineStyle: 'solid',
    outlineWidth: 3,
    position: 'absolute',
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});