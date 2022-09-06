import XCTest

class LoadShowTests: XCUITestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_load_show_sequence() throws {
        measure {
            let app = preparedApp
            app.launch()
            executeTestFlow(in: app)
        }
    }

    var preparedApp: XCUIApplication {
        let app = XCUIApplication()
        app.setInterstitialPlacement(Settings.placement)
        app.setGameID(Settings.gameID)
        return app
    }

    func executeTestFlow(in app: XCUIApplication) {
        do {
            try executeTestFlowWithError(in: app)
        } catch {
            XCTFail("Failed due to the error \(error)")
        }
    }

    func executeTestFlowWithError(in app: XCUIApplication) throws {
        try initializeSDK(in: app)
        try callLoad(in: app)
        try callShow(in: app)
        try closeAd(in: app)
        try waitForButton(name: Settings.initializeButton,
                          app: app,
                          timeout: Settings.elementWaitTimeout)
    }

    func initializeSDK(in app: XCUIApplication) throws {
        try tapOnButtonIfAvailable(Settings.initializeButton,
                                   app: app,
                                   timeout: Settings.elementWaitTimeout)
    }

    func callLoad(in app: XCUIApplication) throws {
        try tapOnButtonIfAvailable(Settings.interstitialLoadButton,
                                   app: app,
                                   timeout: Settings.elementWaitTimeout)
    }

    func callShow(in app: XCUIApplication) throws {
        try tapOnButtonIfAvailable(Settings.interstitialShowButton,
                                   app: app,
                                   timeout: Settings.elementWaitTimeout)
    }

    func closeAd(in app: XCUIApplication) throws {
        try tapOnButtonIfAvailable(Settings.closeButton,
                                   app: app,
                                   timeout: Settings.adDuration,
                                   sleepBeforeTap: Settings.buttonTapWait)
    }
}

extension LoadShowTests {
    struct Settings {
        static let placement = "adapter_test_interstitial_unity_one_c11fda36_a064_4d56_ab7a_efa088f6f7e4"
        static let initializeButton = "InitializeButton"
        static let gameID = "3804048"
        static let gameIDTextField = "GameIDField"
        static let interstitialLoadButton = "interstitialLoadButton"
        static let interstitialShowButton = "interstitialShowButton"
        static let closeButton = "Close"
        static let elementWaitTimeout: TimeInterval = 10
        static let adDuration: TimeInterval = 30
        static let buttonTapWait: UInt32 = 5
    }
}
