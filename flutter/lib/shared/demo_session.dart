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

import 'package:flutter/widgets.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart' as livevoice;
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_fixture.dart';

/// Owns the currently selected API key preset and (re)joins the demo event
/// whenever it changes.
class DemoSession extends ChangeNotifier {
  DemoSession({DemoApiKeyPreset? selectedPreset, bool joinOnInit = true})
    : _selectedPreset = selectedPreset ?? DemoFixture.defaultPreset {
    if (joinOnInit) {
      _joinSelectedPreset();
    }
  }

  static const _kJoinCode = 'demo_custom_join_code';
  static const _kPassword = 'demo_custom_password';
  static const _kApiKey = 'demo_custom_api_key';

  DemoApiKeyPreset _selectedPreset;
  DemoApiKeyPreset get selectedPreset => _selectedPreset;

  // Last credentials a tester entered via "Use your own event".
  DemoCredentials? _customCredentials;
  DemoCredentials? get customCredentials => _customCredentials;

  List<DemoApiKeyPreset> get presets => DemoFixture.apiKeyPresets;

  void select(DemoApiKeyPreset preset) {
    if (preset.id == _selectedPreset.id) return;
    _selectedPreset = preset;
    notifyListeners();
    _joinSelectedPreset();
  }

  /// Loads any saved custom credentials so the editor pre-fills. Does not change
  /// the selected preset — a fresh launch stays on the default preset.
  Future<void> restoreCustomCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final joinCode = prefs.getString(_kJoinCode);
    final apiKey = prefs.getString(_kApiKey);
    if (joinCode == null || apiKey == null) return;
    _customCredentials = DemoCredentials(
      joinCode: joinCode,
      password: prefs.getString(_kPassword) ?? '',
      apiKey: apiKey,
    );
    notifyListeners();
  }

  /// Applies credentials entered in the editor: persists them, selects the
  /// custom event, and (re)joins. An empty password means "no password".
  Future<void> applyCustomCredentials(DemoCredentials credentials) async {
    _customCredentials = credentials;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kJoinCode, credentials.joinCode);
    await prefs.setString(_kPassword, credentials.password);
    await prefs.setString(_kApiKey, credentials.apiKey);

    _selectedPreset = DemoFixture.customPreset(credentials);
    notifyListeners();
    _joinSelectedPreset();
  }

  void _joinSelectedPreset() {
    livevoice.joinEvent(
      joinCode: _selectedPreset.joinCode,
      password: _selectedPreset.password,
      apiKey: _selectedPreset.apiKey,
    );
  }
}

/// Exposes the [DemoSession] to the widget tree and rebuilds dependents when
/// the selected preset changes.
class DemoSessionScope extends InheritedNotifier<DemoSession> {
  const DemoSessionScope({
    super.key,
    required DemoSession session,
    required super.child,
  }) : super(notifier: session);

  static DemoSession of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DemoSessionScope>();
    assert(scope != null, 'No DemoSessionScope found in context');
    return scope!.notifier!;
  }
}
