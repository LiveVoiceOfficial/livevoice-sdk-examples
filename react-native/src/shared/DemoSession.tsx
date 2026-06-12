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

import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { joinEvent } from "livevoice-sdk-react-native";
import { DemoFixture, type DemoApiKeyPreset } from "./DemoFixture";

/** Identifies the dynamic "Use your own event" selection. */
export const customPresetId = "custom";

const storageKey = "demo.customCredentials";

/**
 * User-entered credentials for the "Use your own event" picker option. Persisted
 * so the editor pre-fills on reopen.
 */
export interface DemoCredentials {
  joinCode: string;
  /** Empty string means "no password"; some events are password-protected. */
  password: string;
  apiKey: string;
}

/**
 * Builds the dynamic preset selected when a tester enters their own event
 * credentials.
 */
export function buildCustomPreset(
  credentials: DemoCredentials,
): DemoApiKeyPreset {
  return {
    id: customPresetId,
    title: "Your own event",
    summary: `Join code ${credentials.joinCode} with your own API key.`,
    apiKey: credentials.apiKey,
  };
}

interface DemoSessionValue {
  presets: DemoApiKeyPreset[];
  selectedPreset: DemoApiKeyPreset;
  selectPreset: (preset: DemoApiKeyPreset) => void;
  customCredentials: DemoCredentials | null;
  applyCustomCredentials: (credentials: DemoCredentials) => void;
}

const DemoSessionContext = createContext<DemoSessionValue | undefined>(
  undefined,
);

/**
 * Owns the currently selected API key preset and (re)joins the demo event
 * whenever it changes.
 */
export const DemoSessionProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [selectedPreset, setSelectedPreset] = useState<DemoApiKeyPreset>(
    DemoFixture.defaultPreset,
  );
  const [customCredentials, setCustomCredentials] =
    useState<DemoCredentials | null>(null);
  const customCredentialsRef = useRef<DemoCredentials | null>(null);

  useEffect(() => {
    let cancelled = false;
    AsyncStorage.getItem(storageKey)
      .then((raw) => {
        if (cancelled || raw == null) return;
        const credentials = JSON.parse(raw) as DemoCredentials;
        customCredentialsRef.current = credentials;
        setCustomCredentials(credentials);
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    const credentials = customCredentialsRef.current;
    if (selectedPreset.id === customPresetId && credentials != null) {
      joinEvent(
        credentials.joinCode,
        credentials.password.length > 0 ? credentials.password : null,
        credentials.apiKey,
      );
    } else {
      joinEvent(
        DemoFixture.joinCode,
        DemoFixture.password,
        selectedPreset.apiKey,
      );
    }
  }, [selectedPreset]);

  const applyCustomCredentials = useCallback((credentials: DemoCredentials) => {
    customCredentialsRef.current = credentials;
    setCustomCredentials(credentials);
    AsyncStorage.setItem(storageKey, JSON.stringify(credentials)).catch(
      () => {},
    );
    setSelectedPreset(buildCustomPreset(credentials));
  }, []);

  const value = useMemo<DemoSessionValue>(
    () => ({
      presets: DemoFixture.apiKeyPresets,
      selectedPreset,
      selectPreset: setSelectedPreset,
      customCredentials,
      applyCustomCredentials,
    }),
    [selectedPreset, customCredentials, applyCustomCredentials],
  );

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
