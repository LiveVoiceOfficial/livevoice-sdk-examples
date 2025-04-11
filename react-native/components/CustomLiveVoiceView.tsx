import {
  getCurrentUiState,
  onUiStateChanged,

  startChannel,
  stopChannel,
  reconnect,
  type Channel,
  UiState,
  AvailableSubtitleConfigs,
  onAvailableSubtitleConfigsChanged,
  ErrorState,
  PlayingState,
} from 'livevoice-sdk-react-native';
import { useEffect, useState } from 'react';
import { View, ActivityIndicator } from 'react-native';

import { ChannelView } from './ChannelView';
import { ErrorView } from './ErrorView';
import { ReconnectingView } from './ReconnectingView';
import { AudioOutputSwitchView } from './AudioOutputSwitchView';

export interface CustomLiveVoiceViewProps {
  isDarkMode?: boolean;
}

export const CustomLiveVoiceView: React.FC<CustomLiveVoiceViewProps> = ({
  isDarkMode,
}) => {
  const [uiState, setUiState] = useState<UiState>(() =>
    getCurrentUiState(),
  );

  useEffect(() => {
    onUiStateChanged((data: UiState) => {
      setUiState(data);
    });
  }, []);

  useEffect(() => {
    onAvailableSubtitleConfigsChanged((data: AvailableSubtitleConfigs) => {
      console.log('available subtitles changed!' + JSON.stringify(data));
    });
  }, []);

  switch (uiState.type) {
    case 'loading':
      return (
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
          <ActivityIndicator size={40} />
        </View>
      )
    case 'ready':
      return (
        <View>
          <View style={{ marginBottom: 10 }}>
            <AudioOutputSwitchView
              isDarkMode={isDarkMode} onPress={() => { }}
            />
          </View>
          {uiState.channels.map((channel: Channel, index: number) => (
              <ChannelView
                key={index}
                playingState={channel.playingState}
                isDarkMode={isDarkMode}
                muted={channel.isAudioMuted}
                isOnline={channel.isOnline}
                aiSpeaker={channel.isAiSpeaker}
                channelName={channel.name}
                onPress={() =>
                  channel.playingState === PlayingState.PLAYING
                    ? stopChannel()
                    : startChannel(channel.id)
                }
              />
            ))}
        </View>)

    case 'reconnecting':
      <ReconnectingView
        state={uiState}
        onPress={() => {
          reconnect();
        }}
      />

    case 'error':
      return (
        <ErrorView
          state={uiState as ErrorState}
          onPress={() => {
            reconnect();
          }}
        />
      );
  }
};

export default CustomLiveVoiceView;
