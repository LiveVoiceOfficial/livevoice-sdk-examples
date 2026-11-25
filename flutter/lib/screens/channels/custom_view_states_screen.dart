// Custom view states
//
// LiveVoiceView takes your own widgets for its states: `loadingBuilder`,
// `reconnectingBuilder`, `errorBuilder` and `emptyBuilder`; the parts you
// leave out keep the SDK's design. `onCommandError` receives the errors of
// the SDK's own controls. LiveVoiceView shows a part only while its state
// lasts, so the screen shows each of your widgets with sample values first.
// Below, LiveVoiceView uses them: turn on flight mode while a channel plays
// to see reconnecting and errors.
//
// In Flutter, the parts are constructor arguments, not modifiers. The error
// part's `retry` is `reconnect`, which throws: catch its errors, or they
// end up as unhandled async errors. A reconnect's scheduled time is a
// DateTime, so a countdown is a widget that ticks by itself.
//
// Needs: an API key that permits custom UI (except for `loadingBuilder`).
// Uses: LiveVoiceView(loadingBuilder:, reconnectingBuilder:, errorBuilder:,
// emptyBuilder:, onCommandError:), LiveVoiceRetry, LiveVoiceEmptyReason
// See also: Custom channel cell, Joining an event (connection and reconnect),
// Localization and accessibility (error messages).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';
import '../../demo/demo_theme.dart';

class CustomViewStatesScreen extends StatefulWidget {
  const CustomViewStatesScreen({super.key});

  @override
  State<CustomViewStatesScreen> createState() => _CustomViewStatesScreenState();
}

class _CustomViewStatesScreenState extends State<CustomViewStatesScreen> {
  LiveVoiceException? _failure;

  // Sample values, made once so the countdown counts down.
  final _sampleRetry = LiveVoiceRetryScheduled(
    DateTime.now().add(const Duration(seconds: 8)),
  );
  final _sampleError = LiveVoiceException(LiveVoiceErrorCode.noNetwork);

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<LiveVoiceFeatures>(
    valueListenable: features,
    builder: (context, features, _) => DemoScreen(
      title: 'Custom view states',
      caption: 'Show loading, reconnecting, errors and no channels your way.',
      error: _failure,
      children: [
        DemoRequirement.customUi(isMet: features.customUiAllowed),
        DemoSection(
          'Your views, with sample values',
          children: [
            const DemoLabeled('Loading', child: _LoadingView()),
            DemoLabeled(
              'Reconnecting',
              child: _ReconnectingView(retry: _sampleRetry),
            ),
            DemoLabeled(
              'Error',
              child: _ErrorView(error: _sampleError, retry: () async {}),
            ),
            const DemoLabeled(
              'No channels',
              child: _NoChannelsView(reason: LiveVoiceEmptyReason.noChannels),
            ),
          ],
        ),
        DemoSection(
          'In LiveVoiceView',
          children: [
            const DemoNote.info(
              'Your views show while their state lasts; while connected, the channels do.',
            ),
            LiveVoiceView(
              loadingBuilder: (context) => const _LoadingView(),
              reconnectingBuilder: (context, retry) =>
                  _ReconnectingView(retry: retry),
              errorBuilder: (context, error, retry) =>
                  _ErrorView(error: error, retry: retry),
              emptyBuilder: (context, reason) =>
                  _NoChannelsView(reason: reason),
              // `cancelled` and `superseded` never arrive here. Your own parts
              // get their errors from their actions instead.
              onCommandError: (error) => setState(() => _failure = error),
            ),
          ],
        ),
      ],
    ),
  );
}

/// While the event loads.
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const _StateRow(
    title: 'Loading channels…',
    accessory: SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

/// Shown after the SDK kept the channel list, drawn disabled, for the first
/// seconds of a reconnection. The SDK reconnects by itself.
class _ReconnectingView extends StatefulWidget {
  const _ReconnectingView({required this.retry});

  final LiveVoiceRetry retry;

  @override
  State<_ReconnectingView> createState() => _ReconnectingViewState();
}

class _ReconnectingViewState extends State<_ReconnectingView> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    // Redraws the countdown every second.
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _StateRow(
    title: 'Reconnecting',
    detail: switch (widget.retry) {
      LiveVoiceRetryInProgress() => 'Trying now…',
      LiveVoiceRetryScheduled(:final at) => switch (at
          .difference(DateTime.now())
          .inSeconds) {
        <= 0 => 'Trying again soon…',
        final seconds => 'Next try in $seconds s',
      },
    },
    accessory: const SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

/// Shows the error's `message`, the SDK's text for it. `retry` is there
/// exactly when trying again can help.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.retry});

  final LiveVoiceException error;
  final Future<void> Function()? retry;

  @override
  Widget build(BuildContext context) {
    final retry = this.retry;
    return _StateRow(
      title: "Couldn't connect",
      detail: error.message,
      icon: Icons.warning_rounded,
      accessory: retry == null
          ? null
          : FilledButton(
              // A failed retry shows up as the view's next error.
              onPressed: () =>
                  unawaited(retry().then<void>((_) {}, onError: (Object _) {})),
              child: const Text('Try again'),
            ),
    );
  }
}

class _NoChannelsView extends StatelessWidget {
  const _NoChannelsView({required this.reason});

  final LiveVoiceEmptyReason reason;

  @override
  Widget build(BuildContext context) => _StateRow(
    title: switch (reason) {
      LiveVoiceEmptyReason.noChannels => 'This event has no channels yet.',
      // The view's filter matches none of the event's channels.
      LiveVoiceEmptyReason.noMatches => 'No matching channels.',
    },
    icon: Icons.inbox_outlined,
  );
}

/// The look the state views share with a channel row: an icon, a title, a
/// detail line, and an accessory on the trailing side, in a card.
class _StateRow extends StatelessWidget {
  const _StateRow({
    required this.title,
    this.detail,
    this.icon,
    this.accessory,
  });

  final String title;
  final String? detail;
  final IconData? icon;
  final Widget? accessory;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final icon = this.icon;
    final detail = this.detail;
    final accessory = this.accessory;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.raisedCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: theme.secondaryText, size: 22),
            const SizedBox(width: 12),
          ],
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
                if (detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(color: theme.secondaryText, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (accessory != null) ...[const SizedBox(width: 12), accessory],
        ],
      ),
    );
  }
}
