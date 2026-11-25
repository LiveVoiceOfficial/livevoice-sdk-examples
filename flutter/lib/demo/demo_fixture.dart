// Demo scaffolding — not needed for an integration.
// The demo event's join code, its three API keys, and your own event's credentials.

/// An event and API key the toolbar's picker can join.
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

/// User-entered credentials for the "Use your own event" picker option.
/// Persisted so the editor pre-fills on reopen; see `DemoSession`.
class DemoCredentials {
  const DemoCredentials({
    required this.joinCode,
    required this.password,
    required this.apiKey,
  });

  final String joinCode;

  /// Empty means "no password"; some events are password-protected.
  final String password;
  final String apiKey;
}

abstract final class DemoFixture {
  static const String joinCode = '123456';
  static const String? password = null;

  /// Identifies the "Use your own event" selection (built from user-entered
  /// [DemoCredentials], not part of [apiKeyPresets]).
  static const String customPresetId = 'custom';

  static const DemoApiKeyPreset defaultPreset = DemoApiKeyPreset(
    id: 'default',
    title: 'Default',
    summary: 'Branding visible, custom UI disabled.',
    joinCode: joinCode,
    password: password,
    apiKey: 'HD4cQklUOQKOBWimG54j2kRnxFklDL',
  );

  static const DemoApiKeyPreset hideBrandingPreset = DemoApiKeyPreset(
    id: 'hide-branding',
    title: 'Hide branding',
    summary: 'Branding hidden, custom UI disabled.',
    joinCode: joinCode,
    password: password,
    apiKey: 'uFlkcGkUJEcb7jK6qFcdygreFRTXVh',
  );

  static const DemoApiKeyPreset fullCustomizationPreset = DemoApiKeyPreset(
    id: 'full-customization',
    title: 'Full customization',
    summary: 'Branding hidden, custom UI enabled.',
    joinCode: joinCode,
    password: password,
    apiKey: 's09WEG5y3caQ6R2PDaG4i8R1aTooTd',
  );

  static const List<DemoApiKeyPreset> apiKeyPresets = [
    defaultPreset,
    hideBrandingPreset,
    fullCustomizationPreset,
  ];

  /// The preset selected when a tester enters their own event's
  /// credentials. An empty password is treated as "no password".
  static DemoApiKeyPreset customPreset(DemoCredentials credentials) =>
      DemoApiKeyPreset(
        id: customPresetId,
        title: 'Your own event',
        summary: 'Join code ${credentials.joinCode} with your own API key.',
        joinCode: credentials.joinCode,
        password: credentials.password.isEmpty ? null : credentials.password,
        apiKey: credentials.apiKey,
      );
}
