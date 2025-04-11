import React, {useEffect} from 'react';
import {
  View,
  Text,
  useColorScheme,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import {type Reconnecting} from 'livevoice-sdk-react-native';

export interface ReconnectingProps {
  isDarkMode?: boolean;
  state: Reconnecting;
  onPress: () => void;
}

export const ReconnectingView: React.FC<ReconnectingProps> = props => {
  const isDarkMode = props.isDarkMode ?? useColorScheme() === 'dark';
  const reconnectingState = props.state;
  const isAttemptOngoing = reconnectingState.state.type === 'inProgress';

  const [secUntilRetry, setSecUntilRetry] = React.useState(0);

  useEffect(() => {
    const newValue = calculateSecondsUntilRetry(reconnectingState);
    setSecUntilRetry(newValue);

    const interval = setInterval(() => {
      const newValue = calculateSecondsUntilRetry(reconnectingState);
      setSecUntilRetry(newValue);
    }, 1000);

    return () => clearInterval(interval);
  }, [reconnectingState]);

  return (
    <View
      style={[
        styles.container,
        isDarkMode ? {backgroundColor: '#191919'} : {backgroundColor: '#fff'},
      ]}>
      <Text
        style={[styles.text, isDarkMode ? styles.darkText : styles.lightText]}>
        {reconnectingState.state.type === 'awaitingRetry'
          ? `${secUntilRetry} seconds until retry`
          : 'Reconnecting...'}
      </Text>

      <TouchableOpacity
        onPress={props.onPress}
        activeOpacity={0.8}
        style={[
          styles.button,
          isDarkMode
            ? {
                backgroundColor: '#f56230',
                borderColor: 'transparent',
                outlineColor: '#77392421',
              }
            : {
                backgroundColor: '#f56230',
                borderColor: 'transparent',
                outlineColor: '#f5623021',
              },
        ]}>
        {isAttemptOngoing ? (
          <ActivityIndicator
            size="small"
            color={isDarkMode ? '#ffffff' : '#ffffff'}
          />
        ) : (
          <Text
            style={[
              styles.buttonText,
              isDarkMode ? styles.lightButtonText : styles.darkButtonText,
            ]}>
            Retry Now
          </Text>
        )}
      </TouchableOpacity>
    </View>
  );
};

function calculateSecondsUntilRetry(reconnectingState: Reconnecting): number {
  return reconnectingState.state.type === 'awaitingRetry'
    ? reconnectingState.state.atTimestamp - Date.now() / 1000
    : 0;
}

const styles = StyleSheet.create({
  container: {
    paddingVertical: 20,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 10,
    width: '100%',
    marginBottom: 10,
  },
  text: {
    fontSize: 14,
    fontWeight: '500',
    textAlign: 'center',
    paddingHorizontal: 18,
  },
  darkText: {
    color: '#ffffff',
  },
  lightText: {
    color: '#191919',
  },
  button: {
    paddingVertical: 8,
    paddingHorizontal: 18,
    borderRadius: 10,
    borderWidth: 2,
    outlineStyle: 'solid',
    outlineWidth: 3,
    marginTop: 12,
    alignItems: 'center',
    justifyContent: 'center',
    minWidth: 100,
  },
  buttonText: {
    fontSize: 14,
    fontWeight: '500',
    textAlign: 'center',
  },
  lightButtonText: {
    color: '#ffffff',
  },
  darkButtonText: {
    color: '#ffffff',
  },
});
