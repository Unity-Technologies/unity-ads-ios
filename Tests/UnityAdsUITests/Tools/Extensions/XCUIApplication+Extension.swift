import Foundation
import XCTest

extension XCUIApplication {

    func setInterstitialPlacement(_ interstitialPlacementId: String) {
        launchArguments += ["-interstitialPlacementId", interstitialPlacementId]
    }

    func setGameID(_ gameID: String) {
        launchArguments += ["-adsExampleAppGameId", gameID]
    }

}
