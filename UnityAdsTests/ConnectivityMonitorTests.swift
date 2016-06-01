import XCTest
import SystemConfiguration

class ConnectivityMonitorTests: XCTestCase {
    
    var connectivityMonitor: UADSConnectivityMonitor! = nil

    override func setUp() {
        super.setUp()
        connectivityMonitor = UADSConnectivityMonitor()

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testListener() {
//        let asyncExpectation = expectationWithDescription("ConnectivityListener exceptation")

        let listener = ConnectivityListener()
        UADSConnectivityMonitor.setConnectionMonitoring(true)
        UADSConnectivityMonitor.startListening(listener)
        
        UADSConnectivityMonitor.setConnectionMonitoring(false)
        
        UADSConnectivityMonitor.stopAll()

        UADSConnectivityMonitor.stopListening(listener)

        
        
//        self.waitForExpectationsWithTimeout(20) { error in
//            NSLog("eka timeri")
//            //XCTAssertNil(error, "Something went wrong")        
//        }
//        
    }
    
    class ConnectivityListener : NSObject, UADSConnectivityDelegate {
        @objc func connected() {
            NSLog("connected")
        }
        
        @objc func disconnected() {
            NSLog("disconnected")
        }
    }
    
}

