import Foundation
import LiveVoiceSDK

enum DefaultFilterMode: String, CaseIterable, Identifiable {
    case all = "All"
    case hasSubtitles = "Has subtitles"
    case noMatchingChannels = "No match"

    var id: String { rawValue }
}

struct SourceOption: Identifiable, Hashable {
    let id: Int64
    let name: String
}

struct SubtitleGroup: Identifiable {
    let title: String?
    let items: [LiveVoice.AvailableSubtitle]

    var id: String {
        title ?? "__automatic__"
    }
}

func mapSubtitleGroups(
    _ subtitles: [LiveVoice.AvailableSubtitle]
) -> [SubtitleGroup] {
    let namesByID = Dictionary(uniqueKeysWithValues: subtitles.map { ($0.id, $0.name) })
    var grouped: [String?: [LiveVoice.AvailableSubtitle]] = [:]

    for subtitle in subtitles {
        if let parent = subtitle.parent, let parentName = namesByID[parent] {
            grouped[parentName, default: []].append(subtitle)
        } else if subtitle.parent == nil {
            grouped[subtitle.name, default: []].append(subtitle)
        } else {
            grouped[nil, default: []].append(subtitle)
        }
    }

    let sortedKeys = grouped.keys.sorted { lhs, rhs in
        switch (lhs, rhs) {
        case (nil, nil):
            true
        case (nil, _):
            true
        case (_, nil):
            false
        case let (.some(lhs), .some(rhs)):
            lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
        }
    }

    return sortedKeys.map { key in
        SubtitleGroup(title: key, items: grouped[key] ?? [])
    }
}
