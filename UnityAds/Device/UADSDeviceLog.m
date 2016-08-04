#import "UADSDeviceLog.h"

@implementation UADSDeviceLog

static UnityAdsLogLevel _logLevel = kUnityAdsLogLevelDebug;

+ (void)setLogLevel:(UnityAdsLogLevel)logLevel {
    _logLevel = logLevel;
}

+ (UnityAdsLogLevel)getLogLevel {
    return _logLevel;
}

@end