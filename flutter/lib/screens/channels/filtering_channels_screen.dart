// Filtering channels
//
// LiveVoiceView's `filter` decides which channels it shows: it gets each
// channel and returns `true` to keep it. Filter on any channel property;
// the look, playback and reconnection stay the same. A filter that matches
// nothing shows the view's "no matching channels" state.
//
// In Flutter, `filter` is a constructor argument: to change it, rebuild the
// view with a new function (here with setState). LiveVoiceView keeps its
// state across the rebuild.
//
// Uses: LiveVoiceView(filter:), LiveVoiceChannel
// See also: Default interface, Custom view states (your own empty part).

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';

class FilteringChannelsScreen extends StatefulWidget {
  const FilteringChannelsScreen({super.key});

  @override
  State<FilteringChannelsScreen> createState() =>
      _FilteringChannelsScreenState();
}

enum _Filter { all, online, withSubtitles, none }

class _FilteringChannelsScreenState extends State<FilteringChannelsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) => DemoScreen(
    title: 'Filtering channels',
    caption: 'Show only the channels you want.',
    children: [
      DemoSection(
        'Filter',
        children: [
          DemoSegmentedPicker(
            options: const {
              _Filter.all: 'All',
              _Filter.online: 'Online',
              _Filter.withSubtitles: 'Subtitles',
              _Filter.none: 'None',
            },
            selected: _filter,
            onChanged: (filter) => setState(() => _filter = filter),
          ),
        ],
      ),
      DemoSection(
        'Channels',
        children: [
          LiveVoiceView(
            filter: (channel) => switch (_filter) {
              _Filter.all => true,
              _Filter.online => channel.isOnline,
              _Filter.withSubtitles => channel.hasSubtitles,
              _Filter.none => false,
            },
            // More filters:
            // - A single channel, by its ID from the dashboard's "Show Options":
            //   `channel.id == 137`
            // - A source channel with the AI translations derived from it:
            //   `channel.id == sourceId ||
            //    channel.aiTranslationInfo?.sourceChannelId == sourceId`
          ),
        ],
      ),
    ],
  );
}
