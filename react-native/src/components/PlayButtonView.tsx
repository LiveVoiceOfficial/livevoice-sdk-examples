import {
  ActivityIndicator,
  Text,
  TouchableOpacity,
  useColorScheme,
} from 'react-native';
import {PlayingState} from 'livevoice-sdk-react-native';

export interface PlayButtonProps {
  playingState: PlayingState;
  isChannelOnline: boolean;
  isDarkMode?: boolean;
  onPress: () => void;
}

const PlayButtonView: React.FC<PlayButtonProps> = ({
  playingState,
  isChannelOnline,
  isDarkMode = useColorScheme() === 'dark',
  onPress,
}) => {
  const isPlaying = playingState === PlayingState.PLAYING;
  const isTransitioning = playingState === PlayingState.TRANSITIONING;

  const iconColor = !isChannelOnline
    ? isDarkMode
      ? '#6B7280'
      : '#D1D5DB' // Gray tones for offline
    : isPlaying
    ? '#783D19' // Earthy brown for playing
    : '#F5F3F0'; // Soft beige for paused

  const opacity = isChannelOnline ? 1 : 0.7; // Slightly reduced opacity for offline

  const getButtonIcon = () => {
    if (isTransitioning) {
      return (
        <ActivityIndicator size={20} color={iconColor} style={{opacity}} />
      );
    }
    return isPlaying ? (
      <Text>⏸️</Text>
    ) : (
     <Text>▶️</Text>
    );
  };

  const getStyleType = () => {
    if (!isChannelOnline) return 'offline';
    if (isPlaying) return 'playing';
    return 'paused';
  };

  return (
    <TouchableOpacity
      style={getButtonStyle(getStyleType(), isDarkMode)}
      onPress={onPress}
      activeOpacity={0.8}>
      {getButtonIcon()}
    </TouchableOpacity>
  );
};

type ButtonStyleType = 'paused' | 'playing' | 'offline';

export const getButtonStyle = (type: ButtonStyleType, isDarkMode: boolean) => {
  return ButtonStyles[type][isDarkMode ? 'dark' : 'light'];
};

const baseButtonStyle = {
  paddingVertical: 8,
  paddingHorizontal: 18,
  borderRadius: 10,
  borderWidth: 2,
  outlineStyle: 'solid' as const,
  outlineWidth: 3,
};

export const ButtonStyles = {
  paused: {
    light: {
      ...baseButtonStyle,
      backgroundColor: '#4A7049', // Forest green
      borderColor: 'transparent',
      outlineColor: '#4A704933', // Green with transparency
    },
    dark: {
      ...baseButtonStyle,
      backgroundColor: '#5A8C59', // Slightly lighter green
      borderColor: 'transparent',
      outlineColor: '#5A8C5933', // Matching transparency
    },
  },

  playing: {
    light: {
      ...baseButtonStyle,
      backgroundColor: '#F5F3F0', // Soft beige
      borderColor: '#F5F3F0',
      outlineColor: '#A68A64', // Warm taupe
    },
    dark: {
      ...baseButtonStyle,
      backgroundColor: '#EDE9E3', // Darker beige
      borderColor: '#EDE9E3',
      outlineColor: '#8C6F4A', // Darker taupe
    },
  },

  offline: {
    light: {
      ...baseButtonStyle,
      backgroundColor: 'transparent',
      borderColor: '#A3A3A3', // Mid-gray
      outlineColor: '#E5E7EB', // Light gray
    },
    dark: {
      ...baseButtonStyle,
      backgroundColor: 'transparent',
      borderColor: '#4B5563', // Dark gray
      outlineColor: '#6B7280', // Muted gray
    },
  },
};

export default PlayButtonView;
