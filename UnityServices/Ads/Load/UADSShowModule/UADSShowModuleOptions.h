#import "UADSShowOptions.h"

NS_ASSUME_NONNULL_BEGIN
static NSString *const kSupportedOrientationsKey = @"supportedOrientations";
static NSString *const kSupportedOrientationsPlistKey = @"supportedOrientationsPlist";
static NSString *const kStatusBarOrientationKey = @"statusBarOrientation";
static NSString *const kStatusBarHiddenKey = @"statusBarHidden";
static NSString *kUADSShowModuleStateRotationKey = @"shouldAutorotate";

static NSString *kUADSShowModuleStateOrientationKey = @"orientation";
static NSString *kUADSShowModuleStateDisplayOptionsKey = @"display";

@interface UADSShowModuleOptions : NSObject<UADSDictionaryConvertible>
@property (nonatomic) bool shouldAutorotate;
@property (nonatomic) bool statusBarOrientation;
@property (nonatomic) bool isStatusBarHidden;
@property (nonatomic) int supportedOrientations;
@property (nonatomic) NSArray<NSString *> *supportedOrientationsPlist;
@property (nonatomic, strong) UADSShowOptions * options;
-(NSDictionary *)displayOptions;
@end

NS_ASSUME_NONNULL_END
