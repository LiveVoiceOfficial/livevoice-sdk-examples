// Joining an event
//
// `joinEvent` joins an event and returns once it is ready; joining again
// leaves the previous one. It returns a LiveVoiceJoinedEvent whose `leave()`
// leaves only that join. `connection` says where the connection is and
// `reconnect` reconnects at once. The demo joins the event picked in the
// toolbar at launch; here you make the calls yourself.
//
// In Flutter, `connection` is a ValueListenable of a sealed class: build on
// it with a ValueListenableBuilder and switch over its cases. Every call
// throws a LiveVoiceException, and one made before `initialize` has
// completed throws `notInitialized`.
//
// Uses: joinEvent(joinCode:, password:, apiKey:), LiveVoiceJoinedEvent.leave(),
// leaveEvent(), connection, reconnect()
// See also: Default interface, Custom view states (how LiveVoiceView shows
// each state).

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';
import '../../demo/demo_session.dart';

class JoiningEventScreen extends StatefulWidget {
  const JoiningEventScreen({super.key});

  @override
  State<JoiningEventScreen> createState() => _JoiningEventScreenState();
}

class _JoiningEventScreenState extends State<JoiningEventScreen> {
  // The join made on this screen. A screen that owns its event would leave
  // it with `joined.leave()` in `dispose`; this demo doesn't, because every
  // screen shares the event.
  LiveVoiceJoinedEvent? _joined;
  LiveVoiceException? _failure;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<LiveVoiceConnection>(
        valueListenable: connection,
        builder: (context, connection, _) => DemoScreen(
          title: 'Joining an event',
          caption: 'Join, reconnect and leave the event yourself.',
          error: _failure,
          children: [
            DemoSection(
              'Connection',
              children: [
                DemoValueRow('State', value: _describe(connection)),
                DemoValueRow(
                  'Joined from this screen',
                  value: _joined == null ? 'No' : 'Yes',
                ),
                DemoButtonRow([
                  DemoButton(
                    'Leave',
                    destructive: true,
                    onPressed: _canLeave(connection) ? _leave : null,
                  ),
                  DemoButton(
                    'Join',
                    onPressed: _isBusy(connection) ? null : _join,
                  ),
                  DemoButton(
                    'Reconnect',
                    onPressed: _canReconnect(connection) ? _reconnect : null,
                  ),
                ]),
              ],
            ),
            const DemoSection('Channels', children: [LiveVoiceView()]),
          ],
        ),
      );

  String _describe(LiveVoiceConnection connection) => switch (connection) {
    LiveVoiceConnectionIdle() => 'Idle',
    LiveVoiceConnectionJoining() => 'Joining',
    LiveVoiceConnectionReady(:final eventId) => 'Ready, event $eventId',
    // The SDK reconnects by itself; `reconnect()` tries at once.
    LiveVoiceConnectionReconnecting() => 'Reconnecting',
    LiveVoiceConnectionLeaving() => 'Leaving',
    LiveVoiceConnectionFailed(:final error) => 'Failed: ${error.message}',
  };

  bool _isBusy(LiveVoiceConnection connection) => switch (connection) {
    LiveVoiceConnectionJoining() || LiveVoiceConnectionLeaving() => true,
    LiveVoiceConnectionIdle() ||
    LiveVoiceConnectionReady() ||
    LiveVoiceConnectionReconnecting() ||
    LiveVoiceConnectionFailed() => false,
  };

  bool _canLeave(LiveVoiceConnection connection) => switch (connection) {
    LiveVoiceConnectionIdle() || LiveVoiceConnectionLeaving() => false,
    LiveVoiceConnectionJoining() ||
    LiveVoiceConnectionReady() ||
    LiveVoiceConnectionReconnecting() ||
    LiveVoiceConnectionFailed() => true,
  };

  /// `reconnect()` works while the event is ready or reconnecting, and after
  /// a failure that `isRetryable`; otherwise it throws.
  bool _canReconnect(LiveVoiceConnection connection) => switch (connection) {
    LiveVoiceConnectionReady() || LiveVoiceConnectionReconnecting() => true,
    LiveVoiceConnectionFailed(:final error) => error.isRetryable,
    LiveVoiceConnectionIdle() ||
    LiveVoiceConnectionJoining() ||
    LiveVoiceConnectionLeaving() => false,
  };

  /// Returns once the event is ready. Joining again leaves the previous event.
  Future<void> _join() async {
    // The join code, password and API key of the event picked in the toolbar.
    final event = DemoSessionScope.read(context).selectedPreset;
    // The new join replaces the old one, so forget the old one now: while
    // this join is pending or after it fails, Leave uses `leaveEvent()`.
    setState(() {
      _failure = null;
      _joined = null;
    });
    try {
      final joined = await joinEvent(
        joinCode: event.joinCode,
        password: event.password,
        apiKey: event.apiKey,
      );
      if (mounted) setState(() => _joined = joined);
    } on LiveVoiceException catch (error) {
      // A leave or a newer join ended this one; nothing went wrong.
      if (_endedByAnotherCall(error)) return;
      if (mounted) setState(() => _failure = error);
    }
  }

  /// Works while the event is ready or reconnecting, and after a failure
  /// whose error `isRetryable`; the playing channel is restored.
  Future<void> _reconnect() async {
    setState(() => _failure = null);
    try {
      await reconnect();
    } on LiveVoiceException catch (error) {
      // A newer join, switch or reconnect took over, or a leave ended it;
      // nothing went wrong.
      if (_endedByAnotherCall(error)) return;
      if (mounted) setState(() => _failure = error);
    }
  }

  /// After a join on this screen, leaves only that join: never a newer one,
  /// such as after you pick another event in the toolbar (then it does
  /// nothing). Before it, leaves whatever is joined: here the event the
  /// toolbar joined.
  Future<void> _leave() async {
    setState(() => _failure = null);
    try {
      final joined = _joined;
      if (joined != null) {
        await joined.leave();
      } else {
        await leaveEvent();
      }
      if (mounted) setState(() => _joined = null);
    } on LiveVoiceException catch (error) {
      if (mounted) setState(() => _failure = error);
    }
  }

  bool _endedByAnotherCall(LiveVoiceException error) =>
      error.code == LiveVoiceErrorCode.cancelled ||
      error.code == LiveVoiceErrorCode.superseded;
}
