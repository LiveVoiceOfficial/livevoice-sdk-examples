// Demo scaffolding — not needed for an integration.
// Joins the event picked in the toolbar at launch and whenever the pick
// changes, and remembers what the app last passed to `initialize`.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_fixture.dart';

class DemoSession extends ChangeNotifier {
  DemoSession({required DemoAudioSettings audioSettings})
    : _audioSettings = audioSettings {
    unawaited(_restoreCustomCredentials());
    _joinSelectedPreset();
  }

  static const _joinCodeKey = 'demo_custom_join_code';
  static const _passwordKey = 'demo_custom_password';
  static const _apiKeyKey = 'demo_custom_api_key';

  DemoApiKeyPreset _selectedPreset = DemoFixture.defaultPreset;
  DemoApiKeyPreset get selectedPreset => _selectedPreset;

  /// The last credentials a tester entered via "Use your own event".
  DemoCredentials? _customCredentials;
  DemoCredentials? get customCredentials => _customCredentials;

  /// Whether the picked event is your own rather than the demo event.
  bool get usesOwnEvent => _selectedPreset.id == DemoFixture.customPresetId;

  /// What the app last passed to `initialize`. The SDK has no getter for
  /// it, so the app keeps it, and saves it so that `main` initializes with
  /// the same values after a hot restart (see DemoAudioSettings).
  DemoAudioSettings _audioSettings;
  DemoAudioSettings get audioSettings => _audioSettings;

  Future<void> rememberAudioSettings(DemoAudioSettings settings) async {
    _audioSettings = settings;
    notifyListeners();
    await settings._save();
  }

  void select(DemoApiKeyPreset preset) {
    if (preset.id == _selectedPreset.id) return;
    _selectedPreset = preset;
    notifyListeners();
    _joinSelectedPreset();
  }

  /// Applies credentials entered in the editor: saves them, selects your
  /// own event and joins it. An empty password means "no password".
  Future<void> applyCustomCredentials(DemoCredentials credentials) async {
    _customCredentials = credentials;
    _selectedPreset = DemoFixture.customPreset(credentials);
    notifyListeners();
    _joinSelectedPreset();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_joinCodeKey, credentials.joinCode);
    await prefs.setString(_passwordKey, credentials.password);
    await prefs.setString(_apiKeyKey, credentials.apiKey);
  }

  /// Loads saved credentials so the editor pre-fills. A launch still joins
  /// the demo event.
  Future<void> _restoreCustomCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final joinCode = prefs.getString(_joinCodeKey);
    final apiKey = prefs.getString(_apiKeyKey);
    if (joinCode == null || apiKey == null) return;
    _customCredentials = DemoCredentials(
      joinCode: joinCode,
      password: prefs.getString(_passwordKey) ?? '',
      apiKey: apiKey,
    );
    notifyListeners();
  }

  void _joinSelectedPreset() {
    final preset = _selectedPreset;
    // A newer join replaces this one, which then fails with `superseded`.
    unawaited(
      joinEvent(
        joinCode: preset.joinCode,
        password: preset.password,
        apiKey: preset.apiKey,
      ).then<void>(
        (_) {},
        onError: (Object error) {
          // LiveVoiceView shows connection failures. Never log credentials.
          if (error is LiveVoiceException &&
              (error.code == LiveVoiceErrorCode.cancelled ||
                  error.code == LiveVoiceErrorCode.superseded)) {
            return;
          }
          debugPrint(
            'LiveVoice join failed: '
            '${error is LiveVoiceException ? error.code.value : error}',
          );
        },
      ),
    );
  }
}

/// The audio settings `initialize` takes, which only another `initialize`
/// changes. Saved, because a hot restart runs `main` again while the native
/// SDK keeps its event and configuration: an `initialize` with other values
/// then fails with `invalidArgument`.
@immutable
class DemoAudioSettings {
  const DemoAudioSettings({
    required this.audioFocus,
    required this.showsSystemMediaControls,
  });

  /// The SDK's defaults.
  static const DemoAudioSettings defaults = DemoAudioSettings(
    audioFocus: LiveVoiceAudioFocus.exclusive,
    showsSystemMediaControls: true,
  );

  final LiveVoiceAudioFocus audioFocus;
  final bool showsSystemMediaControls;

  static const _audioFocusKey = 'demo_audio_focus';
  static const _systemMediaControlsKey = 'demo_shows_system_media_controls';

  static Future<DemoAudioSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final focus = LiveVoiceAudioFocus.values
        .asNameMap()[prefs.getString(_audioFocusKey)];
    return DemoAudioSettings(
      audioFocus: focus ?? defaults.audioFocus,
      showsSystemMediaControls:
          prefs.getBool(_systemMediaControlsKey) ??
          defaults.showsSystemMediaControls,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_audioFocusKey, audioFocus.name);
    await prefs.setBool(_systemMediaControlsKey, showsSystemMediaControls);
  }
}

/// Hands the [DemoSession] to the widget tree and rebuilds dependents when
/// it changes.
class DemoSessionScope extends InheritedNotifier<DemoSession> {
  const DemoSessionScope({
    super.key,
    required DemoSession session,
    required super.child,
  }) : super(notifier: session);

  static DemoSession of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DemoSessionScope>()!.notifier!;

  /// The session, without rebuilding when it changes: for callbacks.
  static DemoSession read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DemoSessionScope>()!.notifier!;
}
