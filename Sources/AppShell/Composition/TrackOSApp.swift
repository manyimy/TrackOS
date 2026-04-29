import SwiftUI
import DesignSystem

/// Entry point — add @main to this struct in your Xcode project target.
/// (Cannot use @main inside an SPM library target.)
public struct TrackOSApp: App {
    @Environment(\.colorScheme) private var colorScheme

    @State private var composition: AppComposition?
    @State private var initError: Error?

    public init() {}

    public var body: some Scene {
        WindowGroup {
            Group {
                if let composition {
                    RootView(composition: composition)
                        .environment(\.theme, colorScheme == .dark ? .dark : .light)
                } else if let error = initError {
                    Text("Failed to launch: \(error.localizedDescription)")
                        .padding()
                } else {
                    ProgressView()
                }
            }
            .task {
                if composition == nil && initError == nil {
                    do {
                        composition = try AppComposition()
                    } catch {
                        initError = error
                    }
                }
            }
        }
    }
}
