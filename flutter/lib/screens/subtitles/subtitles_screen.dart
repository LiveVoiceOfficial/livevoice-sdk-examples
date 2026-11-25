// Subtitles
//
// `startSubtitles` with no channel follows whatever channel plays; with a
// channel from `availableSubtitles` it shows that subtitle stream, playing
// or not. `subtitles` holds the state and its fragments for your own view,
// and `stopSubtitles` ends them. You don't need LiveVoiceView for subtitles.
//
// In Flutter, `availableSubtitles` and `subtitles` are ValueListenables: they
// hold a value before `initialize` too, and need no subscription of yours to
// clean up when you use a ValueListenableBuilder. Channel IDs are `int`.
//
// Uses: availableSubtitles, startSubtitles(channelId:, password:),
// stopSubtitles(), subtitles, LiveVoiceSubtitleState
// See also: Filtering channels (channels with subtitles), Password-protected
// channels (subtitles of a protected channel).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_rows.dart';
import '../../demo/demo_screen.dart';
import '../../demo/demo_theme.dart';

class SubtitlesScreen extends StatefulWidget {
  const SubtitlesScreen({super.key});

  @override
  State<SubtitlesScreen> createState() => _SubtitlesScreenState();
}

class _SubtitlesScreenState extends State<SubtitlesScreen> {
  /// `null` follows the playing channel.
  int? _channelId;
  LiveVoiceException? _failure;

  @override
  Widget build(BuildContext context) => DemoScreen(
    title: 'Subtitles',
    caption: "Show a channel's live subtitles in your own view.",
    error: _failure,
    showsSubtitles: true,
    children: [
      const DemoSection('Subtitles', children: [_SubtitleView()]),
      DemoSection(
        'Source',
        children: [
          // `null` until known, `[]` when the event has none. A `null`
          // language is the channel's original transcript.
          ValueListenableBuilder<List<LiveVoiceAvailableSubtitle>?>(
            valueListenable: availableSubtitles,
            builder: (context, available, _) => DemoMenuPicker<int?>(
              options: [
                (null, 'Playing channel'),
                for (final subtitle
                    in available ?? const <LiveVoiceAvailableSubtitle>[])
                  (
                    subtitle.channelId,
                    subtitle.language == null
                        ? '${subtitle.name} (original)'
                        : subtitle.name,
                  ),
              ],
              selected: _channelId,
              onChanged: (channelId) => setState(() => _channelId = channelId),
            ),
          ),
          DemoButtonRow([
            DemoButton('Start', onPressed: _start),
            DemoButton('Stop', onPressed: _stop),
          ]),
        ],
      ),
      // Following subtitles show the channel playing here.
      const DemoSection('Channels', children: [LiveVoiceView()]),
    ],
  );

  /// One subtitle stream at a time: starting another replaces it, without a
  /// stop in between. Subtitles never start, stop or switch playback.
  Future<void> _start() async {
    setState(() => _failure = null);
    try {
      await startSubtitles(channelId: _channelId);
    } on LiveVoiceException catch (error) {
      if (mounted) setState(() => _failure = error);
    }
  }

  Future<void> _stop() async {
    setState(() => _failure = null);
    try {
      await stopSubtitles();
    } on LiveVoiceException catch (error) {
      if (mounted) setState(() => _failure = error);
    }
  }
}

/// Your own subtitle view: the fragments of `subtitles` in a fixed-height
/// list that shows the newest text.
///
/// It returns to the end on every change, also when the last fragment only
/// grows (the SDK appends an unfinished sentence to it) and also when you
/// scrolled up to read. A real app would usually follow only while the
/// reader is at the end.
class _SubtitleView extends StatelessWidget {
  const _SubtitleView();

  @override
  Widget build(BuildContext context) {
    final secondary = TextStyle(
      color: DemoTheme.of(context).secondaryText,
      fontSize: 16,
    );
    return ValueListenableBuilder<LiveVoiceSubtitleState>(
      valueListenable: subtitles,
      builder: (context, state, _) => switch (state) {
        LiveVoiceSubtitleStateAutomatic(:final fragments) ||
        LiveVoiceSubtitleStateSpecific(:final fragments) =>
          fragments.isEmpty
              ? Text('Waiting for the first words…', style: secondary)
              : _Feed(fragments: fragments),
        LiveVoiceSubtitleStateDisabled() => Text(
          'Start subtitles to see them here.',
          style: secondary,
        ),
      },
    );
  }
}

class _Feed extends StatefulWidget {
  const _Feed({required this.fragments});

  final List<String> fragments;

  @override
  State<_Feed> createState() => _FeedState();
}

class _FeedState extends State<_Feed> {
  // The list is reversed, so offset 0 is its end, where the newest text is,
  // and text added there stays in view.
  final _controller = ScrollController();

  @override
  void didUpdateWidget(_Feed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.fragments, widget.fragments)) return;
    // After the layout of the changed text.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients || _controller.offset == 0) return;
      _controller.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fragments = widget.fragments;
    final style = TextStyle(color: DemoTheme.of(context).text, fontSize: 16);
    return SizedBox(
      height: 220,
      child: ListView.builder(
        controller: _controller,
        reverse: true,
        itemCount: fragments.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(fragments[fragments.length - 1 - index], style: style),
        ),
      ),
    );
  }
}
