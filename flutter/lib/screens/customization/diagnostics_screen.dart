// Diagnostics log
//
// The SDK reports what it does as named events, such as `LV_JOIN_RESULT` or
// `LV_CHANNEL_RESULT`, each with a level and a few fields; a failure carries
// its error `code`. They go to the system log, and `logEntries` hands them
// to your own logging. Tap a channel to see some.
//
// In Flutter, `logEntries` is a broadcast stream instead of a single
// listener: any number of listeners, each receiving the entries logged while
// it listens, without replay. Entries start with `initialize`, so listen
// before it to see them all, and cancel the subscription in `dispose`. It
// also carries the Flutter package's own entries, such as `LV_USAGE_ERROR`,
// which explains an `invalidArgument`. The `[LiveVoiceSDK]` lines on the
// debug console are not part of it.
//
// Uses: logEntries, LiveVoiceLogEntry, LiveVoiceLogLevel
// See also: Joining an event, Localization and accessibility (error
// messages).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';
import '../../demo/demo_theme.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  /// The latest entries, newest first.
  final List<LiveVoiceLogEntry> _entries = [];
  late final StreamSubscription<LiveVoiceLogEntry> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = logEntries.listen((entry) {
      setState(() {
        _entries.insert(0, entry);
        if (_entries.length > 100) _entries.removeLast();
      });
    });
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoScreen(
    title: 'Diagnostics log',
    caption: 'Read what the SDK did, and why a call failed.',
    children: [
      const DemoSection('Channels', children: [LiveVoiceView()]),
      DemoSection(
        'Log',
        children: [
          if (_entries.isEmpty)
            const DemoPlaceholder('Nothing logged yet: tap a channel.'),
          for (final entry in _entries) _LogEntryRow(entry: entry),
        ],
      ),
    ],
  );
}

/// One entry: its event, level, time and fields. Entries never contain a
/// password or an API key.
class _LogEntryRow extends StatelessWidget {
  const _LogEntryRow({required this.entry});

  final LiveVoiceLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    const monospace = ['Menlo', 'Courier'];
    final isError = switch (entry.level) {
      LiveVoiceLogLevel.info => false,
      LiveVoiceLogLevel.error => true,
    };
    final fields =
        (entry.fields.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
            .map((field) => '${field.key}=${field.value}')
            .join(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.event,
                style: TextStyle(
                  color: isError ? theme.error : theme.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  fontFamilyFallback: monospace,
                ),
              ),
            ),
            Text(
              _time(entry.timestamp.toLocal()),
              style: TextStyle(color: theme.secondaryText, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          fields,
          style: TextStyle(
            color: theme.secondaryText,
            fontSize: 12,
            fontFamily: 'monospace',
            fontFamilyFallback: monospace,
          ),
        ),
      ],
    );
  }

  String _time(DateTime time) => [
    time.hour,
    time.minute,
    time.second,
  ].map((part) => part.toString().padLeft(2, '0')).join(':');
}
