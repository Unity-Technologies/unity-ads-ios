#import "UADSDeviceIDFIReader.h"
#import "UADSJsonStorageKeyNames.h"
#import "USRVPreferences.h"
#import "USRVDevice.h"
#import "USRVSDKMetrics.h"
#import "UADSTsiMetric.h"
#import "UADSInitializeEventsMetricSender.h"

@implementation UADSDeviceIDFIReaderBase


- (nonnull NSString *)idfi {
    NSString *currentValue = [USRVPreferences getString: kUADSStorageIDFIKey];

    if (currentValue == nil || currentValue.length == 0) {
        currentValue = [[USRVDevice getUniqueEventId] lowercaseString];
        [USRVPreferences setString: currentValue
                            forKey: kUADSStorageIDFIKey];
    }

    return currentValue;
}

- (NSString *)sessionID {
    return [USRVPreferences getString: kUADSStorageAnalyticSessionKey];
}

- (NSString *)userID {
    return [USRVPreferences getString: kUADSStorageAnalyticUserKey];
}

- (NSNumber *)initializationStartTimeStamp {
    return [UADSInitializeEventsMetricSender sharedInstance].initializationStartTimeStamp;
}

@end
