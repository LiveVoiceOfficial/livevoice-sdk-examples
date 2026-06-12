/*
 * This source file is part of the LiveVoice SDK project
 *
 * Copyright (c) LiveVoice GmbH
 * Licensed under the MIT license
 *
 * See LICENSE for license information
 *
 * SPDX-License-Identifier: MIT
 */

import React, { useEffect, useRef, useState } from "react";
import {
  Animated,
  Modal,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from "react-native";
import { useDemoTheme } from "../theme";

/** Scrollable page container for a demo screen (the nav bar provides the title). */
export const DemoScreen: React.FC<{
  summary: string;
  children: React.ReactNode;
}> = ({ summary, children }) => {
  const theme = useDemoTheme();
  return (
    <ScrollView
      style={{ backgroundColor: theme.pageBackground }}
      contentContainerStyle={styles.page}
    >
      <Text style={[styles.summary, { color: theme.secondaryText }]}>
        {summary}
      </Text>
      {children}
    </ScrollView>
  );
};

export const DemoCardSection: React.FC<{
  title: string;
  children: React.ReactNode;
}> = ({ title, children }) => {
  const theme = useDemoTheme();
  return (
    <View style={[styles.cardSection, { backgroundColor: theme.sectionCard }]}>
      <Text style={[styles.cardTitle, { color: theme.text }]}>{title}</Text>
      {children}
    </View>
  );
};

export const DemoNotes: React.FC<{ notes: string[] }> = ({ notes }) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.notes}>
      {notes.map((note, index) => (
        <Text key={index} style={[styles.note, { color: theme.secondaryText }]}>
          {note}
        </Text>
      ))}
    </View>
  );
};

/** A placeholder shown in a subtitle view while no channel is providing subtitles. */
export const DemoSubtitleUnavailableHint: React.FC = () => {
  const theme = useDemoTheme();
  return (
    <View style={styles.hint}>
      <Text style={[styles.hintText, { color: theme.secondaryText }]}>
        Your channels need to provide subtitles to see them here.
      </Text>
    </View>
  );
};

/** A small grey info banner, e.g. to flag a platform limitation on a screen. */
export const DemoBanner: React.FC<{ text: string }> = ({ text }) => {
  const theme = useDemoTheme();
  return (
    <View style={styles.hint}>
      <Text style={[styles.hintText, { color: theme.secondaryText }]}>
        {text}
      </Text>
    </View>
  );
};

/** Fades its children in on mount; pair with a changing `key` to cross over. */
export const DemoFadeIn: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const opacity = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,
    }).start();
  }, [opacity]);
  return <Animated.View style={{ opacity }}>{children}</Animated.View>;
};

export interface SegmentOption<T> {
  label: string;
  value: T;
}

export function SegmentedControl<T extends string | number>({
  options,
  value,
  onChange,
}: {
  options: SegmentOption<T>[];
  value: T;
  onChange: (value: T) => void;
}) {
  const theme = useDemoTheme();
  return (
    <View style={[styles.segment, { backgroundColor: theme.separator }]}>
      {options.map((option) => {
        const selected = option.value === value;
        return (
          <Pressable
            key={String(option.value)}
            onPress={() => onChange(option.value)}
            style={[
              styles.segmentItem,
              selected && { backgroundColor: theme.liveSample },
            ]}
          >
            <Text
              style={{
                fontSize: 13,
                fontWeight: selected ? "600" : "400",
                color: theme.text,
              }}
            >
              {option.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

export interface MenuOption {
  id: string | number | null;
  title: string;
  subtitle?: string;
  sectionTitle?: string;
}

/** Button + modal menu, used for the subtitle source and featured-source pickers. */
export function MenuPicker({
  selectedLabel,
  options,
  selectedId,
  onSelect,
  enabled = true,
}: {
  selectedLabel: string;
  options: MenuOption[];
  selectedId: string | number | null;
  onSelect: (id: string | number | null) => void;
  enabled?: boolean;
}) {
  const theme = useDemoTheme();
  const [open, setOpen] = useState(false);

  return (
    <>
      <Pressable
        onPress={() => enabled && setOpen(true)}
        style={[
          styles.pickerButton,
          { borderColor: theme.separator, opacity: enabled ? 1 : 0.5 },
        ]}
      >
        <Text style={{ color: theme.text, fontSize: 15 }}>{selectedLabel}</Text>
        <Text style={{ color: theme.secondaryText, fontSize: 15 }}>{"▾"}</Text>
      </Pressable>

      <Modal
        visible={open}
        transparent
        animationType="fade"
        onRequestClose={() => setOpen(false)}
      >
        <Pressable style={styles.modalBackdrop} onPress={() => setOpen(false)}>
          <View
            style={[
              styles.menu,
              {
                backgroundColor: theme.popover,
                borderColor: theme.popoverBorder,
              },
            ]}
          >
            <ScrollView>
              {options.map((option, index) => {
                const selected = option.id === selectedId;
                return (
                  <View key={`${option.id}-${index}`}>
                    {option.sectionTitle != null && (
                      <Text
                        style={[
                          styles.menuSection,
                          { color: theme.secondaryText },
                        ]}
                      >
                        {option.sectionTitle}
                      </Text>
                    )}
                    <Pressable
                      onPress={() => {
                        onSelect(option.id);
                        setOpen(false);
                      }}
                      style={({ pressed }) => [
                        styles.menuItem,
                        pressed && { backgroundColor: theme.separator },
                      ]}
                    >
                      <View style={{ flex: 1 }}>
                        <Text style={{ color: theme.text, fontSize: 16 }}>
                          {option.title}
                        </Text>
                        {option.subtitle != null && (
                          <Text
                            style={{ color: theme.secondaryText, fontSize: 13 }}
                          >
                            {option.subtitle}
                          </Text>
                        )}
                      </View>
                      {selected && (
                        <Text style={{ color: theme.primary, fontSize: 16 }}>
                          {"✓"}
                        </Text>
                      )}
                    </Pressable>
                  </View>
                );
              })}
            </ScrollView>
          </View>
        </Pressable>
      </Modal>
    </>
  );
}

const styles = StyleSheet.create({
  page: {
    padding: 20,
    gap: 24,
  },
  summary: {
    fontSize: 16,
    lineHeight: 22,
  },
  cardSection: {
    borderRadius: 16,
    padding: 16,
    gap: 12,
  },
  cardTitle: {
    fontSize: 17,
    fontWeight: "600",
  },
  notes: {
    gap: 8,
  },
  note: {
    fontSize: 15,
    lineHeight: 20,
  },
  hint: {
    padding: 14,
    borderRadius: 14,
    backgroundColor: "rgba(128,128,128,0.15)",
  },
  hintText: {
    fontSize: 14,
    lineHeight: 19,
  },
  segment: {
    flexDirection: "row",
    borderRadius: 8,
    padding: 2,
  },
  segmentItem: {
    flex: 1,
    paddingVertical: 7,
    borderRadius: 7,
    alignItems: "center",
  },
  pickerButton: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    borderWidth: 1,
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 11,
  },
  modalBackdrop: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.5)",
    justifyContent: "center",
    paddingHorizontal: 32,
  },
  menu: {
    borderRadius: 14,
    overflow: "hidden",
    maxHeight: "70%",
    borderWidth: StyleSheet.hairlineWidth,
    shadowColor: "#000",
    shadowOpacity: 0.3,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 },
    elevation: 12,
  },
  menuSection: {
    fontSize: 12,
    fontWeight: "600",
    textTransform: "uppercase",
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 4,
  },
  menuItem: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
});
