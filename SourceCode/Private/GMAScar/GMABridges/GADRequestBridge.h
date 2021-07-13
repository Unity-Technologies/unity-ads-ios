#import "UADSProxyReflection.h"
#import "GADAdInfoBridge.h"
#import "GADQueryInfoBridge.h"

NS_ASSUME_NONNULL_BEGIN

@class GADAdInfoBridge;

@interface GADRequestBridge : UADSProxyReflection
@property (strong, nonatomic) GADAdInfoBridge *adInfo;
+ (instancetype)getNewRequest;
@end

NS_ASSUME_NONNULL_END
