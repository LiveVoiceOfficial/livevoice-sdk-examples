/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import {
  serviceEnabledWithDefaultMessage,
  initialize,
  joinEvent,
  LiveVoiceView,
  AudioOutputSwitchView,
} from 'livevoice-sdk-react-native';
import React, {useState} from 'react';
import type {PropsWithChildren} from 'react';
import {
  StyleSheet,
  useColorScheme,
  View,
  TouchableOpacity,
  Text,
} from 'react-native';

import {Colors} from 'react-native/Libraries/NewAppScreen';
import { CustomLiveVoiceView } from './components';


// will show branding underneath the channels
// @ts-ignore
const noClaimsApiKey = 'HD4cQklUOQKOBWimG54j2kRnxFklDL'

// Use this key to hide the branding underneath the channels
// @ts-ignore
const allClaimsApiKey = 's09WEG5y3caQ6R2PDaG4i8R1aTooTd'

initialize(serviceEnabledWithDefaultMessage);
joinEvent('123456', null, allClaimsApiKey);

type Tab = 'Default' | 'Custom';

interface TabNavigatorProps {
  isDarkMode: boolean;
}

const TabNavigator: React.FC<TabNavigatorProps> = ({isDarkMode}) => {
  const [activeTab, setActiveTab] = useState<Tab>('Default');

  // Map tab names to components
  const renderScreen = () => {
    switch (activeTab) {
      case 'Custom':
        return <CustomLiveVoiceView isDarkMode={isDarkMode} />;
      default:
        return (
          <>
            {/* Show real livevoice view */}
            <AudioOutputSwitchView isDarkMode={isDarkMode}/>
            <LiveVoiceView isDarkMode={isDarkMode} />
          </>
        );
    }
  };

  return (
    <View style={styles.container}>
      {/* Custom Tab Bar */}
      <View style={styles.tabBar}>
        {(['Default', 'Custom'] as Tab[]).map(tab => (
          <TouchableOpacity
            activeOpacity={0.8}
            key={tab}
            style={[
              styles.tabButton,
              activeTab === tab &&
                (isDarkMode ? styles.activeTabDark : styles.activeTab),
            ]}
            onPress={() => setActiveTab(tab)}>
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

function App(): React.JSX.Element {
  const theme = useColorScheme();

  const [isDarkMode, changeTheme] = useState(theme === 'dark');

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <View
      style={{
        flex: 1,
        paddingTop: '20%',
        paddingHorizontal: '5%',
        backgroundColor: backgroundStyle.backgroundColor,
      }}>
      {/* Switch light/dark mode for testing*/}
      <View
        style={{padding: 20, flexDirection: 'row', justifyContent: 'flex-end'}}>
        <TouchableOpacity
          style={styles.button}
          onPress={() => changeTheme(!isDarkMode)}
          activeOpacity={0.8}>
          <Text style={isDarkMode ? styles.text : {color: '#000'}}>
            Switch to {isDarkMode ? 'Light' : 'Dark'}
          </Text>
        </TouchableOpacity>
      </View>
      <TabNavigator isDarkMode={isDarkMode} />
    </View>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  safeAreaDark: {
    flex: 1,
    backgroundColor: '#1E1F23',
  },
  container: {
    flex: 1,
    padding: 20,
  },
  button: {
    padding: 5,
  },
  text: {
    color: '#fff',
  },
  content: {
    marginTop: 10,
  },
  tabBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 12,
  },
  tabButton: {
    padding: 10,
  },
  activeTab: {
    borderBottomWidth: 2,
    borderBottomColor: '#222',
  },
  activeTabDark: {
    borderBottomWidth: 2,
    borderBottomColor: '#FFF',
  },
  tabText: {
    color: '#222',
    fontSize: 16,
    fontWeight: '500',
  },
  tabTextDark: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '500',
  },
});

export default App;
