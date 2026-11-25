// Demo scaffolding — not needed for an integration.
// The toolbar's event picker: the demo API keys, your own event's
// credentials, and the sheets that pick them.

import 'package:flutter/material.dart';

import 'demo_fixture.dart';
import 'demo_session.dart';
import 'demo_theme.dart';

/// The toolbar button that opens the picker.
class DemoApiKeyMenu extends StatelessWidget {
  const DemoApiKeyMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return TextButton(
      onPressed: () => showDemoApiKeyPicker(context),
      style: TextButton.styleFrom(foregroundColor: theme.accent),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'API key',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Icon(Icons.expand_more, size: 20),
        ],
      ),
    );
  }
}

/// Shows the demo event's API keys and "Use your own event".
Future<void> showDemoApiKeyPicker(BuildContext context) async {
  final session = DemoSessionScope.read(context);
  final editCustom = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    backgroundColor: DemoTheme.of(context).card,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: ListenableBuilder(
          listenable: session,
          builder: (context, _) {
            final credentials = session.customCredentials;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DemoApiKeyPresetList(
                  onSelect: () => Navigator.of(context).pop(false),
                ),
                const Divider(height: 1),
                _PickerRow(
                  title: 'Use your own event',
                  summary: credentials == null
                      ? 'Enter your own join code and API key.'
                      : 'Join code ${credentials.joinCode} · tap to edit.',
                  isSelected: session.usesOwnEvent,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  if (editCustom == true && context.mounted) {
    await showDemoCustomCredentialsEditor(context);
  }
}

/// Lets a tester join their own LiveVoice event with their own join code and
/// API key (and an optional password) without rebuilding the sample.
Future<void> showDemoCustomCredentialsEditor(BuildContext context) async {
  final session = DemoSessionScope.read(context);
  final credentials = await showDialog<DemoCredentials>(
    context: context,
    builder: (context) =>
        _CustomCredentialsEditor(initial: session.customCredentials),
  );
  if (credentials != null) await session.applyCustomCredentials(credentials);
}

/// The demo event's three API keys, each with what it permits; tapping one
/// joins the demo event with it.
class DemoApiKeyPresetList extends StatelessWidget {
  const DemoApiKeyPresetList({super.key, this.onSelect});

  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final session = DemoSessionScope.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, preset) in DemoFixture.apiKeyPresets.indexed) ...[
          if (index > 0) const Divider(height: 1),
          _PickerRow(
            title: preset.title,
            summary: preset.summary,
            isSelected: session.selectedPreset.id == preset.id,
            onTap: () {
              session.select(preset);
              onSelect?.call();
            },
          ),
        ],
      ],
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.title,
    required this.summary,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String summary;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary,
                      style: TextStyle(
                        color: theme.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: isSelected ? 1 : 0,
                child: Icon(Icons.check, size: 18, color: theme.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomCredentialsEditor extends StatefulWidget {
  const _CustomCredentialsEditor({required this.initial});

  final DemoCredentials? initial;

  @override
  State<_CustomCredentialsEditor> createState() =>
      _CustomCredentialsEditorState();
}

class _CustomCredentialsEditorState extends State<_CustomCredentialsEditor> {
  late final _joinCode = TextEditingController(text: widget.initial?.joinCode);
  late final _apiKey = TextEditingController(text: widget.initial?.apiKey);
  late final _password = TextEditingController(text: widget.initial?.password);

  @override
  void dispose() {
    _joinCode.dispose();
    _apiKey.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canUse =>
      _joinCode.text.trim().isNotEmpty && _apiKey.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return AlertDialog(
      backgroundColor: theme.card,
      title: const Text('Use your own event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _joinCode,
              // Join codes have digits and letters, in any case.
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Join code'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _apiKey,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'API key'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (optional)',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter the join code and API key for your own LiveVoice event. '
              'The password is only needed for password-protected events.',
              style: TextStyle(color: theme.secondaryText, fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _canUse
              ? () => Navigator.of(context).pop(
                  DemoCredentials(
                    joinCode: _joinCode.text.trim(),
                    password: _password.text,
                    apiKey: _apiKey.text.trim(),
                  ),
                )
              : null,
          child: const Text('Use'),
        ),
      ],
    );
  }
}
