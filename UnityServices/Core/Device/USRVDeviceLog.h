#import <Foundation/Foundation.h>

typedef NS_ENUM(int, UnityServicesLogLevel) {
    kUnityServicesLogLevelError = 1,
    kUnityServicesLogLevelWarning = 2,
    kUnityServicesLogLevelInfo = 3,
    kUnityServicesLogLevelDebug = 4
};

#define USRVLogCore(logLevel, logLevelStr, format, function, lineNumber, ...)\
    if (logLevel <= [USRVDeviceLog getLogLevel]) NSLog((@"%@/UnityAds: %s (line:%d) :: " format), logLevelStr, function, lineNumber, ##__VA_ARGS__);

#define USRVLogError(fmt, ...) USRVLogCore(kUnityServicesLogLevelError, @"E", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define USRVLogWarning(fmt, ...) USRVLogCore(kUnityServicesLogLevelWarning, @"W", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define USRVLogInfo(fmt, ...) USRVLogCore(kUnityServicesLogLevelInfo, @"I", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define USRVLogDebug(fmt, ...) USRVLogCore(kUnityServicesLogLevelDebug, @"D", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface USRVDeviceLog : NSObject
+ (void)setLogLevel:(UnityServicesLogLevel)logLevel;
+ (UnityServicesLogLevel)getLogLevel;
@end


