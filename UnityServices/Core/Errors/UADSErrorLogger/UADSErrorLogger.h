#import <Foundation/Foundation.h>
#import "UADSInternalError.h"
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger,UADSErrorHandlerType) {
    kUADSErrorHandlerTypeShowModule,
    UADSErrorHandlerTypeLoadModule,
};

@protocol UADSErrorHandler <NSObject>


-(void)catchError: (UADSInternalError *)error;

@end

@interface UADSErrorLogger : NSObject<UADSErrorHandler>
+(instancetype)newWithType: (UADSErrorHandlerType)type;
@end

NS_ASSUME_NONNULL_END
