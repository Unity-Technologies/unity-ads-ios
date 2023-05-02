#import "UADSDeviceInfoReader.h"
#import "UADSPIIDataProvider.h"
#import "UADSPrivacyStorage.h"
#import "UADSPIITrackingStatusReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceInfoReaderGate : NSObject<UADSDeviceInfoReader>
+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original
               withPrivacyReader: (id<UADSPrivacyResponseReader>)privacyReader;
@end

NS_ASSUME_NONNULL_END
