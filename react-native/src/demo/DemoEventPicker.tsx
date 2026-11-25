// Demo scaffolding — not needed for an integration.
// The header's event picker: the demo API keys, your own event's credentials,
// and the sheet that picks them.

import React, { useEffect, useState } from "react";
import {
  KeyboardAvoidingView,
  Modal,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from "react-native";
import { DemoFixture, type DemoCredentials } from "./DemoFixture";
import { useDemoSession } from "./DemoSession";
import { useDemoTheme } from "./DemoTheme";

/** The header button that opens the picker. */
export const DemoApiKeyMenu: React.FC = () => {
  const theme = useDemoTheme();
  const { presentPicker } = useDemoSession();
  return (
    <Pressable
      accessibilityRole="button"
      hitSlop={8}
      onPress={() => presentPicker("apiKeys")}
    >
      <Text style={[styles.menuButton, { color: theme.accent }]}>
        API key {"⌄"}
      </Text>
    </Pressable>
  );
};

/**
 * The demo event's three API keys, each with what it permits; tapping one
 * joins the demo event with it.
 */
export const DemoApiKeyPresetList: React.FC<{ onSelect?: () => void }> = ({
  onSelect,
}) => {
  const { selectedPreset, select } = useDemoSession();
  return (
    <View>
      {DemoFixture.apiKeyPresets.map((preset, index) => (
        <DemoPickerRow
          key={preset.id}
          title={preset.title}
          summary={preset.summary}
          isSelected={selectedPreset.id === preset.id}
          showsDivider={index > 0}
          onPress={() => {
            select(preset);
            onSelect?.();
          }}
        />
      ))}
    </View>
  );
};

/**
 * The picker's sheet: the API keys and "Use your own event", or the editor
 * for your own event's credentials. Rendered once, next to the navigation.
 * One modal switches its content, so the editor never has to open while the
 * picker still closes.
 */
export const DemoEventPickerModal: React.FC = () => {
  const theme = useDemoTheme();
  const { picker, presentPicker, customCredentials, selectedPreset } =
    useDemoSession();
  const close = () => presentPicker(null);

  return (
    <Modal
      visible={picker !== null}
      transparent
      animationType="fade"
      onRequestClose={close}
    >
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === "ios" ? "padding" : undefined}
      >
        <Pressable style={styles.backdrop} onPress={close}>
          {/* Taps inside the sheet don't close it. */}
          <Pressable
            style={[styles.sheet, { backgroundColor: theme.popover }]}
            onPress={() => {}}
          >
            {picker === "ownEvent" ? (
              <DemoCustomCredentialsEditor
                credentials={customCredentials}
                onDone={close}
              />
            ) : (
              <>
                <DemoApiKeyPresetList onSelect={close} />
                <DemoPickerRow
                  title="Use your own event"
                  summary={
                    customCredentials
                      ? `Join code ${customCredentials.joinCode} · tap to edit.`
                      : "Enter your own join code and API key."
                  }
                  isSelected={selectedPreset.id === DemoFixture.customPresetId}
                  showsDivider
                  onPress={() => presentPicker("ownEvent")}
                />
              </>
            )}
          </Pressable>
        </Pressable>
      </KeyboardAvoidingView>
    </Modal>
  );
};

const DemoPickerRow: React.FC<{
  title: string;
  summary: string;
  isSelected: boolean;
  showsDivider: boolean;
  onPress: () => void;
}> = ({ title, summary, isSelected, showsDivider, onPress }) => {
  const theme = useDemoTheme();
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected: isSelected }}
      onPress={onPress}
      style={({ pressed }) => [
        styles.pickerRow,
        showsDivider && {
          borderTopWidth: StyleSheet.hairlineWidth,
          borderTopColor: theme.separator,
        },
        pressed && { opacity: 0.5 },
      ]}
    >
      <View style={styles.flex}>
        <Text style={[styles.rowTitle, { color: theme.text }]}>{title}</Text>
        <Text style={[styles.rowSummary, { color: theme.secondaryText }]}>
          {summary}
        </Text>
      </View>
      <Text
        style={[
          styles.check,
          { color: theme.accent, opacity: isSelected ? 1 : 0 },
        ]}
      >
        {"✓"}
      </Text>
    </Pressable>
  );
};

/**
 * Editor for the "Use your own event" credentials. Lets a tester join their
 * own LiveVoice event with their own join code + API key (and optional
 * password) without rebuilding the sample.
 */
const DemoCustomCredentialsEditor: React.FC<{
  credentials: DemoCredentials | null;
  onDone: () => void;
}> = ({ credentials, onDone }) => {
  const theme = useDemoTheme();
  const { applyCustomCredentials } = useDemoSession();
  const [joinCode, setJoinCode] = useState(credentials?.joinCode ?? "");
  const [apiKey, setApiKey] = useState(credentials?.apiKey ?? "");
  const [password, setPassword] = useState(credentials?.password ?? "");

  // The saved credentials load after launch; pre-fill once they arrive.
  useEffect(() => {
    if (credentials == null) return;
    setJoinCode(credentials.joinCode);
    setApiKey(credentials.apiKey);
    setPassword(credentials.password);
  }, [credentials]);

  const canUse = joinCode.trim() !== "" && apiKey.trim() !== "";
  const field = [
    styles.field,
    { color: theme.text, borderColor: theme.separator },
  ];

  return (
    <View style={styles.editor}>
      <Text style={[styles.editorTitle, { color: theme.text }]}>
        Use your own event
      </Text>
      <TextInput
        value={joinCode}
        onChangeText={setJoinCode}
        placeholder="Join code"
        placeholderTextColor={theme.secondaryText}
        // Join codes have digits and letters, in any case.
        keyboardType="ascii-capable"
        autoCapitalize="characters"
        autoCorrect={false}
        style={field}
      />
      <TextInput
        value={apiKey}
        onChangeText={setApiKey}
        placeholder="API key"
        placeholderTextColor={theme.secondaryText}
        autoCapitalize="none"
        autoCorrect={false}
        style={field}
      />
      <TextInput
        value={password}
        onChangeText={setPassword}
        placeholder="Password (optional)"
        placeholderTextColor={theme.secondaryText}
        secureTextEntry
        autoCapitalize="none"
        autoCorrect={false}
        style={field}
      />
      <Text style={[styles.rowSummary, { color: theme.secondaryText }]}>
        Enter the join code and API key for your own LiveVoice event. The
        password is only needed for password-protected events.
      </Text>
      <View style={styles.editorActions}>
        <Pressable accessibilityRole="button" hitSlop={8} onPress={onDone}>
          <Text style={[styles.action, { color: theme.accent }]}>Cancel</Text>
        </Pressable>
        <Pressable
          accessibilityRole="button"
          accessibilityState={{ disabled: !canUse }}
          hitSlop={8}
          disabled={!canUse}
          onPress={() => {
            applyCustomCredentials({
              joinCode: joinCode.trim(),
              apiKey: apiKey.trim(),
              password,
            });
            onDone();
          }}
        >
          <Text
            style={[
              styles.action,
              styles.confirm,
              { color: canUse ? theme.accent : theme.secondaryText },
            ]}
          >
            Use
          </Text>
        </Pressable>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  flex: {
    flex: 1,
  },
  menuButton: {
    fontSize: 15,
    fontWeight: "500",
  },
  backdrop: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.4)",
    justifyContent: "center",
    paddingHorizontal: 24,
  },
  sheet: {
    borderRadius: 14,
    paddingHorizontal: 20,
    paddingVertical: 8,
  },
  pickerRow: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 12,
    paddingVertical: 12,
  },
  rowTitle: {
    fontSize: 15,
    fontWeight: "600",
  },
  rowSummary: {
    fontSize: 12,
    lineHeight: 16,
    marginTop: 2,
  },
  check: {
    fontSize: 14,
    fontWeight: "700",
  },
  editor: {
    gap: 12,
    paddingVertical: 12,
  },
  editorTitle: {
    fontSize: 17,
    fontWeight: "600",
    textAlign: "center",
  },
  field: {
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 17,
  },
  editorActions: {
    flexDirection: "row",
    justifyContent: "space-between",
  },
  action: {
    fontSize: 17,
  },
  confirm: {
    fontWeight: "600",
  },
});
