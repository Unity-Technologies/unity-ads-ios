#import "USRVDeviceLog.h"

@implementation USRVDeviceLog

static UnityServicesLogLevel _logLevel = kUnityServicesLogLevelDebug;

+ (void)setLogLevel:(UnityServicesLogLevel)logLevel {
    _logLevel = logLevel;
}

+ (UnityServicesLogLevel)getLogLevel {
    return _logLevel;
}

@end
