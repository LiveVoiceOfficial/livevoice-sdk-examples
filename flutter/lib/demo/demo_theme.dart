// Demo scaffolding — not needed for an integration.
// The colors of the demo app's own chrome: a dim page with brighter boxes on it.

import 'package:flutter/material.dart';

@immutable
class DemoTheme {
  const DemoTheme._({
    required this.dark,
    required this.pageBackground,
    required this.card,
    required this.sectionFill,
    required this.raisedCard,
    required this.separator,
    required this.text,
    required this.secondaryText,
    required this.accent,
    required this.chevron,
    required this.warning,
    required this.error,
    required this.online,
  });

  final bool dark;
  final Color pageBackground;

  /// The home list's groups and the pickers.
  final Color card;

  /// The box of a `DemoSection`.
  final Color sectionFill;

  /// A card inside a section, such as a custom cell or a state view.
  final Color raisedCard;
  final Color separator;
  final Color text;
  final Color secondaryText;
  final Color accent;
  final Color chevron;
  final Color warning;
  final Color error;
  final Color online;

  static const DemoTheme light = DemoTheme._(
    dark: false,
    pageBackground: Color(0xFFF2F2F7),
    card: Color(0xFFFFFFFF),
    sectionFill: Color(0xFFE8E8ED),
    raisedCard: Color(0xFFFFFFFF),
    separator: Color(0xFFDCDCE1),
    text: Color(0xFF000000),
    secondaryText: Color(0xFF6C6C70),
    accent: Color(0xFF007AFF),
    chevron: Color(0xFFC4C4C6),
    warning: Color(0xFFE08600),
    error: Color(0xFFD70015),
    online: Color(0xFF34C759),
  );

  static const DemoTheme darkTheme = DemoTheme._(
    dark: true,
    pageBackground: Color(0xFF000000),
    card: Color(0xFF1C1C1E),
    sectionFill: Color(0xFF1C1C1E),
    raisedCard: Color(0xFF2C2C2E),
    separator: Color(0xFF38383A),
    text: Color(0xFFFFFFFF),
    secondaryText: Color(0xFF9A9AA0),
    accent: Color(0xFF0A84FF),
    chevron: Color(0xFF48484A),
    warning: Color(0xFFF5A623),
    error: Color(0xFFFF453A),
    online: Color(0xFF30D158),
  );

  /// The demo colors for the app's current brightness.
  static DemoTheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTheme : light;
}
