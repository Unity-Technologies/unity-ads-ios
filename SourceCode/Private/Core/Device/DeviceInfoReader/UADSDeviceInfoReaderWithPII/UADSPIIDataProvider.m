#import "UADSPIIDataProvider.h"
#import "USRVDevice.h"

@implementation UADSPIIDataProviderBase

- (nonnull NSString *)advertisingTrackingID {
    return [USRVDevice getAdvertisingTrackingId];
}

- (nonnull NSString *)vendorID {
    return [USRVDevice getVendorIdentifier];
}

@end
