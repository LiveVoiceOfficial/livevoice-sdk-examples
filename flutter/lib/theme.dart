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

/// Colors for the demo app chrome: a dimmer page background with brighter cards on top.
@immutable
class DemoTheme {
  const DemoTheme({
    required this.dark,
    required this.pageBackground,
    required this.card,
    required this.sectionCard,
    required this.liveSample,
    required this.popover,
    required this.popoverBorder,
    required this.separator,
    required this.text,
    required this.secondaryText,
    required this.primary,
    required this.chevron,
    required this.warning,
  });

  final bool dark;
  final Color pageBackground;
  final Color card;

  /// Content card on the detail screens (one step up from the page).
  final Color sectionCard;

  /// Container around the default LiveVoice view (the brightest level).
  final Color liveSample;

  /// Floating popover/menu surface (lighter than the page so it stands out).
  final Color popover;
  final Color popoverBorder;
  final Color separator;
  final Color text;
  final Color secondaryText;
  final Color primary;
  final Color chevron;
  final Color warning;

  static const DemoTheme light = DemoTheme(
    dark: false,
    pageBackground: Color(0xFFF2F2F7),
    card: Color(0xFFFFFFFF),
    sectionCard: Color(0xFFE8E8ED),
    liveSample: Color(0xFFFFFFFF),
    popover: Color(0xFFFFFFFF),
    popoverBorder: Color(0xFFE4E4E9),
    separator: Color(0xFFE4E4E9),
    text: Color(0xFF000000),
    secondaryText: Color(0xFF6C6C70),
    primary: Color(0xFFF1521B),
    chevron: Color(0xFFC4C4C6),
    warning: Color(0xFFE08600),
  );

  static const DemoTheme dark_ = DemoTheme(
    dark: true,
    pageBackground: Color(0xFF000000),
    card: Color(0xFF1C1C1E),
    sectionCard: Color(0xFF1C1C1E),
    liveSample: Color(0xFF212429),
    popover: Color(0xFF2C2C2E),
    popoverBorder: Color(0xFF3A3A3C),
    separator: Color(0xFF2C2C2E),
    text: Color(0xFFFFFFFF),
    secondaryText: Color(0xFF9A9AA0),
    primary: Color(0xFFF1521B),
    chevron: Color(0xFF48484A),
    warning: Color(0xFFF5A623),
  );

  /// Resolves the demo theme for the current platform brightness.
  static DemoTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark_ : light;
  }
}
