#import <Foundation/Foundation.h>
#import "UADSInternalErrorLogger.h"
#import "USRVSDKMetrics.h"
#import "UADSCurrentTimestamp.h"
#import "UADSInitializationStatusReader.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, UADSEventHandlerType) {
    kUADSEventHandlerTypeShowModule,
    kUADSEventHandlerTypeLoadModule,
};

@protocol UADSEventHandler <UADSInternalErrorHandler>
- (void)eventStarted: (NSString *)identifier;
- (void)onSuccess: (NSString *)identifier;
@end

@interface UADSEventHandlerBase : NSObject<UADSEventHandler>

+ (instancetype)newDefaultWithType: (UADSEventHandlerType)type;
+ (instancetype)newWithType: (UADSEventHandlerType)type
               metricSender: (id<ISDKMetrics>)metricSender
            timestampReader: (id<UADSCurrentTimestamp>)timestampReader
           initStatusReader: (id<UADSInitializationStatusReader>)initStatusReader;
@end

NS_ASSUME_NONNULL_END
