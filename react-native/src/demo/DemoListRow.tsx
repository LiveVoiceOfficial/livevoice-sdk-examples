// Demo scaffolding — not needed for an integration.
// A row of the home list.

import React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { useDemoTheme } from "./DemoTheme";

/**
 * A row of the demo list. `needsOwnEvent` tags a demo that the demo event
 * cannot show, so nobody opens it and wonders why nothing happens.
 */
export const DemoListRow: React.FC<{
  title: string;
  summary: string;
  needsOwnEvent?: boolean;
  showsDivider: boolean;
  onPress: () => void;
}> = ({ title, summary, needsOwnEvent = false, showsDivider, onPress }) => {
  const theme = useDemoTheme();
  return (
    <View>
      <Pressable
        accessibilityRole="button"
        onPress={onPress}
        style={({ pressed }) => [
          styles.row,
          pressed && { backgroundColor: theme.buttonFill },
        ]}
      >
        <View style={styles.text}>
          <View style={styles.titleLine}>
            <Text style={[styles.title, { color: theme.text }]}>{title}</Text>
            {needsOwnEvent && (
              <Text
                style={[
                  styles.tag,
                  { color: theme.orange, backgroundColor: `${theme.orange}26` },
                ]}
              >
                Own event
              </Text>
            )}
          </View>
          <Text style={[styles.summary, { color: theme.secondaryText }]}>
            {summary}
          </Text>
        </View>
        <Text style={[styles.chevron, { color: theme.gray }]}>{"›"}</Text>
      </Pressable>
      {showsDivider && (
        <View style={[styles.divider, { backgroundColor: theme.separator }]} />
      )}
    </View>
  );
};

/** A group of `DemoListRow`s under a title, like an inset grouped list's section. */
export const DemoListSection: React.FC<{
  title: string;
  children: React.ReactNode;
}> = ({ title, children }) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.section}>
      <Text
        accessibilityRole="header"
        style={[styles.sectionTitle, { color: theme.secondaryText }]}
      >
        {title.toUpperCase()}
      </Text>
      <View style={[styles.sectionBox, { backgroundColor: theme.listRow }]}>
        {children}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 11,
  },
  text: {
    flex: 1,
    gap: 6,
  },
  titleLine: {
    flexDirection: "row",
    alignItems: "center",
    flexWrap: "wrap",
    gap: 8,
  },
  title: {
    fontSize: 17,
    fontWeight: "600",
  },
  tag: {
    fontSize: 12,
    fontWeight: "600",
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 999,
    overflow: "hidden",
  },
  summary: {
    fontSize: 15,
    lineHeight: 20,
  },
  chevron: {
    fontSize: 22,
    fontWeight: "600",
    marginLeft: 12,
  },
  divider: {
    height: StyleSheet.hairlineWidth,
    marginLeft: 16,
  },
  section: {
    gap: 8,
  },
  sectionTitle: {
    fontSize: 13,
    fontWeight: "500",
    paddingHorizontal: 16,
  },
  sectionBox: {
    borderRadius: 10,
    overflow: "hidden",
  },
});

/** The platform's badge in the home screen's header, as in the other samples. */
export const DemoPlatformBadge: React.FC = () => (
  <View style={badgeStyles.badge}>
    <Text style={badgeStyles.text}>React Native</Text>
  </View>
);

const badgeStyles = StyleSheet.create({
  badge: { backgroundColor: "#61DAFB", borderRadius: 999, paddingHorizontal: 10, paddingVertical: 4 },
  text: { color: "#20232A", fontSize: 13, fontWeight: "700" },
});
