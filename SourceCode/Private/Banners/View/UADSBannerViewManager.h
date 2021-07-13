#import <Foundation/Foundation.h>
#import "UADSBannerView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetBannerWebPlayerContainerCallback)(UADSBannerView *__nullable bannerView);

@interface UADSBannerViewManager : NSObject

+ (instancetype)sharedInstance;

- (void)        addBannerView: (UADSBannerView *)bannerView bannerAdId: (NSString *)bannerAdId;

- (UADSBannerView *_Nullable)getBannerViewWithBannerAdId: (NSString *)bannerAdId;

- (void)removeBannerViewWithBannerAdId: (NSString *)bannerAdId;

- (void)triggerBannerDidLoad: (NSString *)bannerAdId;

- (void)triggerBannerDidClick: (NSString *)bannerAdId;

- (void)triggerBannerDidLeaveApplication: (NSString *)bannerAdId;

- (void)triggerBannerDidError: (NSString *)bannerAdId error: (UADSBannerError *)error;

@end

NS_ASSUME_NONNULL_END
