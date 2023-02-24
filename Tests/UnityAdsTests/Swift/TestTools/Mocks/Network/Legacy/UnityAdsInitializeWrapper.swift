import Foundation
@testable import UnityAds

final class UnityAdsInitializeWrapper: SDKInitializer {

    var onStart: VoidClosure?
    var onFinish: VoidClosure?

    func initialize(with config: SDKInitializerConfig,
                    completion: @escaping ResultClosure<Void>) {

        let delegateWrapper = UnityAdsDelegateWrapper()
        delegateWrapper.complete = {
            self.onFinish?()
            completion(VoidSuccess)
        }

        delegateWrapper.failure = { _ in
            self.onFinish?()
            completion(.failure(MockedError()))

        }

        onStart?()
        UnityAds.initialize(config.gameID, initializationDelegate: delegateWrapper)
        print("Started")
    }
}
