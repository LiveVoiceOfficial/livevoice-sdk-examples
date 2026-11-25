// Demo scaffolding — not needed for an integration.
// The screens of the demo's navigation stack, by route name.

export type DemoStackParamList = {
  Home: undefined;
  DefaultInterface: undefined;
  JoiningEvent: undefined;
  FilteringChannels: undefined;
  CustomChannelCell: undefined;
  CustomViewStates: undefined;
  Subtitles: undefined;
  AudioOutput: undefined;
  LockScreen: undefined;
  Passwords: undefined;
  LanguageRequests: undefined;
  LinkedEvents: undefined;
  Branding: undefined;
  Localization: undefined;
  Diagnostics: undefined;
};

export type DemoRoute = Exclude<keyof DemoStackParamList, "Home">;
