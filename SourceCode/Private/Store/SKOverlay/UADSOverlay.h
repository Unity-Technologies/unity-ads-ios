#import <Foundation/Foundation.h>
#import "UADSOverlayEventProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSOverlay : NSObject

+ (instancetype)sharedInstance;
- (instancetype)initWithEventHandler: (id<UADSOverlayEventProtocol>)handler;

- (void)show: (NSDictionary *)configDictionary;
- (void)        hide;

@end

NS_ASSUME_NONNULL_END
