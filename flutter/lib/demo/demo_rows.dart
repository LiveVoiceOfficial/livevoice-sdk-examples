// Demo scaffolding — not needed for an integration.
// Rows and controls inside a `DemoSection`, each a single line at its use site.

import 'package:flutter/material.dart';

import 'demo_theme.dart';

/// A label with its value on the trailing side.
class DemoValueRow extends StatelessWidget {
  const DemoValueRow(this.label, {super.key, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(color: theme.secondaryText, fontSize: 15),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: theme.text,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// A name from the code, set in monospace, above the text it stands for.
class DemoTextRow extends StatelessWidget {
  const DemoTextRow(this.name, String this.text, {super.key}) : future = null;

  /// For a text that arrives later, such as one of the SDK's `translations`.
  const DemoTextRow.future(this.name, Future<String> this.future, {super.key})
    : text = null;

  final String name;
  final String? text;
  final Future<String>? future;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final style = TextStyle(color: theme.text, fontSize: 15);
    final future = this.future;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            color: theme.secondaryText,
            fontSize: 12,
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Menlo', 'Courier'],
          ),
        ),
        const SizedBox(height: 4),
        if (future == null)
          Text(text ?? '', style: style)
        else
          FutureBuilder<String>(
            future: future,
            builder: (context, snapshot) => Text(
              snapshot.data ?? (snapshot.hasError ? '—' : ''),
              style: style,
            ),
          ),
      ],
    );
  }
}

/// A secondary line that stands in for content that isn't there yet.
class DemoPlaceholder extends StatelessWidget {
  const DemoPlaceholder(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(color: DemoTheme.of(context).secondaryText, fontSize: 15),
  );
}

/// A small label above a widget of your own, such as one of a screen's
/// sample views.
class DemoLabeled extends StatelessWidget {
  const DemoLabeled(this.label, {super.key, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: TextStyle(
          color: DemoTheme.of(context).secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      child,
    ],
  );
}

/// Buttons side by side, wrapping when they don't fit.
class DemoButtonRow extends StatelessWidget {
  const DemoButtonRow(this.children, {super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 8, runSpacing: 8, children: children);
}

/// A bordered button; `null` [onPressed] disables it.
class DemoButton extends StatelessWidget {
  const DemoButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: destructive ? theme.error : theme.accent,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(label),
    );
  }
}

/// A segmented control over [options], in their order.
class DemoSegmentedPicker<T> extends StatelessWidget {
  const DemoSegmentedPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T selected;

  /// `null` disables the control.
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return SegmentedButton<T>(
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: [
        for (final MapEntry(:key, :value) in options.entries)
          ButtonSegment(value: key, label: Text(value)),
      ],
      selected: {selected},
      onSelectionChanged: onChanged == null
          ? null
          : (selection) => onChanged(selection.first),
    );
  }
}

/// A label with a switch on the trailing side.
class DemoToggle extends StatelessWidget {
  const DemoToggle(
    this.label, {
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;

  /// `null` disables the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: DemoTheme.of(context).text, fontSize: 16),
          ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    ),
  );
}

/// A field that opens a menu of [options], in their order. Values may be
/// `null`, such as for "follow the playing channel".
class DemoMenuPicker<T> extends StatelessWidget {
  const DemoMenuPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = DemoTheme.of(context);
    final index = options.indexWhere((option) => option.$1 == selected);
    return PopupMenuButton<int>(
      initialValue: index < 0 ? null : index,
      onSelected: (index) => onChanged(options[index].$1),
      itemBuilder: (context) => [
        for (final (index, (_, label)) in options.indexed)
          PopupMenuItem(value: index, child: Text(label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                index < 0 ? '' : options[index].$2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.text, fontSize: 16),
              ),
            ),
            Icon(Icons.unfold_more, size: 18, color: theme.secondaryText),
          ],
        ),
      ),
    );
  }
}
