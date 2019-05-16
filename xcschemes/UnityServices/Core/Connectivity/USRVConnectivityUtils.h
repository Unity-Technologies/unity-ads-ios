

@import CoreTelephony;
@import SystemConfiguration;

typedef enum : NSInteger {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

typedef enum : NSInteger {
    NetworkTypeUnknown = 0,
    NetworkTypeGPRS,
    NetworkTypeEdge,
    NetworkTypeUMTS,
    NetworkTypeCDMA,
    NetworkTypeEVDO0,
    NetworkTypeEVDOA,
    NetworkType1xRtt,
    NetworkTypeHSDPA,
    NetworkTypeHSUPA,
    NetworkTypeHSPA,
    NetworkTypeIDEN,
    NetworkTypeEVDOB,
    NetworkTypeLTE,
    NetworkTypeHRPD,
    NetworkTypeHSPAP,
    NetworkTypeGSM,
    NetworkTypeTdSCDMA,
    NetworkTypeIWLAN
} NetworkType;

@interface USRVConnectivityUtils : NSObject

+ (void) initCarrierInfo;

+ (NSInteger)getNetworkType;

+ (NetworkStatus)getNetworkStatus;

+ (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags;

@end
