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

/// Subscribes to the SDK's audio output and rebuilds [builder] with the current value, so every
/// control below stays in sync without managing its own subscription.
class _AudioOutputBuilder extends StatefulWidget {
  const _AudioOutputBuilder({required this.builder});

  final Widget Function(BuildContext context, bool useSpeaker) builder;

  @override
  State<_AudioOutputBuilder> createState() => _AudioOutputBuilderState();
}

class _AudioOutputBuilderState extends State<_AudioOutputBuilder> {
  bool _useSpeaker = false;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  Future<void> _listen() async {
    try {
      final current = await getCurrentAudioState();
      if (mounted) setState(() => _useSpeaker = current);
    } catch (_) {}
    _subscription = onAudioOutputChanged.listen((value) {
      if (mounted) setState(() => _useSpeaker = value);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _useSpeaker);
}

/// The compact output control: an icon-only segmented picker kept narrow so it can sit above a list.
class CompactAudioOutputPicker extends StatelessWidget {
  const CompactAudioOutputPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return _AudioOutputBuilder(
      builder: (context, useSpeaker) => SegmentedButton<bool>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: const [
          ButtonSegment(value: false, icon: Icon(Icons.headset)),
          ButtonSegment(value: true, icon: Icon(Icons.volume_up)),
        ],
        selected: {useSpeaker},
        onSelectionChanged: (selection) =>
            setLiveVoiceUseSpeaker(selection.first),
      ),
    );
  }
}

/// A pop-up menu variant: a field that opens a menu listing the outputs.
class MenuAudioOutputPicker extends StatelessWidget {
  const MenuAudioOutputPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return _AudioOutputBuilder(
      builder: (context, useSpeaker) => DemoMenuPicker(
        selectedLabel: useSpeaker ? 'Speaker' : 'Receiver',
        selectedId: useSpeaker ? 1 : 0,
        onSelect: (id) => setLiveVoiceUseSpeaker(id == 1),
        options: [
          DemoMenuOption(id: 0, title: 'Receiver'),
          DemoMenuOption(id: 1, title: 'Speaker'),
        ],
      ),
    );
  }
}

/// A single button that toggles straight between the two outputs.
class ToggleAudioOutputButton extends StatelessWidget {
  const ToggleAudioOutputButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _AudioOutputBuilder(
      builder: (context, useSpeaker) => OutlinedButton.icon(
        onPressed: () => setLiveVoiceUseSpeaker(!useSpeaker),
        icon: Icon(useSpeaker ? Icons.volume_up : Icons.headset),
        label: Text(useSpeaker ? 'Speaker' : 'Receiver'),
      ),
    );
  }
}

/// An "Audio output" label paired with the compact picker — placed above channel lists.
class AudioOutputRow extends StatelessWidget {
  const AudioOutputRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Audio output',
          style: TextStyle(color: theme.secondaryText, fontSize: 14),
        ),
        const CompactAudioOutputPicker(),
      ],
    );
  }
}
