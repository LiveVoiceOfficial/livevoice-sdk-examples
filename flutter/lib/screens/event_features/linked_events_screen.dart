// Linked events
//
// An event can be linked to others, for example the rooms of a conference.
// `linkedEvents` lists them, and `switchToLinkedEvent` leaves the joined
// event and joins the linked one with the same API key. LiveVoiceView then
// shows the new event's channels.
//
// In Flutter, the screen listens to `features`, `linkedEvents` and
// `currentEvent` at once with `Listenable.merge`. The LiveVoiceJoinedEvent of
// your join follows the switch: its `leave()` then leaves the linked event.
//
// Needs: your own event with another event linked to it in the dashboard,
// and an API key that permits custom UI.
// Uses: linkedEvents, switchToLinkedEvent(), currentEvent,
// LiveVoiceLinkedEvent, features
// See also: Joining an event.

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';

class LinkedEventsScreen extends StatefulWidget {
  const LinkedEventsScreen({super.key});

  @override
  State<LinkedEventsScreen> createState() => _LinkedEventsScreenState();
}

class _LinkedEventsScreenState extends State<LinkedEventsScreen> {
  LiveVoiceException? _failure;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([features, linkedEvents, currentEvent]),
    builder: (context, _) {
      final customUiAllowed = features.value.customUiAllowed;
      final events = linkedEvents.value;
      return DemoScreen(
        title: 'Linked events',
        caption: 'Switch to an event linked to this one.',
        error: _failure,
        children: [
          DemoRequirement.customUi(isMet: customUiAllowed),
          // `null`: no event is ready, or the API key doesn't permit custom
          // UI, which the note above covers.
          DemoRequirement.ownEvent(
            'Linked events',
            isMet: !customUiAllowed || (events?.isNotEmpty ?? false),
          ),
          DemoSection(
            'Events',
            children: [
              DemoValueRow('Joined', value: currentEvent.value?.name ?? 'None'),
              for (final event in events ?? const <LiveVoiceLinkedEvent>[])
                Row(
                  children: [
                    Expanded(child: Text(event.name)),
                    DemoButton('Switch', onPressed: () => _switchTo(event)),
                  ],
                ),
            ],
          ),
          const DemoSection('Channels', children: [LiveVoiceView()]),
        ],
      );
    },
  );

  /// Returns once the linked event is ready. A failed switch doesn't return
  /// to the previous event; `reconnect()` tries the linked event again.
  Future<void> _switchTo(LiveVoiceLinkedEvent event) async {
    setState(() => _failure = null);
    try {
      await switchToLinkedEvent(event);
    } on LiveVoiceException catch (error) {
      // A leave or a newer join or switch ended this one.
      if (error.code == LiveVoiceErrorCode.cancelled ||
          error.code == LiveVoiceErrorCode.superseded) {
        return;
      }
      if (mounted) setState(() => _failure = error);
    }
  }
}
