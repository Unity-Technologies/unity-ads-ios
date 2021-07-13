#import "UnityAdsLoadDelegate.h"
#import "UADSAbstractModuleDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSLoadModuleDelegateWrapper : NSObject<UnityAdsLoadDelegate, UADSAbstractModuleDelegate>
+ (instancetype)newWithAdsDelegate: (id<UnityAdsLoadDelegate>)decorated;
@end

NS_ASSUME_NONNULL_END
