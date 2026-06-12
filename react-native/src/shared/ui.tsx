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

import React, { useState } from "react";
import {
  Image,
  Modal,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from "react-native";
import { useDemoTheme, type DemoTheme } from "../theme";
import {
  useDemoSession,
  customPresetId,
  type DemoCredentials,
} from "./DemoSession";

const logoLight = require("../assets/logo.png");
const logoDark = require("../assets/logo-dark.png");

/**
 * The LiveVoice logo. Uses the dark artwork variant in dark mode.
 */
export const LiveVoiceLogo: React.FC = () => {
  const theme = useDemoTheme();
  return (
    <Image
      source={theme.dark ? logoDark : logoLight}
      style={styles.logo}
      resizeMode="contain"
    />
  );
};

/** A stamped "React Native" pill in the React brand color. */
export const PlatformBadge: React.FC = () => (
  <View style={styles.badge}>
    <Text style={styles.badgeText}>React Native</Text>
  </View>
);

export const SectionHeader: React.FC<{ title: string }> = ({ title }) => {
  const theme = useDemoTheme();
  return (
    <Text style={[styles.sectionHeader, { color: theme.secondaryText }]}>
      {title}
    </Text>
  );
};

export const DemoListSection: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const theme = useDemoTheme();
  return (
    <View style={[styles.card, { backgroundColor: theme.card }]}>
      {children}
    </View>
  );
};

export const DemoListRow: React.FC<{
  title: string;
  summary: string;
  showDivider: boolean;
  onPress: () => void;
}> = ({ title, summary, showDivider, onPress }) => {
  const theme = useDemoTheme();
  return (
    <View>
      <Pressable
        onPress={onPress}
        style={({ pressed }) => [
          styles.row,
          pressed && { backgroundColor: theme.separator },
        ]}
      >
        <View style={styles.rowText}>
          <Text style={[styles.rowTitle, { color: theme.text }]}>{title}</Text>
          <Text style={[styles.rowSummary, { color: theme.secondaryText }]}>
            {summary}
          </Text>
        </View>
        <Text style={[styles.chevron, { color: theme.chevron }]}>{"›"}</Text>
      </Pressable>
      {showDivider && (
        <View
          style={[
            styles.divider,
            { backgroundColor: theme.separator },
          ]}
        />
      )}
    </View>
  );
};

/**
 * Button + modal menu for switching the active API key preset. Available from
 * the home screen and every demo screen's navigation bar.
 */
export const DemoApiKeyMenu: React.FC = () => {
  const theme = useDemoTheme();
  const {
    presets,
    selectedPreset,
    selectPreset,
    customCredentials,
    applyCustomCredentials,
  } = useDemoSession();
  const [open, setOpen] = useState(false);
  const [editorOpen, setEditorOpen] = useState(false);

  const customSelected = selectedPreset.id === customPresetId;
  const customSummary =
    customCredentials != null
      ? `Join code ${customCredentials.joinCode} · tap to edit.`
      : "Enter your own join code and API key.";

  return (
    <>
      <Pressable
        onPress={() => setOpen(true)}
        hitSlop={8}
        style={styles.apiKeyButton}
      >
        <Text style={[styles.apiKeyButtonText, { color: theme.text }]}>
          API key {"▾"}
        </Text>
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
              {presets.map((preset, index) => {
                const selected = preset.id === selectedPreset.id;
                return (
                  <Pressable
                    key={preset.id}
                    onPress={() => {
                      selectPreset(preset);
                      setOpen(false);
                    }}
                    style={({ pressed }) => [
                      styles.menuItem,
                      index > 0 && {
                        borderTopWidth: StyleSheet.hairlineWidth,
                        borderTopColor: theme.separator,
                      },
                      pressed && { backgroundColor: theme.separator },
                    ]}
                  >
                    <View style={styles.menuItemText}>
                      <Text style={[styles.menuItemTitle, { color: theme.text }]}>
                        {preset.title}
                      </Text>
                      <Text
                        style={[
                          styles.menuItemSummary,
                          { color: theme.secondaryText },
                        ]}
                      >
                        {preset.summary}
                      </Text>
                    </View>
                    {selected && (
                      <Text style={[styles.check, { color: theme.primary }]}>
                        {"✓"}
                      </Text>
                    )}
                  </Pressable>
                );
              })}

              <Pressable
                onPress={() => {
                  setOpen(false);
                  setEditorOpen(true);
                }}
                style={({ pressed }) => [
                  styles.menuItem,
                  {
                    borderTopWidth: StyleSheet.hairlineWidth,
                    borderTopColor: theme.separator,
                  },
                  pressed && { backgroundColor: theme.separator },
                ]}
              >
                <View style={styles.menuItemText}>
                  <Text style={[styles.menuItemTitle, { color: theme.text }]}>
                    Use your own event
                  </Text>
                  <Text
                    style={[
                      styles.menuItemSummary,
                      { color: theme.secondaryText },
                    ]}
                  >
                    {customSummary}
                  </Text>
                </View>
                {customSelected && (
                  <Text style={[styles.check, { color: theme.primary }]}>
                    {"✓"}
                  </Text>
                )}
              </Pressable>
            </ScrollView>
          </View>
        </Pressable>
      </Modal>

      <DemoCustomCredentialsEditor
        visible={editorOpen}
        initial={customCredentials}
        onClose={() => setEditorOpen(false)}
        onUse={(credentials) => {
          setEditorOpen(false);
          applyCustomCredentials(credentials);
        }}
      />
    </>
  );
};

/**
 * Modal editor for the "Use your own event" credentials. Lets a tester join
 * their own LiveVoice event with their own join code + API key (and optional
 * password) without rebuilding the sample.
 */
const DemoCustomCredentialsEditor: React.FC<{
  visible: boolean;
  initial: DemoCredentials | null;
  onClose: () => void;
  onUse: (credentials: DemoCredentials) => void;
}> = ({ visible, initial, onClose, onUse }) => {
  const theme = useDemoTheme();
  const [joinCode, setJoinCode] = useState("");
  const [apiKey, setApiKey] = useState("");
  const [password, setPassword] = useState("");

  React.useEffect(() => {
    if (visible) {
      setJoinCode(initial?.joinCode ?? "");
      setApiKey(initial?.apiKey ?? "");
      setPassword(initial?.password ?? "");
    }
  }, [visible, initial]);

  const canUse = joinCode.trim().length > 0 && apiKey.trim().length > 0;

  const fieldStyle = [
    styles.editorField,
    { color: theme.text, borderColor: theme.popoverBorder },
  ];

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onClose}
    >
      <Pressable style={styles.modalBackdrop} onPress={onClose}>
        <Pressable
          style={[
            styles.editor,
            { backgroundColor: theme.popover, borderColor: theme.popoverBorder },
          ]}
          onPress={() => {}}
        >
          <Text style={[styles.editorTitle, { color: theme.text }]}>
            Use your own event
          </Text>
          <Text style={[styles.editorHint, { color: theme.secondaryText }]}>
            Enter the join code and API key for your own LiveVoice event. The
            password is only needed for password-protected events.
          </Text>

          <TextInput
            value={joinCode}
            onChangeText={setJoinCode}
            placeholder="Join code"
            placeholderTextColor={theme.secondaryText}
            keyboardType="number-pad"
            autoCapitalize="none"
            autoCorrect={false}
            style={fieldStyle}
          />
          <TextInput
            value={apiKey}
            onChangeText={setApiKey}
            placeholder="API key"
            placeholderTextColor={theme.secondaryText}
            autoCapitalize="none"
            autoCorrect={false}
            style={fieldStyle}
          />
          <TextInput
            value={password}
            onChangeText={setPassword}
            placeholder="Password (optional)"
            placeholderTextColor={theme.secondaryText}
            secureTextEntry
            autoCapitalize="none"
            autoCorrect={false}
            style={fieldStyle}
          />

          <View style={styles.editorActions}>
            <Pressable hitSlop={8} onPress={onClose}>
              <Text style={[styles.editorAction, { color: theme.secondaryText }]}>
                Cancel
              </Text>
            </Pressable>
            <Pressable
              hitSlop={8}
              disabled={!canUse}
              onPress={() =>
                onUse({
                  joinCode: joinCode.trim(),
                  password,
                  apiKey: apiKey.trim(),
                })
              }
            >
              <Text
                style={[
                  styles.editorAction,
                  { color: canUse ? theme.primary : theme.secondaryText },
                ]}
              >
                Use
              </Text>
            </Pressable>
          </View>
        </Pressable>
      </Pressable>
    </Modal>
  );
};

const styles = StyleSheet.create({
  logo: {
    width: 129.5,
    aspectRatio: 129.5 / 88.7,
  },
  badge: {
    backgroundColor: "#61DAFB",
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  badgeText: {
    color: "#20232A",
    fontSize: 13,
    fontWeight: "700",
  },
  sectionHeader: {
    fontSize: 15,
    fontWeight: "600",
    marginLeft: 4,
    marginBottom: 8,
  },
  card: {
    borderRadius: 16,
    overflow: "hidden",
  },
  row: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  rowText: {
    flex: 1,
    gap: 2,
  },
  rowTitle: {
    fontSize: 17,
    fontWeight: "600",
  },
  rowSummary: {
    fontSize: 14,
    lineHeight: 19,
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
  apiKeyButton: {
    paddingVertical: 6,
    paddingHorizontal: 4,
  },
  apiKeyButtonText: {
    fontSize: 16,
    fontWeight: "500",
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
  menuItem: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  menuItemText: {
    flex: 1,
    gap: 2,
  },
  menuItemTitle: {
    fontSize: 16,
    fontWeight: "600",
  },
  menuItemSummary: {
    fontSize: 13,
  },
  check: {
    fontSize: 18,
    fontWeight: "700",
    marginLeft: 12,
  },
  editor: {
    borderRadius: 14,
    borderWidth: StyleSheet.hairlineWidth,
    padding: 20,
    gap: 12,
    shadowColor: "#000",
    shadowOpacity: 0.3,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 },
    elevation: 12,
  },
  editorTitle: {
    fontSize: 17,
    fontWeight: "600",
  },
  editorHint: {
    fontSize: 13,
  },
  editorField: {
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
  },
  editorActions: {
    flexDirection: "row",
    justifyContent: "flex-end",
    gap: 24,
    marginTop: 4,
  },
  editorAction: {
    fontSize: 16,
    fontWeight: "600",
  },
});
