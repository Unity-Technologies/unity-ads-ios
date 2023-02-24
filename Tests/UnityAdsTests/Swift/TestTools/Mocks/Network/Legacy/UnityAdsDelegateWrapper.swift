import Foundation
@testable import UnityAds

final class UnityAdsDelegateWrapper: NSObject, UnityAdsInitializationDelegate {

    var complete: VoidClosure?
    var failure: Closure<String>?
    func initializationComplete() {
        complete?()
    }

    func initializationFailed(_ error: UnityAdsInitializationError,
                              withMessage message: String) {

        failure?(message)
    }

}
