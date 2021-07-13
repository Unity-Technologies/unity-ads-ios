#import "UADSAdUnitViewHandler.h"
#import "UADSWebPlayerView.h"

extern NSString *const UADSWebPlayerViewId;

@interface UADSWebPlayerHandler : UADSAdUnitViewHandler
@property (nonatomic, strong) UADSWebPlayerView *webPlayerView;
@end
