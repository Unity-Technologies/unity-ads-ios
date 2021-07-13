#import <Foundation/Foundation.h>
#import "UADSBannerViewDelegate.h"

@interface BannerTestDelegate : NSObject <UADSBannerViewDelegate>

@property (nonatomic, copy) void (^ didLoadBlock)(UADSBannerView *);
@property (nonatomic, copy) void (^ didClickBlock)(UADSBannerView *);
@property (nonatomic, copy) void (^ didLeaveApplicationBlock)(UADSBannerView *);
@property (nonatomic, copy) void (^ didErrorBlock)(UADSBannerView *, UADSBannerError *error);

@end
