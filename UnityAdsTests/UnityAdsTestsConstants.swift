import Foundation

@objc class UnityAdsTestConstants: NSObject {
    static let testMode : Bool = true
    static let hammerTime : Int = 10000
    
    static let networkFetchInterval : NSTimeInterval = 10.0
    
    static let nonNumericGameIdString : String = "1EE7"
    
    static let defaultGameId : String = "14850"
    static let defaultPlacementId : String = "defaultVideoAndPictureZone"
    
    static let defaultDebugLogging : Bool = true
    
    class func bundleConfigUrl() -> NSURL {
        return (NSBundle(forClass: self).resourceURL?.URLByAppendingPathComponent("config.json"))!
    }
    
    class func bundleWebviewUrl() -> NSURL {
        return (NSBundle(forClass: self).resourceURL?.URLByAppendingPathComponent("index.html"))!
    }
    
    class func cachedWebviewUrl() -> NSURL {
        let cacheDirPath = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        let webviewPathUrl = cacheDirPath.URLByAppendingPathComponent("index.html")
        return webviewPathUrl
    }
    
    class func cachedConfigUrl() -> NSURL {
        let cacheDirPath = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        let configPathUrl = cacheDirPath.URLByAppendingPathComponent("config.json")
        return configPathUrl
    }
}