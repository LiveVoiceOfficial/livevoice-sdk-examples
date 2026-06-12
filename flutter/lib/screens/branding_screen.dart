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

import '../shared/custom_channel_views.dart';
import '../shared/demo_components.dart';
import '../shared/demo_fixture.dart';
import '../shared/demo_session.dart';
import '../theme.dart';

class BrandingScreen extends StatefulWidget {
  const BrandingScreen({super.key});

  @override
  State<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends State<BrandingScreen> {
  int? _primaryChannelId;
  DemoApiKeyPreset? _lastPreset;

  // The live authorization features reported by the SDK for the joined key.
  // Seeded from getCurrentFeatures() and kept current via onFeaturesChanged, so
  // switching the API key preset updates these in place.
  LiveVoiceFeatures _features = const LiveVoiceFeatures(
    customUiAllowed: false,
    hideBranding: false,
  );
  StreamSubscription<LiveVoiceFeatures>? _featuresSubscription;

  @override
  void initState() {
    super.initState();
    _seedFeatures();
    _featuresSubscription = onFeaturesChanged.listen((features) {
      if (mounted) setState(() => _features = features);
    });
  }

  Future<void> _seedFeatures() async {
    final features = await getCurrentFeatures();
    if (mounted) setState(() => _features = features);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final preset = DemoSessionScope.of(context).selectedPreset;
    if (preset.joinCode != _lastPreset?.joinCode ||
        preset.apiKey != _lastPreset?.apiKey) {
      _lastPreset = preset;
      _primaryChannelId = null;
    }
  }

  @override
  void dispose() {
    unawaited(_featuresSubscription?.cancel());
    super.dispose();
  }

  bool _primaryFilter(LiveVoiceChannel channel) {
    _primaryChannelId ??= channel.id;
    return channel.id == _primaryChannelId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final preset = DemoSessionScope.of(context).selectedPreset;

    return DemoScreen(
      title: 'Branding and entitlements',
      summary:
          'Switch the preset API key from the toolbar to inspect the real '
          'branding and custom UI permissions for this demo event.',
      children: [
        DemoCardSection(
          title: 'Live sample',
          children: [
            Text(
              'Standard view',
              style: TextStyle(
                color: theme.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            DemoDefaultLiveVoiceView(
              child: LiveVoiceView(filter: _primaryFilter),
            ),
            Text(
              'Custom row',
              style: TextStyle(
                color: theme.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            CustomChannelList(filter: _primaryFilter),
          ],
        ),
        DemoCardSection(
          title: 'Current features',
          children: [
            _EntitlementRow(label: 'Selected preset', value: preset.title),
            _EntitlementRow(
              label: 'Branding',
              value: _features.hideBranding ? 'Hidden' : 'Visible',
            ),
            _EntitlementRow(
              label: 'Custom UI',
              value: _features.customUiAllowed ? 'Allowed' : 'Not allowed',
            ),
          ],
        ),
        const DemoCardSection(
          title: 'Implementation notes',
          children: [
            DemoNotes(
              notes: [
                "Both samples above show only the event's first channel.",
                'Switch the API key preset from the toolbar to compare branding and custom UI entitlements for that same channel.',
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _EntitlementRow extends StatelessWidget {
  const _EntitlementRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.secondaryText, fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            color: theme.text,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
