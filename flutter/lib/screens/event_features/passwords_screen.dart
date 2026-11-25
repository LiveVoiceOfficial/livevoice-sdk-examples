// Password-protected channels
//
// A protected channel needs its password when it starts. Without any setup,
// the SDK asks with its own prompt and remembers the password until the app
// quits. `setPasswordProvider` asks with your own UI instead, and
// `setPasswordStore` keeps passwords longer: the SDK asks the store first,
// saves a password the server accepted and removes one it rejected.
//
// In Flutter, the provider is an async function that returns the password
// or `null`, so a modal route that pops with the answer is all it needs:
// each request gets its own sheet and its own answer. The SDK's own prompt
// shows on the most recently shown LiveVoiceView still on screen; with no
// LiveVoiceView on screen, a start that needs a password fails with its
// password error. Your store extends LiveVoicePasswordStore and gets
// `save(subject, password)`, the subject first.
//
// Needs: your own event with a password on a channel.
// Uses: setPasswordProvider(), setPasswordStore(), LiveVoicePasswordStore,
// LiveVoicePasswordRequest, LiveVoicePasswordSubject
// See also: Subtitles (a protected channel's subtitles use the same password).

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';
import '../../demo/demo_session.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({super.key});

  @override
  State<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  final _store = _MemoryPasswordStore();

  // A real app sets both once, at launch. This screen sets them only while
  // it shows, so the other screens keep the SDK's own prompt.
  @override
  void initState() {
    super.initState();
    setPasswordProvider(_ask);
    setPasswordStore(_store);
  }

  @override
  void dispose() {
    setPasswordProvider(null);
    // The store isn't disposed: an operation still running may save to it.
    setPasswordStore(null);
    super.dispose();
  }

  /// The provider: returns the password, or `null` to give up, which fails
  /// the start with `channelPasswordRequired`.
  Future<String?> _ask(LiveVoicePasswordRequest request) async {
    if (!mounted) return null;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      // It closes only through Cancel or Listen, or the back button, which
      // gives up like Cancel, so every request gets its answer.
      isDismissible: false,
      enableDrag: false,
      builder: (context) => _PasswordPrompt(request: request),
    );
  }

  @override
  Widget build(BuildContext context) => DemoScreen(
    title: 'Password-protected channels',
    caption: 'Ask for channel passwords with your own UI, and keep them.',
    children: [
      // The SDK lists an event's channels only in LiveVoiceView, so the note
      // can only tell the demo event apart.
      DemoRequirement.ownEvent(
        'Password-protected channels',
        isMet: DemoSessionScope.of(context).usesOwnEvent,
      ),
      const DemoSection(
        'Channels',
        children: [
          // The SDK keeps an accepted password in memory for the app's run
          // and forgets one only when the server rejects it. Starting a
          // protected channel looks in memory, then asks the store, then the
          // provider.
          DemoNote.info(
            "Once a password is accepted, the SDK remembers it until the app quits and won't ask again. Restart the app to see the prompt again.",
          ),
          LiveVoiceView(),
        ],
      ),
      DemoSection(
        'Saved passwords',
        children: [
          ListenableBuilder(
            listenable: _store,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_store.passwords.isEmpty)
                  const DemoPlaceholder('None yet: play a protected channel.'),
                for (final subject in _store.passwords.keys)
                  Text(_describe(subject)),
              ],
            ),
          ),
        ],
      ),
    ],
  );

  String _describe(LiveVoicePasswordSubject subject) => switch (subject) {
    LiveVoicePasswordSubjectChannel(:final joinCode, :final channelId) =>
      'Channel $channelId of event $joinCode',
    LiveVoicePasswordSubjectEvent(:final joinCode) => 'Event $joinCode',
  };
}

/// Your own password prompt. `isRetry` is `true` after a rejected password.
/// It pops with the password, or with `null` for Cancel.
class _PasswordPrompt extends StatefulWidget {
  const _PasswordPrompt({required this.request});

  final LiveVoicePasswordRequest request;

  @override
  State<_PasswordPrompt> createState() => _PasswordPromptState();
}

class _PasswordPromptState extends State<_PasswordPrompt> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    // Above the keyboard.
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Password', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: widget.request.isRetry
                ? 'Wrong password. Try again.'
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _password.text.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(_password.text),
              child: const Text('Listen'),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Keeps passwords in memory, keyed by what they belong to. A real app keeps
/// them securely, for example in the Keychain or the Android Keystore, so
/// they outlive the app. Storing is best effort: an error you throw is logged
/// and fails nothing.
class _MemoryPasswordStore extends LiveVoicePasswordStore with ChangeNotifier {
  final Map<LiveVoicePasswordSubject, String> passwords = {};

  @override
  Future<String?> load(LiveVoicePasswordSubject subject) async =>
      passwords[subject];

  @override
  Future<void> save(LiveVoicePasswordSubject subject, String password) async {
    passwords[subject] = password;
    notifyListeners();
  }

  @override
  Future<void> remove(LiveVoicePasswordSubject subject) async {
    passwords.remove(subject);
    notifyListeners();
  }
}
