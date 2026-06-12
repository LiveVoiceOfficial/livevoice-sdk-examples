//===----------------------------------------------------------------------===//
//
// This source file is part of the LiveVoice SDK project
//
// Copyright (c) LiveVoice GmbH
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../shared/demo_components.dart';
import '../theme.dart';

enum _FilterMode { all, hasSubtitles, noMatchingChannels }

const Map<_FilterMode, String> _predicateDescription = {
  _FilterMode.all: 'Predicate: (channel) => true',
  _FilterMode.hasSubtitles: 'Predicate: (channel) => channel.hasSubtitles',
  _FilterMode.noMatchingChannels: 'Predicate: (channel) => false',
};

class _SourceOption {
  const _SourceOption({required this.id, required this.name});

  final int id;
  final String name;
}

class FilteredChannelsScreen extends StatefulWidget {
  const FilteredChannelsScreen({super.key});

  @override
  State<FilteredChannelsScreen> createState() => _FilteredChannelsScreenState();
}

class _FilteredChannelsScreenState extends State<FilteredChannelsScreen> {
  _FilterMode _filterMode = _FilterMode.all;
  List<LiveVoiceAvailableSubtitle> _availableSubtitles = const [];
  int? _selectedSourceId;
  StreamSubscription<List<LiveVoiceAvailableSubtitle>?>? _subscription;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  Future<void> _listen() async {
    try {
      final config = await getCurrentSubtitleConfiguration();
      if (mounted) _applyConfig(config);
    } catch (_) {}
    _subscription = onAvailableSubtitleConfigsChanged.listen((data) {
      if (mounted) _applyConfig(data);
    });
  }

  void _applyConfig(List<LiveVoiceAvailableSubtitle>? config) {
    setState(() {
      _availableSubtitles = config ?? const [];
      // Keep the selection pointed at a current option. When the config reloads and the selected
      // source is no longer available, fall back to the first option (or clear it) instead of a
      // stale id that the picker can't resolve and shows as "Choose source channel".
      final options = _sourceOptions;
      if (options.every((o) => o.id != _selectedSourceId)) {
        _selectedSourceId = options.isNotEmpty ? options.first.id : null;
      }
    });
  }

  List<_SourceOption> get _sourceOptions {
    final namesById = {for (final s in _availableSubtitles) s.id: s.name};
    final rootIds = <int>{
      for (final s in _availableSubtitles) s.parent ?? s.id,
    };
    final options = rootIds
        .map((id) => _SourceOption(id: id, name: namesById[id] ?? 'Channel $id'))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return options;
  }

  bool _channelFilter(LiveVoiceChannel channel) {
    switch (_filterMode) {
      case _FilterMode.all:
        return true;
      case _FilterMode.hasSubtitles:
        return channel.hasSubtitles;
      case _FilterMode.noMatchingChannels:
        return false;
    }
  }

  bool _featuredFilter(LiveVoiceChannel channel) {
    if (_selectedSourceId == null) return true;
    return channel.id == _selectedSourceId ||
        channel.aiTranslationInfo?.sourceChannelId == _selectedSourceId;
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final options = _sourceOptions;
    String selectedLabel = 'Choose source channel';
    for (final option in options) {
      if (option.id == _selectedSourceId) {
        selectedLabel = option.name;
        break;
      }
    }

    return DemoScreen(
      title: 'Filtered channel list',
      summary:
          'Keep the standard LiveVoice list, but choose which channels appear — '
          'by any property, the empty state, or a source channel with its AI '
          'subtitles.',
      children: [
        DemoCardSection(
          title: 'Filter by property',
          children: [
            DemoDefaultLiveVoiceView(
              child: LiveVoiceView(filter: _channelFilter),
            ),
          ],
        ),
        DemoCardSection(
          title: 'Controls',
          children: [
            DemoSegmentedControl<_FilterMode>(
              value: _filterMode,
              onChanged: (mode) => setState(() => _filterMode = mode),
              options: const [
                DemoSegment(label: 'All', value: _FilterMode.all),
                DemoSegment(
                  label: 'Has subtitles',
                  value: _FilterMode.hasSubtitles,
                ),
                DemoSegment(
                  label: 'No match',
                  value: _FilterMode.noMatchingChannels,
                ),
              ],
            ),
            Text(
              _predicateDescription[_filterMode]!,
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        DemoCardSection(
          title: 'Source and AI subtitles',
          children: [
            if (options.isEmpty)
              Text(
                'This event has no source channel with derived AI subtitles. '
                'The filter keeps the source channel plus any channel whose '
                'aiTranslationInfo.sourceChannelId matches it.',
                style: TextStyle(color: theme.secondaryText, fontSize: 15),
              )
            else ...[
              DemoDefaultLiveVoiceView(
                child: LiveVoiceView(filter: _featuredFilter),
              ),
              DemoMenuPicker(
                selectedLabel: selectedLabel,
                selectedId: _selectedSourceId,
                onSelect: (id) => setState(() => _selectedSourceId = id as int?),
                options: [
                  for (final option in options)
                    DemoMenuOption(id: option.id, title: option.name),
                ],
              ),
            ],
          ],
        ),
        const DemoCardSection(
          title: 'Implementation notes',
          children: [
            DemoNotes(
              notes: [
                'You provide the filter to the LiveVoiceView.',
                'You can filter by any channel property and not just hard-coded IDs.',
                'A predicate that always returns false is useful for checking the no-matching-channels state.',
                "The source picker is derived from the demo event's available subtitle configuration.",
                'To feature a source channel, keep it plus any channel whose aiTranslationInfo.sourceChannelId matches.',
              ],
            ),
          ],
        ),
      ],
    );
  }
}
