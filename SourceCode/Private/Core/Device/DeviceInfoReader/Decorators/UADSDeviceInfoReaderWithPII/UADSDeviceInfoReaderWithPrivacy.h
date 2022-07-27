#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "UADSPIIDataProvider.h"
#import "UADSPrivacyStorage.h"
#import "UADSPIITrackingStatusReader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceInfoReaderWithPrivacy : NSObject<UADSDeviceInfoReader>
+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original
               withPrivacyReader: (id<UADSPrivacyResponseReader>)privacyReader
             withPIIDataProvider: (id<UADSPIIDataProvider>)dataProvider
                andUserContainer: (id<UADSPIITrackingStatusReader>)userContainer;
@end

NS_ASSUME_NONNULL_END
