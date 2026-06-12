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

import '../theme.dart';
import 'ui.dart';

/// Scaffold + scrollable container for a demo screen. The app bar carries the
/// title and the API key menu.
class DemoScreen extends StatelessWidget {
  const DemoScreen({
    super.key,
    required this.title,
    required this.summary,
    required this.children,
  });

  final String title;
  final String summary;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Scaffold(
      backgroundColor: theme.pageBackground,
      appBar: AppBar(
        backgroundColor: theme.pageBackground,
        foregroundColor: theme.text,
        title: Text(title),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Center(child: DemoApiKeyMenu()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            summary,
            style: TextStyle(
              color: theme.secondaryText,
              fontSize: 16,
              height: 22 / 16,
            ),
          ),
          for (final child in children) ...[const SizedBox(height: 24), child],
        ],
      ),
    );
  }
}

/// A titled content card (one step brighter than the page).
class DemoCardSection extends StatelessWidget {
  const DemoCardSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.sectionCard,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final child in children) ...[const SizedBox(height: 12), child],
        ],
      ),
    );
  }
}

/// A list of implementation-note paragraphs.
class DemoNotes extends StatelessWidget {
  const DemoNotes({super.key, required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < notes.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Text(
            notes[i],
            style: TextStyle(
              color: theme.secondaryText,
              fontSize: 15,
              height: 20 / 15,
            ),
          ),
        ],
      ],
    );
  }
}

/// The brightest container, wrapping the default LiveVoice view.
class DemoDefaultLiveVoiceView extends StatelessWidget {
  const DemoDefaultLiveVoiceView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.liveSample,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}

/// A placeholder shown in a subtitle view while no channel is providing subtitles.
class DemoSubtitleUnavailableHint extends StatelessWidget {
  const DemoSubtitleUnavailableHint({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.subtitles_off_outlined, size: 18, color: theme.secondaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your channels need to provide subtitles to see them here.',
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 14,
                height: 19 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single option in a [DemoSegmentedControl].
class DemoSegment<T> {
  const DemoSegment({required this.label, required this.value});

  final String label;
  final T value;
}

/// A compact segmented control.
class DemoSegmentedControl<T> extends StatelessWidget {
  const DemoSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<DemoSegment<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.separator,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option.value),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: option.value == value
                        ? theme.liveSample
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    option.label,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 13,
                      fontWeight: option.value == value
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// An entry in a [DemoMenuPicker]. A non-null [sectionTitle] renders a grouped
/// header above the item.
class DemoMenuOption {
  const DemoMenuOption({
    required this.id,
    required this.title,
    this.subtitle,
    this.sectionTitle,
  });

  final Object? id;
  final String title;
  final String? subtitle;
  final String? sectionTitle;
}

/// A button that opens a popover menu, used for the subtitle source and
/// featured-source pickers.
class DemoMenuPicker extends StatelessWidget {
  const DemoMenuPicker({
    super.key,
    required this.selectedLabel,
    required this.options,
    required this.selectedId,
    required this.onSelect,
    this.enabled = true,
  });

  final String selectedLabel;
  final List<DemoMenuOption> options;
  final Object? selectedId;
  final ValueChanged<Object?> onSelect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? () => _open(context, theme) : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            border: Border.all(color: theme.separator),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  selectedLabel,
                  style: TextStyle(color: theme.text, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('▾', style: TextStyle(color: theme.secondaryText, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, DemoTheme theme) async {
    final picked = await showDialog<_PickResult>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: theme.popover,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: theme.popoverBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            for (final option in options) ...[
              if (option.sectionTitle != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    option.sectionTitle!.toUpperCase(),
                    style: TextStyle(
                      color: theme.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              InkWell(
                onTap: () =>
                    Navigator.of(context).pop(_PickResult(option.id)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: TextStyle(color: theme.text, fontSize: 16),
                            ),
                            if (option.subtitle != null)
                              Text(
                                option.subtitle!,
                                style: TextStyle(
                                  color: theme.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (option.id == selectedId)
                        Text(
                          '✓',
                          style: TextStyle(color: theme.primary, fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    if (picked != null) {
      onSelect(picked.id);
    }
  }
}

/// Wraps the picked id so that selecting `null` is distinguishable from
/// dismissing the dialog.
class _PickResult {
  const _PickResult(this.id);
  final Object? id;
}
