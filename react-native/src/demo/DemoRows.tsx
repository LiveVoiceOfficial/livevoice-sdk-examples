// Demo scaffolding — not needed for an integration.
// Rows that show a value inside a `DemoSection`, each a single line at its use site.

import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { demoMonospace, useDemoTheme } from "./DemoTheme";

/** A label with its value on the trailing side. */
export const DemoValueRow: React.FC<{ label: string; value: string }> = ({
  label,
  value,
}) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.row}>
      <Text style={[styles.text, { color: theme.secondaryText }]}>{label}</Text>
      <Text style={[styles.text, styles.value, { color: theme.text }]}>
        {value}
      </Text>
    </View>
  );
};

/** A label with your own view, such as a button, on the trailing side. */
export const DemoItemRow: React.FC<{
  label: string;
  children?: React.ReactNode;
}> = ({ label, children }) => {
  const theme = useDemoTheme();
  return (
    <View style={[styles.row, styles.centered]}>
      <Text style={[styles.item, { color: theme.text }]}>{label}</Text>
      {children}
    </View>
  );
};

/** A name from the code, set in monospace, above the text it stands for. */
export const DemoTextRow: React.FC<{ name: string; text: string }> = ({
  name,
  text,
}) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.stack}>
      <Text style={[styles.code, { color: theme.secondaryText }]}>{name}</Text>
      <Text style={[styles.text, { color: theme.text }]}>{text}</Text>
    </View>
  );
};

/** A secondary line that stands in for content that isn't there yet. */
export const DemoPlaceholder: React.FC<{ text: string }> = ({ text }) => {
  const theme = useDemoTheme();
  return (
    <Text style={[styles.text, { color: theme.secondaryText }]}>{text}</Text>
  );
};

/** A small label above a view of your own, such as one of a screen's sample views. */
export const DemoLabeled: React.FC<{
  label: string;
  children: React.ReactNode;
}> = ({ label, children }) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.labeled}>
      <Text style={[styles.label, { color: theme.secondaryText }]}>{label}</Text>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    gap: 12,
  },
  centered: {
    alignItems: "center",
  },
  text: {
    fontSize: 15,
    lineHeight: 20,
  },
  value: {
    flexShrink: 1,
    fontWeight: "500",
    textAlign: "right",
  },
  item: {
    flex: 1,
    fontSize: 17,
  },
  stack: {
    gap: 4,
  },
  code: {
    fontSize: 12,
    fontFamily: demoMonospace,
  },
  labeled: {
    gap: 6,
  },
  label: {
    fontSize: 12,
    fontWeight: "600",
  },
});
