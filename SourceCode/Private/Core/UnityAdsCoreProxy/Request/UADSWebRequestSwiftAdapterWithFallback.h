#import <Foundation/Foundation.h>
#import "USRVWebRequest.h"
#import "UADSConfigurationMetricTagsReader.h"
#import "USRVSDKMetrics.h"

extern NSString *const UADSSwiftErrorDomain;

@interface UADSWebRequestSwiftAdapterWithFallback : NSObject <USRVWebRequest>

+ (instancetype)newWithOriginal: (id<USRVWebRequest>)original metricSender: (id<ISDKMetrics>)metricSender;
+ (instancetype)newWithOriginal: (id<USRVWebRequest>)original
                fallbackFactory: (id<IUSRVWebRequestFactory>)fallbackFactory
                   metricSender: (id<ISDKMetrics>)metricSender;
@end
