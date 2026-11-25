// The demo list: one screen per feature, grouped into sections.

import 'package:flutter/material.dart';

import 'demo/demo_event_picker.dart';
import 'demo/demo_list_row.dart';
import 'demo/demo_theme.dart';
import 'screens/audio_and_system/audio_output_screen.dart';
import 'screens/audio_and_system/lock_screen_screen.dart';
import 'screens/channels/custom_channel_cell_screen.dart';
import 'screens/channels/custom_view_states_screen.dart';
import 'screens/channels/filtering_channels_screen.dart';
import 'screens/customization/branding_screen.dart';
import 'screens/customization/diagnostics_screen.dart';
import 'screens/customization/localization_screen.dart';
import 'screens/event_features/language_requests_screen.dart';
import 'screens/event_features/linked_events_screen.dart';
import 'screens/event_features/passwords_screen.dart';
import 'screens/getting_started/default_interface_screen.dart';
import 'screens/getting_started/joining_event_screen.dart';
import 'screens/subtitles/subtitles_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Scaffold(
      backgroundColor: theme.pageBackground,
      appBar: AppBar(
        backgroundColor: theme.pageBackground,
        leading: const Center(child: DemoPlatformBadge()),
        leadingWidth: 96,
        actions: const [DemoApiKeyMenu(), SizedBox(width: 8)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const DemoHomeHeader(),
          DemoListGroup(
            'Getting started',
            children: [
              DemoListRow(
                title: 'Default interface',
                summary:
                    "The smallest integration: the event's channels, ready to play.",
                destination: () => const DefaultInterfaceScreen(),
              ),
              DemoListRow(
                title: 'Joining an event',
                summary:
                    'Join, reconnect and leave, and follow the connection.',
                destination: () => const JoiningEventScreen(),
              ),
            ],
          ),
          DemoListGroup(
            'Channels',
            children: [
              DemoListRow(
                title: 'Filtering channels',
                summary: 'Show only the channels you want.',
                destination: () => const FilteringChannelsScreen(),
              ),
              DemoListRow(
                title: 'Custom channel cell',
                summary: 'Draw each channel with your own view.',
                destination: () => const CustomChannelCellScreen(),
              ),
              DemoListRow(
                title: 'Custom view states',
                summary:
                    'Your own loading, reconnecting, error and empty views.',
                destination: () => const CustomViewStatesScreen(),
              ),
            ],
          ),
          DemoListGroup(
            'Subtitles',
            children: [
              DemoListRow(
                title: 'Subtitles',
                summary: "Show a channel's live subtitles in your own view.",
                destination: () => const SubtitlesScreen(),
              ),
            ],
          ),
          DemoListGroup(
            'Audio and system',
            children: [
              DemoListRow(
                title: 'Audio output',
                summary: 'Prefer the loudspeaker, or let the system choose.',
                destination: () => const AudioOutputScreen(),
              ),
              DemoListRow(
                title: 'Lock screen and audio sharing',
                summary:
                    'Share the audio with other apps, and show the channel on the Lock Screen.',
                destination: () => const LockScreenScreen(),
              ),
            ],
          ),
          DemoListGroup(
            'Event features',
            children: [
              DemoListRow(
                title: 'Password-protected channels',
                summary:
                    'Ask for channel passwords with your own UI, and keep them.',
                needsOwnEvent: true,
                destination: () => const PasswordsScreen(),
              ),
              DemoListRow(
                title: 'Language requests',
                summary: "Ask the event for a language it doesn't offer yet.",
                needsOwnEvent: true,
                destination: () => const LanguageRequestsScreen(),
              ),
              DemoListRow(
                title: 'Linked events',
                summary: 'Switch to an event linked to this one.',
                needsOwnEvent: true,
                destination: () => const LinkedEventsScreen(),
              ),
            ],
          ),
          DemoListGroup(
            'Customization and diagnostics',
            children: [
              DemoListRow(
                title: 'Branding and entitlements',
                summary: "See what the joined event's API key permits.",
                destination: () => const BrandingScreen(),
              ),
              DemoListRow(
                title: 'Localization and accessibility',
                summary:
                    "The SDK's own texts, in the app's language, for your custom parts.",
                destination: () => const LocalizationScreen(),
              ),
              DemoListRow(
                title: 'Diagnostics log',
                summary: 'Read what the SDK did, and why a call failed.',
                destination: () => const DiagnosticsScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
