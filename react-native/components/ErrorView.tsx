import React from 'react';
import {
  View,
  Text,
  useColorScheme,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import {type ErrorState} from 'livevoice-sdk-react-native';

export interface ErrorProps {
  isDarkMode?: boolean;
  state: ErrorState;
  onPress: () => void;
}

export const ErrorView: React.FC<ErrorProps> = props => {
  const isDarkMode = props.isDarkMode ?? useColorScheme() === 'dark';
  const state = props.state;

  const canBeRetried = state.type === 'error' && state.canBeRetried;

  return (
    <View
      style={[
        styles.container,
        isDarkMode ? {backgroundColor: '#191919'} : {backgroundColor: '#fff'},
      ]}>
      <Text
        style={[
          styles.text,
          state.type === 'error'
            ? styles.dangerText
            : isDarkMode
            ? styles.darkText
            : styles.lightText,
        ]}>
        {state.message}
      </Text>

      {canBeRetried && (
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
          <Text
            style={[
              styles.buttonText,
              isDarkMode ? styles.lightButtonText : styles.darkButtonText,
            ]}>
            Retry Now
          </Text>
        </TouchableOpacity>
      )}
    </View>
  );
};

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
  dangerText: {
    color: '#F1521B',
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
