#import "GMAQuerySignalReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMASignalServiceMock : NSObject<GMASignalService>
- (void)callSuccessForType: (GADQueryInfoAdType)adType
            forPlacementId: (nonnull NSString *)placementId
                    signal: (NSString *)signal;
- (void)callErrorForType: (GADQueryInfoAdType)adType
          forPlacementId: (nonnull NSString *)placementId
                   error: (id<UADSError>)error;
- (NSUInteger)numberOfCallsForType: (GADQueryInfoAdType)type;
@end

NS_ASSUME_NONNULL_END
