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
import 'demo_fixture.dart';
import 'demo_session.dart';

const String _logoLight = 'assets/logo.png';
const String _logoDark = 'assets/logo-dark.png';
const double _logoWidth = 129.5;
const double _logoHeight = _logoWidth / (129.5 / 88.7);

/// The LiveVoice logo. Uses the dark artwork variant in dark mode.
class LiveVoiceLogo extends StatelessWidget {
  const LiveVoiceLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Image.asset(
      theme.dark ? _logoDark : _logoLight,
      width: _logoWidth,
      height: _logoHeight,
      fit: BoxFit.contain,
    );
  }
}

/// The running LiveVoice SDK version, e.g. "SDK 2.0.0", shown under the logo.
class SdkVersionLabel extends StatefulWidget {
  const SdkVersionLabel({super.key});

  @override
  State<SdkVersionLabel> createState() => _SdkVersionLabelState();
}

class _SdkVersionLabelState extends State<SdkVersionLabel> {
  late final Future<String> _version = getSdkVersion();

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return FutureBuilder<String>(
      future: _version,
      builder: (context, snapshot) {
        final version = snapshot.data;
        if (version == null) return const SizedBox.shrink();
        return Text(
          'SDK $version',
          style: TextStyle(color: theme.secondaryText, fontSize: 13),
        );
      },
    );
  }
}

/// A stamped "Flutter" pill in the Flutter brand color.
class PlatformBadge extends StatelessWidget {
  const PlatformBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF027DFD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Flutter',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A grouped-list section header above a [DemoListSection].
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.secondaryText,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The rounded card that wraps a group of [DemoListRow]s.
class DemoListSection extends StatelessWidget {
  const DemoListSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// A single tappable row inside a [DemoListSection].
class DemoListRow extends StatelessWidget {
  const DemoListRow({
    super.key,
    required this.title,
    required this.summary,
    required this.showDivider,
    required this.onTap,
  });

  final String title;
  final String summary;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          splashColor: theme.separator,
          highlightColor: theme.separator,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary,
                        style: TextStyle(
                          color: theme.secondaryText,
                          fontSize: 14,
                          height: 19 / 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '›',
                  style: TextStyle(
                    color: theme.chevron,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Divider(height: 0.5, thickness: 0.5, color: theme.separator),
          ),
      ],
    );
  }
}

/// Button + popover menu for switching the active API key preset. Available
/// from the home screen and every demo screen's app bar.
class DemoApiKeyMenu extends StatelessWidget {
  const DemoApiKeyMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final session = DemoSessionScope.of(context);

    return TextButton(
      onPressed: () => _showMenu(context, session, theme),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'API key',
            style: TextStyle(
              color: theme.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 2),
          Text('▾', style: TextStyle(color: theme.text, fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _showMenu(
    BuildContext context,
    DemoSession session,
    DemoTheme theme,
  ) async {
    final result = await showDialog<_ApiKeyMenuResult>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _ApiKeyMenuDialog(session: session, theme: theme),
    );
    if (result == null) return;
    switch (result) {
      case _SelectPreset(:final preset):
        session.select(preset);
      case _EditCustomCredentials():
        if (!context.mounted) return;
        await _showCustomCredentialsEditor(context, session, theme);
    }
  }

  Future<void> _showCustomCredentialsEditor(
    BuildContext context,
    DemoSession session,
    DemoTheme theme,
  ) async {
    final credentials = await showDialog<DemoCredentials>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _CustomCredentialsDialog(
        initial: session.customCredentials,
        theme: theme,
      ),
    );
    if (credentials != null) {
      await session.applyCustomCredentials(credentials);
    }
  }
}

/// Result of the API key menu: either a built-in preset was tapped, or the
/// "Use your own event" row was tapped (which opens the credentials editor).
sealed class _ApiKeyMenuResult {
  const _ApiKeyMenuResult();
}

class _SelectPreset extends _ApiKeyMenuResult {
  const _SelectPreset(this.preset);
  final DemoApiKeyPreset preset;
}

class _EditCustomCredentials extends _ApiKeyMenuResult {
  const _EditCustomCredentials();
}

class _ApiKeyMenuDialog extends StatelessWidget {
  const _ApiKeyMenuDialog({required this.session, required this.theme});

  final DemoSession session;
  final DemoTheme theme;

  @override
  Widget build(BuildContext context) {
    final presets = session.presets;
    return Dialog(
      backgroundColor: theme.popover,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.popoverBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: presets.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 0.5, thickness: 0.5, color: theme.separator),
              itemBuilder: (context, index) {
                final preset = presets[index];
                final selected = preset.id == session.selectedPreset.id;
                return InkWell(
                  onTap: () => Navigator.of(context).pop(_SelectPreset(preset)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preset.title,
                                style: TextStyle(
                                  color: theme.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                preset.summary,
                                style: TextStyle(
                                  color: theme.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 12),
                          Text(
                            '✓',
                            style: TextStyle(
                              color: theme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 0.5, thickness: 0.5, color: theme.separator),
          InkWell(
            onTap: () =>
                Navigator.of(context).pop(const _EditCustomCredentials()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use your own event',
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.customCredentials != null
                              ? 'Join code ${session.customCredentials!.joinCode} · tap to edit.'
                              : 'Enter your own join code and API key.',
                          style: TextStyle(
                            color: theme.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (session.selectedPreset.id == DemoFixture.customPresetId) ...[
                    const SizedBox(width: 12),
                    Text(
                      '✓',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal editor for the "Use your own event" credentials. Lets a tester join
/// their own LiveVoice event with their own join code + API key (and optional
/// password) without rebuilding the sample.
class _CustomCredentialsDialog extends StatefulWidget {
  const _CustomCredentialsDialog({required this.initial, required this.theme});

  final DemoCredentials? initial;
  final DemoTheme theme;

  @override
  State<_CustomCredentialsDialog> createState() =>
      _CustomCredentialsDialogState();
}

class _CustomCredentialsDialogState extends State<_CustomCredentialsDialog> {
  late final TextEditingController _joinCode;
  late final TextEditingController _apiKey;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _joinCode = TextEditingController(text: widget.initial?.joinCode ?? '');
    _apiKey = TextEditingController(text: widget.initial?.apiKey ?? '');
    _password = TextEditingController(text: widget.initial?.password ?? '');
    for (final c in [_joinCode, _apiKey]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _joinCode.dispose();
    _apiKey.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canUse =>
      _joinCode.text.trim().isNotEmpty && _apiKey.text.trim().isNotEmpty;

  void _use() {
    Navigator.of(context).pop(
      DemoCredentials(
        joinCode: _joinCode.text.trim(),
        password: _password.text,
        apiKey: _apiKey.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return AlertDialog(
      backgroundColor: theme.popover,
      title: Text('Use your own event', style: TextStyle(color: theme.text)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the join code and API key for your own LiveVoice event. '
              'The password is only needed for password-protected events.',
              style: TextStyle(color: theme.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _joinCode,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Join code'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKey,
              decoration: const InputDecoration(labelText: 'API key'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (optional)',
              ),
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
          onPressed: _canUse ? _use : null,
          child: const Text('Use'),
        ),
      ],
    );
  }
}
