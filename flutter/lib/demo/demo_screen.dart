// Demo scaffolding — not needed for an integration.
//
// The look every demo screen shares, so that a screen's own file reads as
// LiveVoice SDK usage: the screen shell, the grouped sections and the one-line
// note on what a screen needs from the event.

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import '../screens/subtitles/subtitles_screen.dart';
import 'demo_event_picker.dart';
import 'demo_session.dart';
import 'demo_theme.dart';

/// A demo screen: a scrolling column of [DemoSection]s under a title, with
/// a one-sentence caption.
///
/// [error] shows a failed call's message in one line under the caption, the
/// text the SDK provides for it. While subtitles are on, the screen links to
/// the Subtitles screen, unless it is the one that shows them
/// ([showsSubtitles]).
class DemoScreen extends StatelessWidget {
  const DemoScreen({
    super.key,
    required this.title,
    required this.caption,
    this.error,
    this.showsSubtitles = false,
    required this.children,
  });

  final String title;
  final String caption;
  final LiveVoiceException? error;
  final bool showsSubtitles;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final error = this.error;
    return Scaffold(
      backgroundColor: theme.pageBackground,
      appBar: AppBar(
        backgroundColor: theme.pageBackground,
        foregroundColor: theme.text,
        actions: const [DemoApiKeyMenu(), SizedBox(width: 8)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.text,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            caption,
            style: TextStyle(color: theme.secondaryText, fontSize: 17),
          ),
          if (error != null) ...[
            const SizedBox(height: 24),
            DemoNote(
              error.message,
              icon: Icons.error_outline,
              color: theme.error,
            ),
          ],
          if (!showsSubtitles)
            ValueListenableBuilder<LiveVoiceSubtitleState>(
              valueListenable: subtitles,
              builder: (context, state, _) => switch (state) {
                LiveVoiceSubtitleStateDisabled() => const SizedBox.shrink(),
                LiveVoiceSubtitleStateAutomatic() ||
                LiveVoiceSubtitleStateSpecific() => Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SubtitlesScreen(),
                      ),
                    ),
                    child: DemoNote(
                      'Go to the Subtitles section to see them in action.',
                      icon: Icons.subtitles_outlined,
                      color: theme.accent,
                    ),
                  ),
                ),
              },
            ),
          for (final child in children) ...[const SizedBox(height: 24), child],
        ],
      ),
    );
  }
}

/// A titled, rounded box that groups part of a demo screen.
class DemoSection extends StatelessWidget {
  const DemoSection(this.title, {super.key, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Above the box, like a grouped list's header, so it never reads as
        // part of the content.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: theme.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.sectionFill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0) const SizedBox(height: 12),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// What a demo screen needs beyond the demo event, said in one line while it
/// is missing, with a button to pick another event or API key. Until an event
/// is ready it says it waits instead: permissions and features are only
/// known once joined.
class DemoRequirement extends StatelessWidget {
  /// An API key that permits custom UI: the "Full customization" preset.
  const DemoRequirement.customUi({super.key, required this.isMet})
    : feature = null;

  /// An event with [feature] enabled in the Admin console, which the demo
  /// event lacks. With your own event, the note says that this event doesn't
  /// have it enabled.
  const DemoRequirement.ownEvent(
    String this.feature, {
    super.key,
    required this.isMet,
  });

  final String? feature;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final session = DemoSessionScope.of(context);
    return ValueListenableBuilder<LiveVoiceConnection>(
      valueListenable: connection,
      builder: (context, connection, _) {
        final eventIsReady = switch (connection) {
          LiveVoiceConnectionReady() ||
          LiveVoiceConnectionReconnecting() => true,
          LiveVoiceConnectionIdle() ||
          LiveVoiceConnectionJoining() ||
          LiveVoiceConnectionLeaving() ||
          LiveVoiceConnectionFailed() => false,
        };
        if (!eventIsReady) {
          return const DemoNote(
            'Waiting for the event…',
            icon: Icons.hourglass_empty,
          );
        }
        if (isMet) return const SizedBox.shrink();
        final feature = this.feature;
        final (text, button, choose) = feature == null
            ? (
                'Needs an API key that permits custom UI.',
                'Choose an API key',
                showDemoApiKeyPicker,
              )
            : session.usesOwnEvent
            ? (
                "This event doesn't have the '$feature' feature enabled. "
                    'Enable this in the Admin console on the web.',
                'Use another event',
                showDemoCustomCredentialsEditor,
              )
            : (
                "The demo event doesn't have the '$feature' feature enabled. "
                    'To try it, use your own event and enable the feature in '
                    'the Admin console on the web.',
                'Use your own event',
                showDemoCustomCredentialsEditor,
              );
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_rounded, color: theme.warning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(color: theme.text, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () => choose(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(top: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: theme.accent,
                      ),
                      child: Text(
                        button,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One line of information on a demo screen, with an icon.
class DemoNote extends StatelessWidget {
  const DemoNote(this.text, {super.key, required this.icon, this.color});

  /// A secondary note, such as on what a setting applies to.
  const DemoNote.info(this.text, {super.key})
    : icon = Icons.info_outline,
      color = null;

  final String text;
  final IconData icon;

  /// The secondary text color by default.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? DemoTheme.of(context).secondaryText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 14)),
        ),
      ],
    );
  }
}

/// A small outlined label for one of a channel's properties in a custom
/// cell: full contrast when [isOn], faint when not, so every value stays
/// visible. Your app draws its own.
class DemoTag extends StatelessWidget {
  const DemoTag(this.text, {super.key, this.isOn = true});

  final String text;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final color = DemoTheme.of(context).text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: color.withValues(alpha: isOn ? 0.85 : 0.16),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          color: color.withValues(alpha: isOn ? 1 : 0.3),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
