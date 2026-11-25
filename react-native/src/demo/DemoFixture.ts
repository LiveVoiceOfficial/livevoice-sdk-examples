// Demo scaffolding — not needed for an integration.
// The demo event's join code, its three API keys, and your own event's credentials.

export interface DemoApiKeyPreset {
  id: string;
  title: string;
  summary: string;
  joinCode: string;
  password: string | null;
  apiKey: string;
}

/**
 * User-entered credentials for the "Use your own event" picker option.
 * Persisted so the editor pre-fills on reopen; see `DemoSession`.
 */
export interface DemoCredentials {
  joinCode: string;
  /** Empty string means "no password"; some events are password-protected. */
  password: string;
  apiKey: string;
}

const joinCode = "123456";
const password: string | null = null;

/**
 * Identifies the dynamic "Use your own event" selection (built from
 * user-entered `DemoCredentials`, not part of `apiKeyPresets`).
 */
const customPresetId = "custom";

const defaultPreset: DemoApiKeyPreset = {
  id: "default",
  title: "Default",
  summary: "Branding visible, custom UI disabled.",
  joinCode,
  password,
  apiKey: "HD4cQklUOQKOBWimG54j2kRnxFklDL",
};

const hideBrandingPreset: DemoApiKeyPreset = {
  id: "hide-branding",
  title: "Hide branding",
  summary: "Branding hidden, custom UI disabled.",
  joinCode,
  password,
  apiKey: "uFlkcGkUJEcb7jK6qFcdygreFRTXVh",
};

const fullCustomizationPreset: DemoApiKeyPreset = {
  id: "full-customization",
  title: "Full customization",
  summary: "Branding hidden, custom UI enabled.",
  joinCode,
  password,
  apiKey: "s09WEG5y3caQ6R2PDaG4i8R1aTooTd",
};

export const DemoFixture = {
  joinCode,
  password,
  customPresetId,
  defaultPreset,
  apiKeyPresets: [defaultPreset, hideBrandingPreset, fullCustomizationPreset],

  /**
   * Builds the dynamic preset selected when a tester enters their own event
   * credentials. An empty password is treated as "no password".
   */
  customPreset(credentials: DemoCredentials): DemoApiKeyPreset {
    return {
      id: customPresetId,
      title: "Your own event",
      summary: `Join code ${credentials.joinCode} with your own API key.`,
      joinCode: credentials.joinCode,
      password: credentials.password === "" ? null : credentials.password,
      apiKey: credentials.apiKey,
    };
  },
};
