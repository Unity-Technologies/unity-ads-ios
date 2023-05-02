import Foundation

@objc
final class SDKInitializerOBJBridge: NSObject {
    private let sdkInitializer: SDKInitializer
    init(sdkInitializer: SDKInitializer) {
        self.sdkInitializer = sdkInitializer
    }

    @objc
    func initialize(gameID: String,
                    testMode: Bool,
                    completion: @escaping VoidClosure,
                    error: @escaping Closure<Error>) {
        let config = SDKInitializerConfig(gameID: gameID, isTestModeEnabled: testMode)
        sdkInitializer.initialize(with: config) { result in
            result.do(completion)
                  .onFailure(error)
        }
    }

}
