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

export interface DemoApiKeyPreset {
  id: string;
  title: string;
  summary: string;
  apiKey: string;
}

// The public demo event (123456, no password) with its three documented keys.
const defaultPreset: DemoApiKeyPreset = {
  id: "default",
  title: "Default",
  summary: "Branding visible, custom UI disabled.",
  apiKey: "HD4cQklUOQKOBWimG54j2kRnxFklDL",
};

const hideBrandingPreset: DemoApiKeyPreset = {
  id: "hide-branding",
  title: "Hide branding",
  summary: "Branding hidden, custom UI disabled.",
  apiKey: "uFlkcGkUJEcb7jK6qFcdygreFRTXVh",
};

const fullCustomizationPreset: DemoApiKeyPreset = {
  id: "full-customization",
  title: "Full customization",
  summary: "Branding hidden, custom UI enabled.",
  apiKey: "s09WEG5y3caQ6R2PDaG4i8R1aTooTd",
};

export const DemoFixture = {
  joinCode: "123456",
  password: null as string | null,
  apiKeyPresets: [defaultPreset, hideBrandingPreset, fullCustomizationPreset],
  defaultPreset,
};
