import SwiftUI
import LiveVoiceSDK

struct FilteredChannelListScreen: View {
    @ObservedObject private var liveVoice: LiveVoice = .shared
    @State private var filterMode: DefaultFilterMode = .all
    @State private var selectedSourceID: Int64?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DemoScreenHeader(
                    title: "Filtered channel list",
                    summary: "Keep the standard LiveVoice list, but choose which channels appear — by any property, the empty state, or a source channel with its AI subtitles."
                )

                DemoCardSection(title: "Filter by property") {
                    LiveVoiceView(filter: channelFilter)
                }

                DemoCardSection(title: "Controls") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Filter mode", selection: $filterMode) {
                            ForEach(DefaultFilterMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        Text(predicateDescription)
                            .font(.footnote.monospaced())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                DemoCardSection(title: "Source and AI subtitles") {
                    VStack(alignment: .leading, spacing: 12) {
                        if sourceOptions.isEmpty {
                            Text("This event has no source channel with derived AI subtitles. The filter keeps the source channel plus any channel whose aiTranslationInfo.sourceID matches it — point the app at an event that has them to see it in action.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            LiveVoiceView(filter: featuredFilter)

                            Picker("Source channel", selection: $selectedSourceID) {
                                Text("Choose source channel").tag(Optional<Int64>.none)
                                ForEach(sourceOptions) { option in
                                    Text(option.name).tag(Optional(option.id))
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }

                DemoCardSection(title: "Implementation notes") {
                    DemoNoteList(
                        notes: [
                            "You provide the filter to the LiveVoiceView.",
                            "You can filter by any channel property and not just hard-coded IDs.",
                            "A predicate that always returns false is useful for checking the no-matching-channels state.",
                            "To feature a source channel, keep it plus any channel whose aiTranslationInfo.sourceID matches.",
                        ]
                    )
                }

            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        // Re-validate against the *emitted* config (the @Published stored value lags one update
        // in willSet), so the selection always points at a current option. Otherwise a selected
        // source that drops out of the list leaves the Picker selection without a matching tag and
        // the button renders blank ("…selection is invalid and does not have an associated tag").
        .onReceive(liveVoice.$availableSubtitles) { subtitles in
            let options = sourceOptions(from: subtitles)
            if !options.contains(where: { $0.id == selectedSourceID }) {
                selectedSourceID = options.first?.id
            }
        }
    }

    private func channelFilter(_ channel: LiveVoiceChannel) -> Bool {
        switch filterMode {
        case .all:
            true
        case .hasSubtitles:
            channel.hasSubtitles
        case .noMatchingChannels:
            false
        }
    }

    private var predicateDescription: String {
        switch filterMode {
        case .all:
            "Predicate: { _ in true }"
        case .hasSubtitles:
            "Predicate: { channel in channel.hasSubtitles }"
        case .noMatchingChannels:
            "Predicate: { _ in false }"
        }
    }

    private var sourceOptions: [SourceOption] {
        sourceOptions(from: liveVoice.availableSubtitles)
    }

    private func sourceOptions(from subtitles: [LiveVoice.AvailableSubtitle]) -> [SourceOption] {
        let namesByID = Dictionary(uniqueKeysWithValues: subtitles.map { ($0.id, $0.name) })
        let rootIDs = Set(subtitles.map { $0.parent ?? $0.id })
        return rootIDs
            .map { SourceOption(id: $0, name: namesByID[$0] ?? "Channel \($0)") }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func featuredFilter(_ channel: LiveVoiceChannel) -> Bool {
        guard let selectedSourceID else { return true }
        return channel.id == selectedSourceID
            || channel.aiTranslationInfo?.sourceID == selectedSourceID
    }
}

#Preview {
    DemoStackNavigation {
        FilteredChannelListScreen()
    }
    .environmentObject(DemoSession.preview)
    .initialized(
        joinCode: DemoFixture.joinCode,
        password: DemoFixture.password,
        apiKey: DemoFixture.apiKey
    )
}
