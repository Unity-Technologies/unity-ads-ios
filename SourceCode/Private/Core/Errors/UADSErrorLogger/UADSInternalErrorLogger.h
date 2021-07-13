#import <Foundation/Foundation.h>
#import "UADSInternalError.h"
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM (NSInteger, UADSErrorHandlerType) {
    kUADSErrorHandlerTypeShowModule,
    kUADSErrorHandlerTypeLoadModule,
};

@protocol UADSInternalErrorHandler <NSObject>
- (void)catchError: (UADSInternalError *)error;
@end

@interface UADSInternalErrorLogger : NSObject<UADSInternalErrorHandler>
+ (instancetype)newWithType: (UADSErrorHandlerType)type;
@end

NS_ASSUME_NONNULL_END
