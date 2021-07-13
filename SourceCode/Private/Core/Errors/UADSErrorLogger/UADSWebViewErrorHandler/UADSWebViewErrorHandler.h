#import <Foundation/Foundation.h>
#import "UADSGenericError.h"
#import "UADSWebViewEventSender.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSWebViewErrorHandler : NSObject<UADSErrorHandler>
+ (instancetype)newWithEventSender: (id)eventSender;
+ (instancetype)defaultHandler;
@end

NS_ASSUME_NONNULL_END
