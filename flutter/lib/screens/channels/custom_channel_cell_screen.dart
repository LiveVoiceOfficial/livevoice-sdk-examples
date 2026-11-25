// Custom channel cell
//
// `channelCellBuilder` draws each channel with your own widget. The builder
// gets a LiveVoiceChannelCell: the channel, whether it is the last one,
// whether its action may be used now (`isEnabled`), and the action,
// `togglePlayback()`. The SDK keeps the session, playback and reconnection.
// Both cells read out with the SDK's accessibility texts (`translations`).
//
// In Flutter, `cell.channel` is an immutable snapshot: LiveVoiceView calls
// the builder again whenever a channel changes, so read the channel in
// `build` and never keep it. A cell with state of its own (here a failed
// tap's message) needs a key per channel, so the state stays with its
// channel. The SDK's texts arrive asynchronously, so the screen reads them
// once and hands them to the cells. With an API key that doesn't permit
// custom UI, the whole view shows the invalid-API-key error instead of your
// cells.
//
// Needs: an API key that permits custom UI.
// Uses: LiveVoiceView(channelCellBuilder:), LiveVoiceChannelCell,
// LiveVoiceChannel, features, translations
// See also: Custom view states, Localization and accessibility (the SDK's
// texts for your cells).

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../../demo/demo_screen.dart';
import '../../demo/demo_theme.dart';

class CustomChannelCellScreen extends StatefulWidget {
  const CustomChannelCellScreen({super.key});

  @override
  State<CustomChannelCellScreen> createState() =>
      _CustomChannelCellScreenState();
}

/// The SDK's localized accessibility texts for a channel cell.
typedef _CellTexts = ({String play, String stop, String muted});

class _CustomChannelCellScreenState extends State<CustomChannelCellScreen> {
  _CellTexts? _texts;

  @override
  void initState() {
    super.initState();
    _loadTexts();
  }

  Future<void> _loadTexts() async {
    try {
      final texts = (
        play: await translations.accessibilityChannelPlay(),
        stop: await translations.accessibilityChannelStop(),
        muted: await translations.accessibilityChannelStatusMuted(),
      );
      if (mounted) setState(() => _texts = texts);
    } on LiveVoiceException {
      // Without them the cells read out without a hint.
    }
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<LiveVoiceFeatures>(
        valueListenable: features,
        builder: (context, features, _) => DemoScreen(
          title: 'Custom channel cell',
          caption: 'Draw each channel with your own view.',
          children: [
            DemoRequirement.customUi(isMet: features.customUiAllowed),
            DemoSection(
              'Simple cell',
              children: [
                LiveVoiceView(
                  channelCellBuilder: (context, cell) => _ChannelCell(
                    key: ValueKey(cell.channel.id),
                    cell: cell,
                    texts: _texts,
                  ),
                ),
              ],
            ),
            DemoSection(
              'Detailed cell',
              children: [
                LiveVoiceView(
                  channelCellBuilder: (context, cell) => _DetailedChannelCell(
                    key: ValueKey(cell.channel.id),
                    cell: cell,
                    texts: _texts,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

/// A channel row of your own: the name, a status line and a play button.
/// Cells are laid out flush to the view's edges, so the cell sets its own
/// padding and divider.
class _ChannelCell extends StatefulWidget {
  const _ChannelCell({super.key, required this.cell, required this.texts});

  final LiveVoiceChannelCell cell;
  final _CellTexts? texts;

  @override
  State<_ChannelCell> createState() => _ChannelCellState();
}

class _ChannelCellState extends State<_ChannelCell> {
  LiveVoiceException? _failure;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final cell = widget.cell;
    final channel = cell.channel;
    // `false` while the channel is offline, has no audio, or the connection
    // recovers: draw the cell as unavailable then.
    final onTap = cell.isEnabled ? _togglePlayback : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          excludeSemantics: true,
          button: true,
          enabled: cell.isEnabled,
          label: channel.name,
          value: _accessibilityStatus,
          hint: _accessibilityHint,
          onTap: onTap,
          child: InkWell(
            onTap: onTap,
            child: Opacity(
              opacity: cell.isEnabled ? 1 : 0.4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            channel.name,
                            style: TextStyle(
                              color: theme.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _failure?.message ?? _status,
                            style: TextStyle(
                              color: theme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _PlaybackIcon(
                      state: channel.playingState,
                      color: theme.accent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!cell.isLast) Divider(height: 1, color: theme.separator),
      ],
    );
  }

  String get _status {
    final channel = widget.cell.channel;
    if (!channel.isOnline) return 'Offline';
    // The SDK plays no video: a channel with video and audio plays its
    // audio, one with only video cannot be played (`hasAudio` is false).
    if (!channel.hasAudio) return channel.hasVideo ? 'Video only' : 'No audio';
    final translation = channel.aiTranslationInfo;
    if (translation != null) {
      return 'AI translation, ${translation.targetLanguage}';
    }
    return channel.hasSubtitles ? 'With subtitles' : 'Ready';
  }

  /// What a screen reader reads after the name: a failed tap's message, as
  /// shown, or the playing state.
  String get _accessibilityStatus {
    final failure = _failure;
    if (failure != null) return failure.message;
    final channel = widget.cell.channel;
    final playing = switch (channel.playingState) {
      LiveVoicePlayingState.playing => 'Playing',
      LiveVoicePlayingState.transitioning => 'Connecting',
      LiveVoicePlayingState.stopped => 'Stopped',
    };
    return channel.isOnline ? playing : 'Offline, $playing';
  }

  /// The SDK's localized text for the cell's action.
  String? get _accessibilityHint => switch (widget.cell.channel.playingState) {
    LiveVoicePlayingState.playing ||
    LiveVoicePlayingState.transitioning => widget.texts?.stop,
    LiveVoicePlayingState.stopped => widget.texts?.play,
  };

  /// Starts the channel if it is stopped and stops it if it plays, decided
  /// when it runs. Returns once the channel plays or has stopped.
  Future<void> _togglePlayback() async {
    setState(() => _failure = null);
    try {
      await widget.cell.togglePlayback();
    } on LiveVoiceException catch (error) {
      if (mounted) setState(() => _failure = error);
    }
  }
}

/// A richer row that shows what you can read from LiveVoiceChannel: the
/// online dot, every Boolean as a tag (faint when false, so all of them stay
/// visible even where a feature doesn't apply), the AI translation, the
/// channels that translate this one, and the playing state. Each channel is
/// a card of its own.
class _DetailedChannelCell extends StatefulWidget {
  const _DetailedChannelCell({
    super.key,
    required this.cell,
    required this.texts,
  });

  final LiveVoiceChannelCell cell;
  final _CellTexts? texts;

  @override
  State<_DetailedChannelCell> createState() => _DetailedChannelCellState();
}

class _DetailedChannelCellState extends State<_DetailedChannelCell> {
  LiveVoiceException? _failure;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final cell = widget.cell;
    final channel = cell.channel;
    // `false` while the channel is offline, has no audio, or the connection
    // recovers: the cell looks and acts unavailable then.
    final onTap = cell.isEnabled ? _togglePlayback : null;
    final buttonColor = cell.isEnabled ? theme.accent : theme.secondaryText;
    final failure = _failure;
    return Padding(
      padding: EdgeInsets.only(bottom: cell.isLast ? 0 : 12),
      // Read as one element, so the faint tags aren't read out.
      child: Semantics(
        container: true,
        excludeSemantics: true,
        button: true,
        enabled: cell.isEnabled,
        label: channel.name,
        value: _accessibilityValue,
        hint: _accessibilityHint,
        onTap: onTap,
        child: Material(
          color: theme.raisedCard,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: channel.isOnline
                          ? theme.online
                          : theme.secondaryText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channel.name,
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          failure?.message ?? _status,
                          style: TextStyle(
                            color: failure == null
                                ? theme.secondaryText
                                : theme.error,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            DemoTag('Audio', isOn: channel.hasAudio),
                            // The SDK plays no video; of a channel with both
                            // it plays the audio.
                            DemoTag('Video', isOn: channel.hasVideo),
                            DemoTag('Subtitles', isOn: channel.hasSubtitles),
                            DemoTag('Muted', isOn: channel.isAudioMuted),
                            DemoTag(
                              'Password',
                              isOn: channel.isPasswordProtected,
                            ),
                            DemoTag('AI voice', isOn: channel.isAiSpeaker),
                            DemoTag('On demand', isOn: channel.isOnDemand),
                          ],
                        ),
                        if (channel.dependentChannels.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          // Channels that translate this one, such as an AI
                          // voice.
                          Text(
                            'Translations: '
                            '${channel.dependentChannels.map((c) => c.name).join(', ')}',
                            style: TextStyle(
                              color: theme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.accent.withValues(
                        alpha: cell.isEnabled ? 0.12 : 0.05,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: _PlaybackIcon(
                      state: channel.playingState,
                      color: buttonColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _status {
    final channel = widget.cell.channel;
    if (!channel.isOnline) return 'Inactive';
    final translation = channel.aiTranslationInfo;
    if (translation != null) {
      return 'AI translation into ${translation.targetLanguage}';
    }
    return switch (channel.playingState) {
      LiveVoicePlayingState.playing => 'Currently playing',
      LiveVoicePlayingState.transitioning => 'Connecting…',
      LiveVoicePlayingState.stopped =>
        channel.hasAudio ? 'Ready to start' : 'Nothing to play',
    };
  }

  /// The status line and only the properties that are true, the way the
  /// tags show them at full contrast.
  String get _accessibilityValue {
    final channel = widget.cell.channel;
    final properties = <(bool, String?)>[
      (channel.hasAudio, 'Audio'),
      (channel.hasVideo, 'Video'),
      (channel.hasSubtitles, 'Subtitles'),
      // The SDK's localized text for a muted channel.
      (channel.isAudioMuted, widget.texts?.muted),
      (channel.isPasswordProtected, 'Password'),
      (channel.isAiSpeaker, 'AI voice'),
      (channel.isOnDemand, 'On demand'),
    ];
    return [
      _failure?.message ?? _status,
      for (final (isOn, text) in properties)
        if (isOn && text != null) text,
    ].join(', ');
  }

  /// The SDK's localized text for the cell's action.
  String? get _accessibilityHint => switch (widget.cell.channel.playingState) {
    LiveVoicePlayingState.playing ||
    LiveVoicePlayingState.transitioning => widget.texts?.stop,
    LiveVoicePlayingState.stopped => widget.texts?.play,
  };

  Future<void> _togglePlayback() async {
    setState(() => _failure = null);
    try {
      await widget.cell.togglePlayback();
    } on LiveVoiceException catch (error) {
      if (mounted) setState(() => _failure = error);
    }
  }
}

/// Play, connecting or stop, for a channel's `playingState`.
class _PlaybackIcon extends StatelessWidget {
  const _PlaybackIcon({required this.state, required this.color});

  final LiveVoicePlayingState state;
  final Color color;

  @override
  Widget build(BuildContext context) => switch (state) {
    LiveVoicePlayingState.stopped => Icon(
      Icons.play_arrow_rounded,
      color: color,
    ),
    LiveVoicePlayingState.transitioning => SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    ),
    LiveVoicePlayingState.playing => Icon(Icons.stop_rounded, color: color),
  };
}
