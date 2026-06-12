import SwiftUI

// iOS 15 / 16 navigation and onChange fallbacks.
//
// This file exists ONLY to support systems older than the modern SwiftUI APIs
// used in `DemoPlatformSupport.swift`. It deliberately uses `NavigationView`
// (deprecated in iOS 16) and the single-parameter `onChange(of:perform:)`
// (deprecated in iOS 17), so the compiler will emit deprecation warnings here —
// that is expected and is the signal that this code is legacy.
//
// When the deployment target is raised past iOS 15 (and iOS 16 for onChange),
// delete this file and the matching `else` branches in `DemoPlatformSupport.swift`.
// Nothing else references these types.

/// iOS 15 fallback for ``DemoSplitNavigation``. `NavigationView` with a sidebar
/// and a detail column reproduces the split behaviour on iPad and pushes on
/// iPhone, matching `NavigationSplitView`.
struct LegacySplitNavigation<Sidebar: View, Detail: View>: View {
    let sidebar: () -> Sidebar
    let detail: () -> Detail

    var body: some View {
        NavigationView {
            sidebar()
            detail()
        }
    }
}

/// iOS 15 fallback for ``DemoStackNavigation``. `.stack` keeps it single-column
/// so presented forms behave like `NavigationStack`.
struct LegacyStackNavigation<Content: View>: View {
    let content: () -> Content

    var body: some View {
        NavigationView {
            content()
        }
        .navigationViewStyle(.stack)
    }
}

extension View {
    /// iOS 15/16 fallback for ``demoOnChange(of:perform:)`` using the
    /// single-parameter `onChange(of:perform:)`.
    func legacyOnChange<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        onChange(of: value, perform: action)
    }
}
