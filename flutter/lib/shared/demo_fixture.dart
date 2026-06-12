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

/// A selectable API key configuration shown in the home/demo API key menu.
class DemoApiKeyPreset {
  const DemoApiKeyPreset({
    required this.id,
    required this.title,
    required this.summary,
    required this.joinCode,
    required this.password,
    required this.apiKey,
  });

  final String id;
  final String title;
  final String summary;
  final String joinCode;
  final String? password;
  final String apiKey;
}

/// User-entered credentials for the "Use your own event" picker option. Persisted
/// so the editor pre-fills on reopen; see `DemoSession`.
class DemoCredentials {
  const DemoCredentials({
    required this.joinCode,
    required this.password,
    required this.apiKey,
  });

  final String joinCode;

  /// Empty string means "no password"; some events are password-protected.
  final String password;
  final String apiKey;
}

const DemoApiKeyPreset _defaultPreset = DemoApiKeyPreset(
  id: 'default',
  title: 'Default',
  summary: 'Branding visible, custom UI disabled.',
  joinCode: DemoFixture.joinCode,
  password: DemoFixture.password,
  apiKey: 'HD4cQklUOQKOBWimG54j2kRnxFklDL',
);

const DemoApiKeyPreset _hideBrandingPreset = DemoApiKeyPreset(
  id: 'hide-branding',
  title: 'Hide branding',
  summary: 'Branding hidden, custom UI disabled.',
  joinCode: DemoFixture.joinCode,
  password: DemoFixture.password,
  apiKey: 'uFlkcGkUJEcb7jK6qFcdygreFRTXVh',
);

const DemoApiKeyPreset _fullCustomizationPreset = DemoApiKeyPreset(
  id: 'full-customization',
  title: 'Full customization',
  summary: 'Branding hidden, custom UI enabled.',
  joinCode: DemoFixture.joinCode,
  password: DemoFixture.password,
  apiKey: 's09WEG5y3caQ6R2PDaG4i8R1aTooTd',
);

/// Shared connection details and API key presets for the sample.
abstract final class DemoFixture {
  static const String joinCode = '123456';
  static const String? password = null;

  /// Identifies the dynamic "Use your own event" selection (built from
  /// user-entered [DemoCredentials], not part of [apiKeyPresets]).
  static const String customPresetId = 'custom';

  static const List<DemoApiKeyPreset> apiKeyPresets = [
    _defaultPreset,
    _hideBrandingPreset,
    _fullCustomizationPreset,
  ];
  static const DemoApiKeyPreset defaultPreset = _defaultPreset;

  /// Builds the dynamic preset selected when a tester enters their own event
  /// credentials. An empty password is treated as "no password".
  static DemoApiKeyPreset customPreset(DemoCredentials credentials) {
    return DemoApiKeyPreset(
      id: customPresetId,
      title: 'Your own event',
      summary: 'Join code ${credentials.joinCode} with your own API key.',
      joinCode: credentials.joinCode,
      password: credentials.password.isEmpty ? null : credentials.password,
      apiKey: credentials.apiKey,
    );
  }
}
