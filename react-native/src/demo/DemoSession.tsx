// Demo scaffolding — not needed for an integration.
// Initializes the SDK once, then joins the event picked in the header at
// launch and whenever the pick changes.

import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import { StyleSheet, Text, View } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import {
  initialize,
  joinEvent,
  type LiveVoiceError,
} from "livevoice-sdk-react-native";
import {
  DemoFixture,
  type DemoApiKeyPreset,
  type DemoCredentials,
} from "./DemoFixture";
import { useDemoTheme } from "./DemoTheme";

/** Which of the event picker's sheets shows. */
export type DemoPicker = "apiKeys" | "ownEvent" | null;

interface DemoSessionValue {
  selectedPreset: DemoApiKeyPreset;
  select(preset: DemoApiKeyPreset): void;
  /** Whether the picked event is your own rather than the demo event. */
  usesOwnEvent: boolean;
  /** Last credentials a tester entered via "Use your own event". */
  customCredentials: DemoCredentials | null;
  /**
   * Applies credentials entered in the editor: persists them, selects the
   * custom event, and (re)joins. An empty password means "no password".
   */
  applyCustomCredentials(credentials: DemoCredentials): void;
  picker: DemoPicker;
  presentPicker(picker: DemoPicker): void;
}

const DemoSessionContext = createContext<DemoSessionValue | undefined>(
  undefined,
);

const customCredentialsKey = "DemoSession.customCredentials";

function samePreset(a: DemoApiKeyPreset, b: DemoApiKeyPreset): boolean {
  return (
    a.id === b.id &&
    a.joinCode === b.joinCode &&
    a.password === b.password &&
    a.apiKey === b.apiKey
  );
}

export const DemoSessionProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const theme = useDemoTheme();
  const [initialized, setInitialized] = useState(false);
  const [initializeError, setInitializeError] = useState<unknown>();
  const [selectedPreset, setSelectedPreset] = useState(
    DemoFixture.defaultPreset,
  );
  const [customCredentials, setCustomCredentials] =
    useState<DemoCredentials | null>(null);
  const [picker, presentPicker] = useState<DemoPicker>(null);

  // Once, at launch, with the default options. Commands before it reject
  // with `not_initialized`; the Lock screen screen initializes again with
  // other options.
  useEffect(() => {
    let active = true;
    initialize().then(
      () => active && setInitialized(true),
      (error: unknown) => active && setInitializeError(error),
    );
    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    AsyncStorage.getItem(customCredentialsKey)
      .then((raw) => {
        if (raw != null) setCustomCredentials(JSON.parse(raw));
      })
      .catch(() => {});
  }, []);

  // Joining again leaves the previous event, so there is nothing to leave
  // here; a newer join rejects a pending one with `superseded`.
  useEffect(() => {
    if (!initialized) return;
    const { joinCode, password, apiKey } = selectedPreset;
    joinEvent({ joinCode, password, apiKey }).catch((error: LiveVoiceError) => {
      // LiveVoiceView displays connection failures. Never log credentials.
      if (error.code !== "cancelled" && error.code !== "superseded") {
        console.warn(`LiveVoice join failed: ${error.code}`);
      }
    });
  }, [initialized, selectedPreset]);

  const select = useCallback((preset: DemoApiKeyPreset) => {
    setSelectedPreset((current) =>
      samePreset(current, preset) ? current : preset,
    );
  }, []);

  const applyCustomCredentials = useCallback(
    (credentials: DemoCredentials) => {
      setCustomCredentials(credentials);
      AsyncStorage.setItem(
        customCredentialsKey,
        JSON.stringify(credentials),
      ).catch(() => {});
      select(DemoFixture.customPreset(credentials));
    },
    [select],
  );

  const value = useMemo<DemoSessionValue>(
    () => ({
      selectedPreset,
      select,
      usesOwnEvent: selectedPreset.id === DemoFixture.customPresetId,
      customCredentials,
      applyCustomCredentials,
      picker,
      presentPicker,
    }),
    [selectedPreset, select, customCredentials, applyCustomCredentials, picker],
  );

  if (!initialized) {
    return (
      <View style={[styles.launch, { backgroundColor: theme.pageBackground }]}>
        <Text style={{ color: theme.secondaryText }}>
          {initializeError
            ? `Unable to initialize LiveVoice: ${describeLaunchError(initializeError)}`
            : "Initializing LiveVoice…"}
        </Text>
      </View>
    );
  }
  return (
    <DemoSessionContext.Provider value={value}>
      {children}
    </DemoSessionContext.Provider>
  );
};

export function useDemoSession(): DemoSessionValue {
  const value = useContext(DemoSessionContext);
  if (value == null) {
    throw new Error("useDemoSession must be used within a DemoSessionProvider");
  }
  return value;
}

const styles = StyleSheet.create({
  launch: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    padding: 24,
  },
});

/**
 * The launch error with its code: errors that point at a setup mistake, such
 * as `unsupported_sdk`, carry only a generic message, and the code says what
 * went wrong. Anything that isn't the SDK's error shows its type.
 */
function describeLaunchError(error: unknown): string {
  const sdkError = error as Partial<LiveVoiceError> | undefined;
  if (sdkError?.code) return `${sdkError.message} (${sdkError.code})`;
  if (error instanceof Error) return `${error.name}: ${error.message}`;
  return String(error);
}
