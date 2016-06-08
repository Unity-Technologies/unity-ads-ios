import XCTest

class PlacementTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        UADSPlacement.reset()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testReset() {
        UADSPlacement.setDefaultPlacement("defaultPlacement")
        
        UADSPlacement.reset()
        
        XCTAssertNil(UADSPlacement.getDefaultPlacement())
        XCTAssert(UADSPlacement.isReady("testPlacement") == false)
        XCTAssert(UADSPlacement.getPlacementState() == UnityAdsPlacementState.NotAvailable)
        XCTAssert(UADSPlacement.getPlacementState("testPlacement") == UnityAdsPlacementState.NotAvailable)
        
    }
    
    func testSetDefaultPlacement() {
        let testPlacement:String = "testPlacement"
        
        UADSPlacement.setDefaultPlacement(testPlacement)
        
        XCTAssertEqual(UADSPlacement.getDefaultPlacement(), testPlacement)
        
    }
    
    func testSetPlacementState() {
        let testPlacement:String = "testPlacement"
        let testPlacement2:String = "testPlacement2"
        
        UADSPlacement.setPlacementState(testPlacement, placementState: "NO_FILL")
        
        XCTAssertEqual(UADSPlacement.getPlacementState(testPlacement), UnityAdsPlacementState.NoFill)
        
        UADSPlacement.setPlacementState(testPlacement2, placementState: "NOT_AVAILABLE")
        
        XCTAssertEqual(UADSPlacement.getPlacementState(testPlacement2), UnityAdsPlacementState.NotAvailable)
        
        UADSPlacement.setPlacementState(testPlacement, placementState: "READY")
        
        XCTAssertEqual(UADSPlacement.getPlacementState(testPlacement), UnityAdsPlacementState.Ready)
        
        UADSPlacement.setPlacementState(testPlacement2, placementState: "DISABLED")
        
        XCTAssertEqual(UADSPlacement.getPlacementState(testPlacement2), UnityAdsPlacementState.Disabled)
        
        UADSPlacement.setPlacementState(testPlacement, placementState: "WAITING")
        
        XCTAssertEqual(UADSPlacement.getPlacementState(testPlacement), UnityAdsPlacementState.Waiting)
    }
    
    func testIsPlacementReady() {
        let testPlacement:String = "testPlacement"
        
        XCTAssertFalse(UADSPlacement.isReady(testPlacement))
        
        UADSPlacement.setPlacementState(testPlacement, placementState:"DISABLED")
        
        XCTAssertFalse(UADSPlacement.isReady(testPlacement))
        
        UADSPlacement.setPlacementState(testPlacement, placementState: "READY")
        XCTAssertTrue(UADSPlacement.isReady(testPlacement))
        
        UADSPlacement.setPlacementState(testPlacement, placementState: "NO_FILL")
        XCTAssertFalse(UADSPlacement.isReady(testPlacement))
    }
    
    func testIsDefaultPlacementReady() {
        let defaultPlacement:String = "defaultPlacement"
        
        XCTAssertFalse(UADSPlacement.isReady())
        
        UADSPlacement.setDefaultPlacement(defaultPlacement)
        
        XCTAssertFalse(UADSPlacement.isReady())
        
        UADSPlacement.setPlacementState(defaultPlacement, placementState: "WAITING")
        XCTAssertFalse(UADSPlacement.isReady())
        
        UADSPlacement.setPlacementState(defaultPlacement, placementState: "READY")
        XCTAssertTrue(UADSPlacement.isReady())
    }
    
}


