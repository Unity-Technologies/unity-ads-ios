import XCTest

class PlacementTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        UADSApiPlacement.reset()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testReset() {
        let callback = UADSWebViewCallback()
        UADSApiPlacement.WebViewExposed_setDefaultPlacement("defaultPlacement", webViewCallback: callback)
        
        UADSApiPlacement.reset()
        
        XCTAssertNil(UADSApiPlacement.getDefaultPlacement())
        XCTAssert(UADSApiPlacement.isReady("testPlacement") == false)
        XCTAssert(UADSApiPlacement.getPlacementState() == UnityAdsPlacementState.NotAvailable)
        XCTAssert(UADSApiPlacement.getPlacementState("testPlacement") == UnityAdsPlacementState.NotAvailable)
        
    }
    
    func testSetDefaultPlacement() {
        let callback = UADSWebViewCallback()
        let testPlacement:String = "testPlacement"
        
        UADSApiPlacement.WebViewExposed_setDefaultPlacement(testPlacement, webViewCallback: callback)
        
        XCTAssertEqual(UADSApiPlacement.getDefaultPlacement(), testPlacement)
        
    }
    
    func testSetPlacementState() {
        let callback = UADSWebViewCallback()
        let testPlacement:String = "testPlacement"
        let testPlacement2:String = "testPlacement2"
        
        UADSApiPlacement.WebViewExposed_setPlacementState(testPlacement, placementState: "NO_FILL", webViewCallback: callback)
        
        XCTAssertEqual(UADSApiPlacement.getPlacementState(testPlacement), UnityAdsPlacementState.NoFill)
        
        UADSApiPlacement.WebViewExposed_setPlacementState(testPlacement2, placementState: "NOT_AVAILABLE", webViewCallback: callback)
        
        XCTAssertEqual(UADSApiPlacement.getPlacementState(testPlacement2), UnityAdsPlacementState.NotAvailable)
        
        UADSApiPlacement.WebViewExposed_setPlacementState(testPlacement, placementState: "READY", webViewCallback: callback)
        
        XCTAssertEqual(UADSApiPlacement.getPlacementState(testPlacement), UnityAdsPlacementState.Ready)
        
        UADSApiPlacement.WebViewExposed_setPlacementState(testPlacement2, placementState: "DISABLED", webViewCallback: callback)
        
        XCTAssertEqual(UADSApiPlacement.getPlacementState(testPlacement2), UnityAdsPlacementState.Disabled)
        
        UADSApiPlacement.WebViewExposed_setPlacementState(testPlacement, placementState: "WAITING", webViewCallback: callback)
        
        XCTAssertEqual(UADSApiPlacement.getPlacementState(testPlacement), UnityAdsPlacementState.Waiting)
    }
    
    func testIsPlacementReady() {
        let callback = UADSWebViewCallback()
        let testPlacement:String = "testPlacement"
        
        XCTAssertFalse(UADSApiPlacement.isReady(testPlacement))
        
        UADSApiPlacement.WebViewExposed_setPlacementState(testPlacement, placementState:"DISABLED", webViewCallback: callback)
        
        XCTAssertFalse(UADSApiPlacement.isReady(testPlacement))
        
        UADSApiPlacement.WebViewExposed_setPlacementState(testPlacement, placementState: "READY", webViewCallback: callback)
        XCTAssertTrue(UADSApiPlacement.isReady(testPlacement))
        
        UADSApiPlacement.WebViewExposed_setPlacementState(testPlacement, placementState: "NO_FILL", webViewCallback: callback)
        XCTAssertFalse(UADSApiPlacement.isReady(testPlacement))
    }
    
    func testIsDefaultPlacementReady() {
        let callback = UADSWebViewCallback()
        let defaultPlacement:String = "defaultPlacement"
        
        XCTAssertFalse(UADSApiPlacement.isReady())
        
        UADSApiPlacement.WebViewExposed_setDefaultPlacement(defaultPlacement, webViewCallback: callback)
        
        XCTAssertFalse(UADSApiPlacement.isReady())
        
        UADSApiPlacement.WebViewExposed_setPlacementState(defaultPlacement, placementState: "WAITING", webViewCallback: callback)
        XCTAssertFalse(UADSApiPlacement.isReady())
        
        UADSApiPlacement.WebViewExposed_setPlacementState(defaultPlacement, placementState: "READY", webViewCallback: callback)
        XCTAssertTrue(UADSApiPlacement.isReady())
    }
    
}


