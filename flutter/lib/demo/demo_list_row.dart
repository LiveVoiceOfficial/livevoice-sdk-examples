// Demo scaffolding — not needed for an integration.
// The home list: its header, its groups and their rows.

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import 'demo_theme.dart';

/// The logo, the SDK versions and the app's one-line summary.
class DemoHomeHeader extends StatefulWidget {
  const DemoHomeHeader({super.key});

  @override
  State<DemoHomeHeader> createState() => _DemoHomeHeaderState();
}

class _DemoHomeHeaderState extends State<DemoHomeHeader> {
  late final Future<(String, String)> _versions = (() async =>
      (await getSdkVersion(), await getNativeSdkVersion()))();

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final caption = TextStyle(color: theme.secondaryText, fontSize: 12);
    return Column(
      children: [
        const SizedBox(height: 16),
        Image.asset(
          theme.dark ? 'assets/logo-dark.png' : 'assets/logo.png',
          width: 129.5,
          height: 88.7,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        FutureBuilder<(String, String)>(
          future: _versions,
          builder: (context, snapshot) => switch (snapshot.data) {
            (final flutter, final native) => Text(
              'Flutter SDK $flutter · native SDK $native',
              style: caption,
            ),
            null => Text('', style: caption),
          },
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'A quick tour of LiveVoice SDK features.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.text, fontSize: 15),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// A stamped "Flutter" pill in the Flutter brand color.
class DemoPlatformBadge extends StatelessWidget {
  const DemoPlatformBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
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

/// A titled group of [DemoListRow]s.
class DemoListGroup extends StatelessWidget {
  const DemoListGroup(this.title, {super.key, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final (index, child) in children.indexed) ...[
                  if (index > 0)
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      indent: 16,
                      color: theme.separator,
                    ),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of the demo list. [needsOwnEvent] tags a demo that the demo event
/// cannot show, so nobody opens it and wonders why nothing happens.
class DemoListRow extends StatelessWidget {
  const DemoListRow({
    super.key,
    required this.title,
    required this.summary,
    this.needsOwnEvent = false,
    required this.destination,
  });

  final String title;
  final String summary;
  final bool needsOwnEvent;

  /// The screen the row opens.
  final Widget Function() destination;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => destination())),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (needsOwnEvent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Own event',
                            style: TextStyle(
                              color: theme.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    style: TextStyle(color: theme.secondaryText, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: theme.chevron),
          ],
        ),
      ),
    );
  }
}
