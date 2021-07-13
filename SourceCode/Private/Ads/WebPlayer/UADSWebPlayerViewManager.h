#import <Foundation/Foundation.h>
#import "UADSWebPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSWebPlayerViewManager : NSObject

+ (instancetype)sharedInstance;

- (void)        addWebPlayerView: (UADSWebPlayerView *)webPlayerView viewId: (NSString *)viewId;

- (void)removeWebPlayerViewWithViewId: (NSString *)viewId;

- (UADSWebPlayerView *_Nullable)getWebPlayerViewWithViewId: (NSString *)viewId;

@end

NS_ASSUME_NONNULL_END
