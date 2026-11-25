// Password-protected channels
//
// A protected channel needs its password when it starts. Without any setup,
// the SDK asks with its own prompt and remembers the password until the app
// quits. `setPasswordProvider` asks with your own UI instead, and
// `setPasswordStore` keeps passwords longer: the SDK asks the store first,
// saves a password the server accepted and removes one it rejected.
//
// Differs from iOS: the provider is a function returning a promise and the
// store a plain object of three async functions. Subjects are new frozen
// objects each time, so the store keys them by their fields, not by
// identity. The SDK's own prompt shows only while a LiveVoiceView is
// mounted; with none on screen, a request without a provider gives up. A
// stack navigator keeps a screen mounted under the one pushed over it, so
// this screen sets both while it has the focus (`useFocusEffect`), not while
// it is mounted. The SDK remembers passwords in its native part: reloading
// the JavaScript bundle doesn't forget them, quitting the app does.
//
// Needs: your own event with a password on a channel.
// Uses: setPasswordProvider(provider), setPasswordStore(store),
// LiveVoicePasswordStore, LiveVoicePasswordRequest, LiveVoicePasswordSubject
// See also: Subtitles (a protected channel's subtitles use the same password).

import React, { useCallback, useRef, useState } from "react";
import { Modal, Pressable, StyleSheet, Text, TextInput, View } from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import {
  LiveVoiceView,
  setPasswordProvider,
  setPasswordStore,
  type LiveVoicePasswordRequest,
  type LiveVoicePasswordStore,
  type LiveVoicePasswordSubject,
} from "livevoice-sdk-react-native";
import { DemoPlaceholder } from "../../demo/DemoRows";
import {
  DemoNote,
  DemoRequirement,
  DemoScreen,
  DemoSection,
} from "../../demo/DemoScreen";
import { useDemoSession } from "../../demo/DemoSession";
import { useDemoTheme } from "../../demo/DemoTheme";

export const PasswordsScreen: React.FC = () => {
  const theme = useDemoTheme();
  const { usesOwnEvent } = useDemoSession();
  const prompt = usePasswordPrompt();
  const { pending } = prompt;
  const { store, subjects } = useMemoryPasswordStore();

  // A real app sets both once, at launch. This screen sets them only while
  // it shows, so the other screens keep the SDK's own prompt.
  useFocusEffect(
    useCallback(() => {
      setPasswordProvider(prompt.ask);
      setPasswordStore(store);
      return () => {
        setPasswordProvider(null);
        setPasswordStore(null);
        prompt.giveUp();
      };
    }, [prompt.ask, prompt.giveUp, store]),
  );

  return (
    <DemoScreen
      title="Password-protected channels"
      caption="Ask for channel passwords with your own UI, and keep them."
    >
      {/* The SDK lists an event's channels only in LiveVoiceView, so the note
          can only tell the demo event apart. */}
      <DemoRequirement
        need={{ ownEvent: "Password-protected channels" }}
        isMet={usesOwnEvent}
      />
      <DemoSection title="Channels">
        {/* The SDK keeps an accepted password in memory for the app's run and
            forgets one only when the server rejects it. Starting a protected
            channel looks in memory, then asks the store, then the provider. */}
        <DemoNote
          text="Once a password is accepted, the SDK remembers it until the app quits and won't ask again. Restart the app to see the prompt again."
          icon="info"
          tint={theme.secondaryText}
        />
        <LiveVoiceView />
      </DemoSection>
      <DemoSection title="Saved passwords">
        {subjects.length === 0 && (
          <DemoPlaceholder text="None yet: play a protected channel." />
        )}
        {subjects.map((subject) => (
          <Text key={subjectKey(subject)} style={[styles.saved, { color: theme.text }]}>
            {subject.kind === "channel"
              ? `Channel ${subject.channelId} of event ${subject.joinCode}`
              : `Event ${subject.joinCode}`}
          </Text>
        ))}
      </DemoSection>
      {/* Keyed by the request, so a retry after a wrong password starts
          with an empty field. */}
      {pending && (
        <PasswordPromptView
          key={pending.id}
          request={pending.request}
          answer={(password) => prompt.answer(pending.id, password)}
        />
      )}
    </DemoScreen>
  );
};

/** A request the prompt shows, with the way to answer it. */
type Pending = {
  id: number;
  request: LiveVoicePasswordRequest;
  resolve: (password: string | null) => void;
};

/** Hands the SDK's password requests to your UI and waits for the answer. */
function usePasswordPrompt() {
  const [pending, setPending] = useState<Pending | null>(null);
  const open = useRef<Pending | null>(null);
  const nextId = useRef(0);

  /**
   * Answers the request with `id`. A late answer to an older request, such
   * as from a prompt that is still closing, does nothing.
   */
  const answer = useCallback((id: number, password: string | null) => {
    const request = open.current;
    if (request === null || request.id !== id) return;
    open.current = null;
    setPending(null);
    request.resolve(password);
  }, []);

  /**
   * The provider: resolves with the password, or `null` to give up, which
   * fails the start with `channel_password_required`.
   */
  const ask = useCallback(
    (request: LiveVoicePasswordRequest) =>
      new Promise<string | null>((resolve) => {
        // A newer request replaces one still open, which gives up.
        if (open.current) answer(open.current.id, null);
        const next = { id: ++nextId.current, request, resolve };
        open.current = next;
        setPending(next);
      }),
    [answer],
  );

  /** Gives up the open request, so the SDK isn't left waiting. */
  const giveUp = useCallback(() => {
    if (open.current) answer(open.current.id, null);
  }, [answer]);

  return { pending, ask, answer, giveUp };
}

/**
 * Your own password prompt. `isRetry` is `true` after a rejected password.
 * It closes only through Cancel or Listen (or Android's back button, which
 * cancels), so every request gets its answer.
 */
const PasswordPromptView: React.FC<{
  request: LiveVoicePasswordRequest;
  answer: (password: string | null) => void;
}> = ({ request, answer }) => {
  const theme = useDemoTheme();
  const [password, setPassword] = useState("");
  return (
    <Modal visible transparent animationType="fade" onRequestClose={() => answer(null)}>
      <View style={styles.backdrop}>
        <View style={[styles.prompt, { backgroundColor: theme.popover }]}>
          <Text style={[styles.title, { color: theme.text }]}>Password</Text>
          <TextInput
            value={password}
            onChangeText={setPassword}
            placeholder="Password"
            placeholderTextColor={theme.secondaryText}
            secureTextEntry
            autoFocus
            autoCapitalize="none"
            autoCorrect={false}
            style={[styles.field, { color: theme.text, borderColor: theme.separator }]}
          />
          {request.isRetry && (
            <Text style={[styles.footer, { color: theme.secondaryText }]}>
              Wrong password. Try again.
            </Text>
          )}
          <View style={styles.actions}>
            <Pressable accessibilityRole="button" hitSlop={8} onPress={() => answer(null)}>
              <Text style={[styles.action, { color: theme.accent }]}>Cancel</Text>
            </Pressable>
            <Pressable
              accessibilityRole="button"
              accessibilityState={{ disabled: password === "" }}
              hitSlop={8}
              disabled={password === ""}
              onPress={() => answer(password)}
            >
              <Text
                style={[
                  styles.action,
                  styles.confirm,
                  { color: password === "" ? theme.secondaryText : theme.accent },
                ]}
              >
                Listen
              </Text>
            </Pressable>
          </View>
        </View>
      </View>
    </Modal>
  );
};

/**
 * Keeps passwords in memory, keyed by what they belong to. A real app keeps
 * them securely, for example in the Keychain or the Android Keystore, so
 * they outlive the app. Storing is best effort: a promise that rejects is
 * logged and fails nothing.
 */
function useMemoryPasswordStore() {
  const saved = useRef(new Map<string, { subject: LiveVoicePasswordSubject; password: string }>());
  const [subjects, setSubjects] = useState<LiveVoicePasswordSubject[]>([]);
  const [store] = useState<LiveVoicePasswordStore>(() => {
    const changed = () =>
      setSubjects([...saved.current.values()].map((entry) => entry.subject));
    return {
      load: async (subject) => saved.current.get(subjectKey(subject))?.password ?? null,
      save: async (subject, password) => {
        saved.current.set(subjectKey(subject), { subject, password });
        changed();
      },
      remove: async (subject) => {
        saved.current.delete(subjectKey(subject));
        changed();
      },
    };
  });
  return { store, subjects };
}

/** A subject's fields as one string, to key it by. */
function subjectKey(subject: LiveVoicePasswordSubject): string {
  return subject.kind === "channel"
    ? `channel/${subject.joinCode}/${subject.channelId}`
    : `event/${subject.joinCode}`;
}

const styles = StyleSheet.create({
  saved: {
    fontSize: 17,
  },
  backdrop: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.4)",
    justifyContent: "center",
    paddingHorizontal: 32,
  },
  prompt: {
    borderRadius: 14,
    padding: 20,
    gap: 12,
  },
  title: {
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
  footer: {
    fontSize: 13,
  },
  actions: {
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
