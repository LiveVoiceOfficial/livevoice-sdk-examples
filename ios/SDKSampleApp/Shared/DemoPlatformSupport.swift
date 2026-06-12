import SwiftUI

// Forward-looking platform wrappers used throughout the demo.
//
// Each wrapper uses the latest navigation / presentation API on the OS versions
// that support it, and falls back to an iOS 15/16 implementation from
// `DemoPlatformSupportLegacy.swift` on older systems. When the project's
// deployment target is raised, delete the legacy file and the matching `else`
// branch below — the modern path already covers every newer OS.

/// Two-column root navigation. Uses `NavigationSplitView` on iOS 16+.
struct DemoSplitNavigation<Sidebar: View, Detail: View>: View {
    @ViewBuilder var sidebar: () -> Sidebar
    @ViewBuilder var detail: () -> Detail

    var body: some View {
        if #available(iOS 16, *) {
            NavigationSplitView {
                sidebar()
            } detail: {
                detail()
            }
        } else {
            LegacySplitNavigation(sidebar: sidebar, detail: detail)
        }
    }
}

/// Single-column navigation container for pushed and presented screens.
/// Uses `NavigationStack` on iOS 16+.
struct DemoStackNavigation<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack {
                content()
            }
        } else {
            LegacyStackNavigation(content: content)
        }
    }
}

extension View {
    /// Pins a sheet to a fixed height on iOS 16+ (via `presentationDetents`).
    /// On iOS 15 the sheet uses the system default height.
    @ViewBuilder
    func demoSheetHeight(_ height: CGFloat) -> some View {
        if #available(iOS 16, *) {
            presentationDetents([.height(height)])
                .presentationDragIndicator(.hidden)
        } else {
            self
        }
    }

    /// Runs `action` with the new value whenever `value` changes, using the
    /// two-parameter `onChange(of:)` on iOS 17+ and the single-parameter form
    /// on iOS 15/16.
    @ViewBuilder
    func demoOnChange<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17, *) {
            onChange(of: value) { _, newValue in action(newValue) }
        } else {
            legacyOnChange(of: value, perform: action)
        }
    }
}
