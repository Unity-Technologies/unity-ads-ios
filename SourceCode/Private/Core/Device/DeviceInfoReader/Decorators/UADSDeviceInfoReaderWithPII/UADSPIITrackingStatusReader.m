#import "UADSPIITrackingStatusReader.h"
#import "UADSJsonStorageKeyNames.h"
#import "NSDictionary+Merge.h"

static NSString *const kPrivacyModeAppString = @"app";
static NSString *const kPrivacyModeNoneString = @"none";
static NSString *const kPrivacyModeMixedString = @"mixed";

UADSPrivacyMode uads_privacyModeFromString(NSString *modeString) {
    if (modeString == NULL) {
        return kUADSPrivacyModeNull;
    }

    NSString *lowercased = [modeString lowercaseString];

    if ([lowercased isEqualToString: kPrivacyModeAppString]) {
        return kUADSPrivacyModeApp;
    }

    if ([lowercased isEqualToString: kPrivacyModeNoneString]) {
        return kUADSPrivacyModeNone;
    }

    if ([lowercased isEqualToString: kPrivacyModeMixedString]) {
        return kUADSPrivacyModeMixed;
    }

    return kUADSPrivacyModeUndefined;
}

NSString * uads_privacyModeString(UADSPrivacyMode mode) {
    switch (mode) {
        case kUADSPrivacyModeApp:
            return kPrivacyModeAppString;

        case kUADSPrivacyModeNone:
            return kPrivacyModeNoneString;

        case kUADSPrivacyModeMixed:
            return kPrivacyModeMixedString;

        case kUADSPrivacyModeUndefined:
            return @"undefined";

        default:
            return nil;

            break;
    }
}

@interface UADSPIITrackingStatusReaderBase ()
@property (nonatomic, strong) id<UADSJsonStorageReader> storageReader;
@end

@implementation UADSPIITrackingStatusReaderBase
+ (instancetype)newWithStorageReader: (id<UADSJsonStorageReader>)storageReader {
    UADSPIITrackingStatusReaderBase *base = [UADSPIITrackingStatusReaderBase new];

    base.storageReader = storageReader;
    return base;
}

- (UADSPrivacyMode)privacyMode {
    if (self.userPrivacyMode == kUADSPrivacyModeNull && self.spmPrivacyMode == kUADSPrivacyModeNull) {
        return kUADSPrivacyModeNull;
    }

    if (self.userPrivacyMode == kUADSPrivacyModeApp || self.spmPrivacyMode == kUADSPrivacyModeApp) {
        return kUADSPrivacyModeApp;
    }

    if (self.userPrivacyMode == kUADSPrivacyModeMixed || self.spmPrivacyMode == kUADSPrivacyModeMixed) {
        return kUADSPrivacyModeMixed;
    }

    if (self.userPrivacyMode == kUADSPrivacyModeNone || self.spmPrivacyMode == kUADSPrivacyModeNone) {
        return kUADSPrivacyModeNone;
    }

    return kUADSPrivacyModeUndefined;
}

- (UADSPrivacyMode)userPrivacyMode {
    NSString *privacyMode = [self.storageReader getValueForKey: [UADSJsonStorageKeyNames privacyModeKey]];

    return uads_privacyModeFromString(privacyMode);
}

- (UADSPrivacyMode)spmPrivacyMode {
    NSString *privacyMode = [self.storageReader getValueForKey: [UADSJsonStorageKeyNames privacySPMModeKey]];

    return uads_privacyModeFromString(privacyMode);
}

- (NSNumber *)userNonBehavioralFlag {
    id flag = [self.storageReader getValueForKey: [UADSJsonStorageKeyNames userNonBehavioralValueFlagKey]];

    if (flag == nil) {
        flag = [self.storageReader getValueForKey: [UADSJsonStorageKeyNames userNonbehavioralValueFlagKey]];
    }

    return flag ? @([flag boolValue]) : nil;
}

@end
