#import <UnityAds/UnityAds.h>

@interface UnityBannerTestDelegate : NSObject<UnityAdsBannerDelegate>

@property(nonatomic, copy) void (^didLoadBlock)(NSString *placementId, UIView *view);
@property(nonatomic, copy) void (^didUnloadBlock)(NSString *placementId);
@property(nonatomic, copy) void (^didShowBlock)(NSString *placementId);
@property(nonatomic, copy) void (^didHideBlock)(NSString *placementId);
@property(nonatomic, copy) void (^didClickBlock)(NSString *placementId);
@property(nonatomic, copy) void (^didErrorBlock)(NSString *message);

@end
