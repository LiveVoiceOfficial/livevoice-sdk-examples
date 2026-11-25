// Branding and entitlements
//
// What an API key may do is set for your account. `hideBranding` says
// whether LiveVoiceView leaves out the LiveVoice logo, `customUiAllowed`
// whether you may replace its parts with your own. The SDK enforces both;
// read them only to adapt your own UI. Both are `false` until an event is
// joined.
//
// In Flutter, both come together in `features`, one ValueListenable of
// LiveVoiceFeatures; they are `false` again as soon as a new join starts.
//
// Uses: features, LiveVoiceFeatures.hideBranding, customUiAllowed
// See also: Custom channel cell, Custom view states (the parts custom UI
// allows).

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_event_picker.dart';
import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';

class BrandingScreen extends StatelessWidget {
  const BrandingScreen({super.key});

  @override
  Widget build(BuildContext context) => DemoScreen(
    title: 'Branding and entitlements',
    caption: "See what the joined event's API key permits.",
    children: [
      ValueListenableBuilder<LiveVoiceFeatures>(
        valueListenable: features,
        builder: (context, features, _) => DemoSection(
          'This API key',
          children: [
            DemoValueRow(
              'Branding',
              value: features.hideBranding ? 'Hidden' : 'Shown',
            ),
            DemoValueRow(
              'Custom UI',
              value: features.customUiAllowed ? 'Allowed' : 'Not allowed',
            ),
          ],
        ),
      ),
      // The demo event's three keys: branding shown and no custom UI,
      // branding hidden and no custom UI, branding hidden and custom UI.
      const DemoSection('Demo API keys', children: [DemoApiKeyPresetList()]),
      // Shows or hides the branding by itself.
      const DemoSection('Channels', children: [LiveVoiceView()]),
    ],
  );
}
