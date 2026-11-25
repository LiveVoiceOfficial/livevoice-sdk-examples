// Demo scaffolding — not needed for an integration.
// The controls of the demo screens, each a single line at its use site.

import React, { useState } from "react";
import {
  Modal,
  Pressable,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  View,
} from "react-native";
import { useDemoTheme } from "./DemoTheme";

/**
 * A button: `bordered` on a tinted fill, like the iOS sample's bordered
 * buttons, or plain text. `destructive` draws it in red.
 */
export const DemoButton: React.FC<{
  title: string;
  onPress: () => void;
  disabled?: boolean;
  destructive?: boolean;
  plain?: boolean;
}> = ({ title, onPress, disabled = false, destructive = false, plain = false }) => {
  const theme = useDemoTheme();
  const tint = disabled
    ? theme.secondaryText
    : destructive
      ? theme.red
      : theme.accent;
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ disabled }}
      disabled={disabled}
      onPress={onPress}
      hitSlop={plain ? 8 : 0}
      style={({ pressed }) => [
        !plain && styles.bordered,
        !plain && { backgroundColor: theme.buttonFill },
        { opacity: pressed ? 0.5 : disabled ? 0.6 : 1 },
      ]}
    >
      <Text style={[styles.buttonText, { color: tint }]}>{title}</Text>
    </Pressable>
  );
};

/** Buttons side by side. */
export const DemoButtonRow: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => <View style={styles.buttonRow}>{children}</View>;

/** A segmented control over a few values. */
export function DemoSegmentedControl<T extends string>({
  options,
  value,
  onChange,
}: {
  options: { label: string; value: T }[];
  value: T;
  onChange: (value: T) => void;
}) {
  const theme = useDemoTheme();
  return (
    <View
      accessibilityRole="tablist"
      style={[styles.segments, { backgroundColor: theme.buttonFill }]}
    >
      {options.map((option) => {
        const selected = option.value === value;
        return (
          <Pressable
            key={option.value}
            accessibilityRole="tab"
            accessibilityState={{ selected }}
            onPress={() => onChange(option.value)}
            style={[
              styles.segment,
              selected && { backgroundColor: theme.cardFill },
            ]}
          >
            <Text
              style={[
                styles.segmentText,
                { color: theme.text, fontWeight: selected ? "600" : "400" },
              ]}
            >
              {option.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

/** A label with a switch on the trailing side. */
export const DemoSwitchRow: React.FC<{
  label: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
  disabled?: boolean;
}> = ({ label, value, onValueChange, disabled = false }) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.switchRow}>
      <Text style={[styles.switchLabel, { color: theme.text }]}>{label}</Text>
      <Switch
        accessibilityLabel={label}
        value={value}
        onValueChange={onValueChange}
        disabled={disabled}
      />
    </View>
  );
};

/** A button that shows the selected option and opens a menu of all of them. */
export function DemoMenuPicker<T extends string | number | null>({
  label,
  options,
  value,
  onChange,
}: {
  label: string;
  options: { label: string; value: T }[];
  value: T;
  onChange: (value: T) => void;
}) {
  const theme = useDemoTheme();
  const [open, setOpen] = useState(false);
  const selected = options.find((option) => option.value === value);

  return (
    <>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={label}
        accessibilityValue={{ text: selected?.label }}
        onPress={() => setOpen(true)}
        style={[styles.menuButton, { backgroundColor: theme.buttonFill }]}
      >
        <Text style={[styles.buttonText, { color: theme.accent }]}>
          {selected?.label ?? label}
        </Text>
        <Text style={[styles.buttonText, { color: theme.accent }]}>{"⌄"}</Text>
      </Pressable>
      <Modal
        visible={open}
        transparent
        animationType="fade"
        onRequestClose={() => setOpen(false)}
      >
        <Pressable style={styles.backdrop} onPress={() => setOpen(false)}>
          <View style={[styles.menu, { backgroundColor: theme.popover }]}>
            <ScrollView>
              {options.map((option, index) => (
                <Pressable
                  key={String(option.value)}
                  accessibilityRole="menuitem"
                  accessibilityState={{ selected: option.value === value }}
                  onPress={() => {
                    setOpen(false);
                    onChange(option.value);
                  }}
                  style={({ pressed }) => [
                    styles.menuItem,
                    index > 0 && {
                      borderTopWidth: StyleSheet.hairlineWidth,
                      borderTopColor: theme.separator,
                    },
                    pressed && { backgroundColor: theme.buttonFill },
                  ]}
                >
                  <Text style={[styles.menuItemText, { color: theme.text }]}>
                    {option.label}
                  </Text>
                  {option.value === value && (
                    <Text style={[styles.menuItemText, { color: theme.accent }]}>
                      {"✓"}
                    </Text>
                  )}
                </Pressable>
              ))}
            </ScrollView>
          </View>
        </Pressable>
      </Modal>
    </>
  );
}

const styles = StyleSheet.create({
  bordered: {
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 7,
  },
  buttonText: {
    fontSize: 15,
    fontWeight: "500",
  },
  buttonRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
  },
  segments: {
    flexDirection: "row",
    borderRadius: 9,
    padding: 2,
  },
  segment: {
    flex: 1,
    alignItems: "center",
    borderRadius: 7,
    paddingVertical: 6,
  },
  segmentText: {
    fontSize: 13,
  },
  switchRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 12,
  },
  switchLabel: {
    flex: 1,
    fontSize: 17,
  },
  menuButton: {
    alignSelf: "flex-start",
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 7,
  },
  backdrop: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.4)",
    justifyContent: "center",
    paddingHorizontal: 32,
  },
  menu: {
    borderRadius: 14,
    overflow: "hidden",
    maxHeight: "70%",
  },
  menuItem: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 13,
  },
  menuItemText: {
    fontSize: 17,
  },
});
