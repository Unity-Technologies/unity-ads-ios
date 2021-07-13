#import <Foundation/Foundation.h>
#import "UnityAdsShowDelegate.h"
#import "UADSAbstractModuleDelegate.h"
NS_ASSUME_NONNULL_BEGIN



@interface UADShowDelegateWrapper : NSObject<UADSAbstractModuleDelegate, UnityAdsShowDelegate>
+ (instancetype)newWithOriginalDelegate: (nullable id<UnityAdsShowDelegate>)delegate;
- (void)unityAdsDidShowConsent: (NSString *)placementId; //
@end

NS_ASSUME_NONNULL_END
