import XCTest

class ClientPropertiesTests: XCTestCase {

    func testGetAppName() {
        XCTAssertEqual(UADSClientProperties.getAppName(), "com.unity3d.ads.example", "App name should be eqaul to 'com.unity3d.ads.example")

    }

    func testGetAppVersion() {
        XCTAssertEqual(UADSClientProperties.getAppVersion(), "1.0")
        
    }
    
    func testSetCurrentViewController() {
        let viewController = UIViewController();
        
        UADSClientProperties.setCurrentViewController(viewController);
        
        XCTAssertEqual(viewController, UADSClientProperties.getCurrentViewController())
    }
    
    func testSetDelegate() {
        let adsDelegate = AdsDelegate();
        UADSClientProperties.setDelegate(adsDelegate)
        
        XCTAssertNotNil(UADSClientProperties.getDelegate())
    }
    
    func testIsAppDebuggable() {
        XCTAssertTrue(UADSClientProperties.isAppDebuggable(), "App should be debuggable")
    }
    
    func testSetGameId() {
        UADSClientProperties.setGameId("54321")
        XCTAssertEqual(UADSClientProperties.getGameId(), "54321")
    }
    
}

class AdsDelegate: NSObject, UnityAdsDelegate {
    
    func unityAdsReady(placementId: String) {
        
    }
    
    func unityAdsDidStart(placementId: String) {
        
    }
    
    func unityAdsDidError(error: UnityAdsError, withMessage message: String) {
        
    }
    
    func unityAdsDidFinish(placementId: String, withFinishState state: UnityAdsFinishState) {

        
    }
}