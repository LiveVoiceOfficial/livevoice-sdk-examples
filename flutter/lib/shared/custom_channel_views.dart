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

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../theme.dart';

/// The channel list rendered with fully custom rows via the public `cellBuilder`
/// of [LiveVoiceView].
class CustomChannelList extends StatelessWidget {
  const CustomChannelList({super.key, this.filter, this.detailed = false});

  /// Returns true for channels that should be displayed.
  final bool Function(LiveVoiceChannel channel)? filter;

  /// Render the richer [DetailedCustomChannelRow] instead of the basic row.
  final bool detailed;

  @override
  Widget build(BuildContext context) => LiveVoiceView(
    filter: filter,
    cellBuilder: (context, channel, cell) => detailed
        ? DetailedCustomChannelRow(
            channel: channel,
            isLast: cell.isLast,
            onAudioPressed: cell.onAudioPressed,
          )
        : BasicCustomChannelRow(
            channel: channel,
            isLast: cell.isLast,
            onAudioPressed: cell.onAudioPressed,
          ),
  );
}

/// A fully custom channel row that replaces the built-in cell.
class BasicCustomChannelRow extends StatelessWidget {
  const BasicCustomChannelRow({
    super.key,
    required this.channel,
    required this.onAudioPressed,
    this.isLast = false,
  });

  final LiveVoiceChannel channel;

  /// Toggles audio for this channel — provided by the SDK through the cell
  /// builder. Starts the channel if stopped, stops it if playing.
  final VoidCallback onAudioPressed;

  /// Last row in the list — drop the trailing gap so the cells sit flush in the section.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final playing = channel.playingState == LiveVoicePlayingState.playing;
    return GestureDetector(
      onTap: onAudioPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.liveSample,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _StatusText(channel: channel),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0x1F007AFF),
                shape: BoxShape.circle,
              ),
              child: Text(
                playing ? '■' : '▶',
                style: const TextStyle(color: Color(0xFF007AFF), fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A richer custom channel row that surfaces the channel's Booleans — isOnline as the status
/// dot, the rest as badges (solid when true, faint when false) — so you can see which values
/// you can read even when a feature doesn't apply. The row is tappable, and its play control
/// active, only when the channel can be started (online and with audio).
class DetailedCustomChannelRow extends StatelessWidget {
  const DetailedCustomChannelRow({
    super.key,
    required this.channel,
    required this.onAudioPressed,
    this.isLast = false,
  });

  final LiveVoiceChannel channel;

  /// Toggles audio for this channel — provided by the SDK through the cell
  /// builder. Starts the channel if stopped, stops it if playing.
  final VoidCallback onAudioPressed;

  /// Last row in the list — drop the trailing gap so the cells sit flush in the section.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final playing = channel.playingState == LiveVoicePlayingState.playing;
    // The channel can be started only when it is online and has audio.
    final canPlay = channel.isOnline && channel.hasAudio;
    final playColor = canPlay
        ? const Color(0xFF007AFF)
        : const Color(0xFF8E8E93);
    return GestureDetector(
      onTap: canPlay ? onAudioPressed : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.liveSample,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: channel.isOnline
                    ? const Color(0xFF34C759)
                    : const Color(0xFF8E8E93),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _StatusText(channel: channel),
                  const SizedBox(height: 8),
                  // isOnline is already conveyed by the status dot + status line above, so it's
                  // not repeated as a badge here.
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _BooleanBadge(label: 'Audio', isOn: channel.hasAudio),
                      _BooleanBadge(label: 'Subtitles', isOn: channel.hasSubtitles),
                      _BooleanBadge(label: 'Muted', isOn: channel.isAudioMuted),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Opacity(
              opacity: canPlay ? 1.0 : 0.4,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: playColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  playing ? '■' : '▶',
                  style: TextStyle(color: playColor, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pill for one Boolean property: full-contrast when true, faint when false, so every
/// readable value stays visible even when the feature doesn't apply.
class _BooleanBadge extends StatelessWidget {
  const _BooleanBadge({required this.label, required this.isOn});

  final String label;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final color = DemoTheme.of(context).text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: color.withValues(alpha: isOn ? 0.85 : 0.16),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          color: color.withValues(alpha: isOn ? 1.0 : 0.3),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// The channel's status line. The offline label is localized by the SDK, so it
/// is resolved asynchronously; online statuses are immediate.
class _StatusText extends StatelessWidget {
  const _StatusText({required this.channel});

  final LiveVoiceChannel channel;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final style = TextStyle(color: theme.secondaryText, fontSize: 12);

    if (!channel.isOnline) {
      return FutureBuilder<String>(
        future: translations.channelStatusOffline(),
        builder: (context, snapshot) => Text(snapshot.data ?? '', style: style),
      );
    }

    final ai = channel.aiTranslationInfo;
    final text = ai != null
        ? 'AI ${ai.targetLanguage}'
        : (channel.playingState == LiveVoicePlayingState.playing
              ? 'Currently playing'
              : 'Ready to start');
    return Text(text, style: style);
  }
}
