#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "UADSOverlayEventProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSOverlayDelegateProxy : NSObject <SKOverlayDelegate>

- (instancetype)initWithEventHandler: (id<UADSOverlayEventProtocol>)handler;

@end

NS_ASSUME_NONNULL_END
