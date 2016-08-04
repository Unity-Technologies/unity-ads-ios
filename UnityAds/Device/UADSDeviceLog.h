#import <Foundation/Foundation.h>
#import "UnityAds/UnityAds.h"

typedef NS_ENUM(int, UnityAdsLogLevel) {
    kUnityAdsLogLevelError = 1,
    kUnityAdsLogLevelWarning = 2,
    kUnityAdsLogLevelInfo = 3,
    kUnityAdsLogLevelDebug = 4
};

#define UADSLogCore(logLevel, logLevelStr, format, function, lineNumber, ...)\
    if (logLevel <= [UADSDeviceLog getLogLevel]) NSLog((@"%@/UnityAds: %s (line:%d) :: " format), logLevelStr, function, lineNumber, ##__VA_ARGS__);

#define UADSLogError(fmt, ...) UADSLogCore(kUnityAdsLogLevelError, @"E", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define UADSLogWarning(fmt, ...) UADSLogCore(kUnityAdsLogLevelWarning, @"W", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define UADSLogInfo(fmt, ...) UADSLogCore(kUnityAdsLogLevelInfo, @"I", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define UADSLogDebug(fmt, ...) UADSLogCore(kUnityAdsLogLevelDebug, @"D", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface UADSDeviceLog : NSObject
+ (void)setLogLevel:(UnityAdsLogLevel)logLevel;
+ (UnityAdsLogLevel)getLogLevel;
@end


