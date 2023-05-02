#import "UADSDeviceInfoReaderWithPrivacy.h"
#import "UADSJsonStorageKeyNames.h"
#import "NSMutableDictionary+SafeOperations.h"

@interface UADSDeviceInfoReaderWithPrivacy ()
@property (nonatomic, strong) id<UADSDeviceInfoReader>original;
@property (nonatomic, strong) id<UADSPrivacyResponseReader>privacyReader;
@property (nonatomic, strong) id<UADSPIIDataProvider>dataProvider;
@property (nonatomic, strong) id<UADSPIITrackingStatusReader>userContainer;
@end


@implementation UADSDeviceInfoReaderWithPrivacy
+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original
               withPrivacyReader: (id<UADSPrivacyResponseReader>)privacyReader
             withPIIDataProvider: (id<UADSPIIDataProvider>)dataProvider
                andUserContainer: (id<UADSPIITrackingStatusReader>)userContainer {
    UADSDeviceInfoReaderWithPrivacy *decorator = [self new];

    decorator.original = original;
    decorator.privacyReader = privacyReader;
    decorator.dataProvider = dataProvider;
    decorator.userContainer = userContainer;
    return decorator;
}

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSDictionary *info = [_original getDeviceInfoForGameMode: mode];
    NSMutableDictionary *mInfo = [[NSMutableDictionary alloc] initWithDictionary: info];

    if (_privacyReader.responseState == kUADSPrivacyResponseAllowed) {
        mInfo[self.vendorIDKey] = _dataProvider.vendorID;
        mInfo[self.advertisingTrackingIdKey] = _dataProvider.advertisingTrackingID;
    }

    return mInfo;
}

- (NSString *)vendorIDKey {
    return [UADSJsonStorageKeyNames attributeKeyForPIIContainer: kVendorIDKey];
}

- (NSString *)userNonBehavioralFlagKey {
    return UADSJsonStorageKeyNames.userNonBehavioralFlagKey;
}

- (NSString *)advertisingTrackingIdKey {
    return [UADSJsonStorageKeyNames attributeKeyForPIIContainer: kAdvertisingTrackingIdKey];
}

@end
