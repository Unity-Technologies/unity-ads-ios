#import "UADSWebViewEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSOverlayWebViewEvent : UADSWebViewEventBase

+ (instancetype)newWillStartPresentation;
+ (instancetype)newDidFinishPresentation;
+ (instancetype)newWillStartDismissal;
+ (instancetype)newDidFinishDismissal;
+ (instancetype)newDidFailToLoadWithParams: (NSArray *_Nullable)params;

@end

NS_ASSUME_NONNULL_END
