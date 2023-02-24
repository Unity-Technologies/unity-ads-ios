import Foundation
@testable import UnityAds

extension SDKInitializerBase.State {
    static func convertFromLegacy(_ legacyState: InitializationState) -> Self {
        switch legacyState {

        case .NOT_INITIALIZED:
            return .notInitialized
        case .INITIALIZING:
            return .inProcess
        case .INITIALIZED_SUCCESSFULLY:
            return .initialized
        case .INITIALIZED_FAILED:
            return .failed(MockedError())
        @unknown default:
            fatalError()
        }
    }

    var legacyType: InitializationState {
        switch self {

        case .notInitialized:
            return .NOT_INITIALIZED
        case .inProcess:
            return .INITIALIZING
        case .failed:
            return .INITIALIZED_FAILED
        case .initialized:
            return .INITIALIZED_SUCCESSFULLY
        }
    }
}
