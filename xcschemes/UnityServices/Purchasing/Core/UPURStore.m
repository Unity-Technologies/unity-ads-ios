
#import "UPURStore.h"

NSString *NSStringFromUPURAppStore(UPURStore store) {
    switch (store) {
        case kUPURStoreGooglePlay:
            return @"GOOGLE_PLAY";
        case kUPURStoreAmazonAppStore:
            return @"AMAZON_APP_STORE";
        case kUPURStoreCloudMoolah:
            return @"CLOUD_MOOLAH";
        case kUPURStoreSamsungApps:
            return @"SAMSUNG_APPS";
        case kUPURStoreXiaomiMiPay:
            return @"XIAOMI_MI_PAY";
        case kUPURStoreMacAppStore:
            return @"MAC_APP_STORE";
        case kUPURStoreAppleAppStore:
            return @"APPLE_APP_STORE";
        case kUPURStoreWinRT:
            return @"WIN_RT";
        case kUPURStoreTizenStore:
            return @"TIZEN_STORE";
        case kUPURStoreFacebookStore:
            return @"FACEBOOK_STORE";
        case kUPURStoreNotSpecified:
            return @"NOT_SPECIFIED";
    }
}
