#import <Foundation/Foundation.h>
#import "UnityAds/UnityAds.h"

#define UADSLogCore(logLevel, format, function, lineNumber, ...) NSLog((@"%@/UnityAds: %s (line:%d) :: " format), logLevel, function, lineNumber, ##__VA_ARGS__);
#define UADSLogError(fmt, ...) UADSLogCore(@"E", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define UADSLogWarning(fmt, ...) UADSLogCore(@"W", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define UADSLogInfo(fmt, ...) UADSLogCore(@"I", fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define UADSLogDebug(fmt, ...)\
    if([UnityAds getDebugMode]) {\
        UADSLogCore(@("D"), fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);\
    }\
