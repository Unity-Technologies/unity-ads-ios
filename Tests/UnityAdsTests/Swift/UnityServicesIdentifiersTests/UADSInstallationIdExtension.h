#import "UADSIdStore.h"
#import "UADSInstallationId.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSInstallationId (Tests)

- (instancetype)initWithInstallationIdStore:(id<UADSIdStore>)installationIdStore
                           analyticsIdStore:(id<UADSIdStore>)analyticsIdStore
                            unityAdsIdStore:(id<UADSIdStore>)unityAdsIdStore;

@end

NS_ASSUME_NONNULL_END
