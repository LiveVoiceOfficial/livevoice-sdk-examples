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

import '../theme.dart';
import 'demo_components.dart';

/// Wires the SDK's subtitle configuration, fragment feed, and start/stop calls.
class SubtitlesController extends ChangeNotifier {
  SubtitlesController() {
    _listen();
  }

  List<LiveVoiceAvailableSubtitle>? _availableSubtitles;
  LiveVoiceSubtitleState _state = const LiveVoiceSubtitlesDisabled();
  int? _selectedChannelId;

  StreamSubscription<List<LiveVoiceAvailableSubtitle>?>? _configSubscription;
  StreamSubscription<LiveVoiceSubtitleState>? _stateSubscription;

  List<LiveVoiceAvailableSubtitle>? get availableSubtitles =>
      _availableSubtitles;
  List<String> get fragments => _state.fragments;

  /// Whether subtitles are currently streaming.
  bool get enabled => _state is! LiveVoiceSubtitlesDisabled;

  int? get selectedChannelId => _selectedChannelId;

  Future<void> _listen() async {
    try {
      _availableSubtitles = await getCurrentSubtitleConfiguration();
      _state = await getCurrentSubtitleState();
      notifyListeners();
    } catch (_) {}
    _configSubscription = onAvailableSubtitleConfigsChanged.listen((data) {
      _availableSubtitles = data;
      notifyListeners();
    });
    _stateSubscription = onSubtitleStateChanged.listen((state) {
      _state = state;
      if (state is LiveVoiceSubtitlesSpecific) {
        _selectedChannelId = state.channelId;
      } else if (state is LiveVoiceSubtitlesAutomatic) {
        _selectedChannelId = null;
      }
      notifyListeners();
    });
  }

  void start() {
    startSubtitles(channelId: _selectedChannelId);
    notifyListeners();
  }

  void stop() {
    stopSubtitles();
    notifyListeners();
  }

  // The native API stops any previous stream automatically, so switching the
  // language is just another startSubtitles call.
  void select(int? channelId) {
    _selectedChannelId = channelId;
    if (enabled) {
      startSubtitles(channelId: channelId);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_configSubscription?.cancel());
    unawaited(_stateSubscription?.cancel());
    super.dispose();
  }
}

/// A fixed-height feed that stays pinned to the latest subtitle fragment.
class SubtitleFeed extends StatelessWidget {
  const SubtitleFeed({
    super.key,
    required this.fragments,
    required this.placeholder,
  });

  final List<String> fragments;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    if (fragments.isEmpty) {
      return Text(
        placeholder,
        style: TextStyle(
          color: theme.secondaryText,
          fontSize: 15,
          height: 20 / 15,
        ),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        reverse: true,
        itemCount: fragments.length,
        itemBuilder: (context, index) {
          final fragment = fragments[fragments.length - 1 - index];
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              fragment,
              style: TextStyle(color: theme.text, fontSize: 16, height: 22 / 16),
            ),
          );
        },
      ),
    );
  }
}

/// Builds the subtitle source picker options.
List<DemoMenuOption> mapSubtitleOptions(
  List<LiveVoiceAvailableSubtitle> subtitles,
) {
  final namesById = {for (final s in subtitles) s.id: s.name};
  final options = <DemoMenuOption>[
    const DemoMenuOption(id: null, title: 'Automatic'),
  ];

  final groups = <int, List<LiveVoiceAvailableSubtitle>>{};
  for (final subtitle in subtitles) {
    final rootId = subtitle.parent ?? subtitle.id;
    groups.putIfAbsent(rootId, () => []).add(subtitle);
  }

  final sortedRoots = groups.keys.toList()
    ..sort(
      (a, b) => (namesById[a] ?? '').compareTo(namesById[b] ?? ''),
    );

  for (final rootId in sortedRoots) {
    final items = (groups[rootId] ?? [])
      ..sort((a, b) => (a.language ?? '').compareTo(b.language ?? ''));
    final groupTitle = namesById[rootId] ?? 'Channel $rootId';
    for (var i = 0; i < items.length; i++) {
      final subtitle = items[i];
      options.add(
        DemoMenuOption(
          id: subtitle.id,
          title: subtitle.language == null
              ? 'Original transcript'
              : subtitle.name,
          sectionTitle: i == 0 ? 'Based on $groupTitle' : null,
        ),
      );
    }
  }

  return options;
}

/// Start/stop button plus the subtitle source picker.
class SubtitleControls extends StatelessWidget {
  const SubtitleControls({super.key, required this.controller});

  final SubtitlesController controller;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final configs =
        controller.availableSubtitles ?? const <LiveVoiceAvailableSubtitle>[];
    final hasSubtitles = configs.isNotEmpty;
    String selectedLabel = 'Automatic';
    for (final subtitle in configs) {
      if (subtitle.id == controller.selectedChannelId) {
        selectedLabel = subtitle.name;
        break;
      }
    }

    return DemoCardSection(
      title: 'Controls',
      children: [
        Opacity(
          opacity: hasSubtitles ? 1 : 0.5,
          child: GestureDetector(
            onTap: hasSubtitles
                ? (controller.enabled ? controller.stop : controller.start)
                : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                controller.enabled ? 'Stop subtitles' : 'Start subtitles',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        DemoMenuPicker(
          selectedLabel: selectedLabel,
          options: mapSubtitleOptions(configs),
          selectedId: controller.selectedChannelId,
          onSelect: (id) => controller.select(id as int?),
          enabled: hasSubtitles,
        ),
      ],
    );
  }
}
