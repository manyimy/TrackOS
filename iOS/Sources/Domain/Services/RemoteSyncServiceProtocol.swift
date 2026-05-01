import Foundation

public protocol RemoteSyncServiceProtocol: Sendable {
    func sync() async
}

public struct NoOpSyncService: RemoteSyncServiceProtocol {
    public init() {}
    public func sync() async {}
}
