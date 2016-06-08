import XCTest

class UnityAdsClassSelectorAvailabilityTests: XCTestCase, UnityAdsDelegate {
    // MARK: UnityAdsDelegate selectors
    func unityAdsReady(placementId: String) {
    }

    func unityAdsDidClick(placementId: String) {
    }

    func unityAdsDidError(error: UnityAdsError, withMessage message: String) {
    }

    func unityAdsDidStart(placementId: String) {
    }

    func unityAdsDidFinish(placementId: String, withFinishState state: UnityAdsFinishState) {
    }

    // MARK: show(viewController)
    func testShow() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.show(_:))), "UnityAds does not respond to show:")
    }
    
    func testShowWithPlacementId() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.show(_:placementId:))), "UnityAds does not respond to show:")
    }
    
    // MARK: getDelegate()
    func testDelegateGetter() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.getDelegate)), "UnityAds does not respond to getDelegate")
    }
    
    func testPerformanceDelegateGetter() {
        self.measureBlock {
            UnityAds.getDelegate()
        }
    }
    
    func testPerformanceDelegateGetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.getDelegate()
            }
        }
    }
    
    // MARK: setDelegate()
    func testDelegateSetter() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.setDelegate(_:))), "UnityAds does not respond to setDelegate:")
    }
    
    func testPerformanceDelegateSetter() {
        self.measureBlock {
            UnityAds.setDelegate(self)
        }
    }
    
    func testPerformanceDelegateSetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.setDelegate(self)
            }
        }
    }
    
    // MARK: getDebugMode()
    func testDebugModeGetter() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.getDebugMode)), "UnityAds does not respond to getDebugMode")
    }
    
    func testPerformanceDebugModeGetter() {
        self.measureBlock {
            UnityAds.getDebugMode()
        }
    }
    
    func testPerformanceDebugModeGetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.getDebugMode()
            }
        }
    }
    
    // MARK: setDebugMode()
    func testDebugModeSetter() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.setDebugMode(_:))), "UnityAds does not respond to setDebugMode:")
    }
    
    func testPerformanceDebugModeSetter() {
        self.measureBlock {
            UnityAds.setDebugMode(UnityAdsTestConstants.defaultDebugLogging)
        }
    }
    
    func testPerformanceDebugModeSetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.setDebugMode(UnityAdsTestConstants.defaultDebugLogging)
            }
        }
    }
    
    // MARK: getPlacementState()
    func testPlacementStateGetter() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.getPlacementState as () -> UnityAdsPlacementState)), "UnityAds does not respond to getPlacementState")
    }
    
    func testPerformancePlacementStateGetter() {
        self.measureBlock {
            UnityAds.getPlacementState()
        }
    }
    
    func testPerformancePlacementStateGetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.getPlacementState()
            }
        }
    }
    
    // MARK: getPlacementState(placementId)
    func testPlacementStateGetterWithPlacementIdString() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.getPlacementState(_:))), "UnityAds does not respond to getPlacementState:placementId")
    }
    
    func testPerformancePlacementStateForPlacementIdGetter() {
        self.measureBlock {
            UnityAds.getPlacementState(UnityAdsTestConstants.defaultPlacementId)
        }
    }
    
    func testPerformancePlacementStateForPlacementIdGetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.getPlacementState(UnityAdsTestConstants.defaultPlacementId)
            }
        }
    }
    
    // MARK: getVersion()
    func testVersionGetter() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.getVersion)), "UnityAds does not respond to getVersion")
    }
    
    func testPerformanceVersionGetter() {
        self.measureBlock {
            UnityAds.getVersion()
        }
    }
    
    func testPerformanceVersionGetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.getVersion()
            }
        }
    }
    
    // MARK: isInitialized()
    func testInitializedGetter() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.isInitialized)), "UnityAds does not respond to isInitialized")
    }
    
    func testPerformanceInitializedGetter() {
        self.measureBlock {
            UnityAds.isInitialized()
        }
    }
    
    func testPerformanceInitializedGetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.isInitialized()
            }
        }
    }
    
    
    // MARK: isReady()
    func testReadyGetter() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.isReady as () -> Bool)), "UnityAds does not respond to isReady")
    }
    
    func testPerformanceReadyGetter() {
        self.measureBlock {
            UnityAds.isReady()
        }
    }
    
    func testPerformanceReadyGetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.isReady()
            }
        }
    }
    
    // MARK: isReadyWithPlacementId(placementIdString)
    func testReadyGetterWithPlacementIdString() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.isReady(_:))), "UnityAds does not respond to isReadyWithPlacementId:")
    }
    
    func testPerformanceReadyForPlacementIdGetter() {
        self.measureBlock {
            UnityAds.isReady(UnityAdsTestConstants.defaultPlacementId)
        }
    }
    
    func testPerformanceReadyForPlacementIdGetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.isReady(UnityAdsTestConstants.defaultPlacementId)
            }
        }
    }
    
    // MARK: isSupported()
    func testSupportedGetter() {
        XCTAssertTrue(UnityAds.respondsToSelector(#selector(UnityAds.isSupported)), "UnityAds does not respond to isSupported")
    }
    
    func testPerformanceSupportedGetter() {
        self.measureBlock {
            UnityAds.isSupported()
        }
    }
    
    func testPerformanceSupportedGetterRepeatedly() {
        self.measureBlock {
            for _ in [0...UnityAdsTestConstants.hammerTime] {
                UnityAds.isSupported()
            }
        }
    }

}
