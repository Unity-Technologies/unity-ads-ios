#import "UADSPIIDataSelector.h"
#import "UADSJsonStorageKeyNames.h"
#import "NSDictionary+Merge.h"
#import "NSDictionary+Filter.h"

@interface UADSPIIDataSelectorBase ()
@property (nonatomic, strong) id<UADSJsonStorageReader> jsonStorage;
@property (nonatomic, strong) id<UADSPIIDataSelectorConfig> piiConfig;
@property (nonatomic, strong) id<UADSPIITrackingStatusReader> statusReader;
@end

@implementation UADSPIIDataSelectorBase
+ (id<UADSPIIDataSelector>)newWithJsonStorage: (id<UADSJsonStorageReader>)jsonStorage
                              andStatusReader: (id<UADSPIITrackingStatusReader>)statusReader
                                 andPIIConfig: (id<UADSPIIDataSelectorConfig>)piiConfig {
    UADSPIIDataSelectorBase *obj = [UADSPIIDataSelectorBase new];

    obj.piiConfig = piiConfig;
    obj.jsonStorage = jsonStorage;
    obj.statusReader = statusReader;
    return obj;
}

- (UADSPIIDecisionData *)whatToDoWithPII {
    switch (_statusReader.privacyMode) {
        case kUADSPrivacyModeNone:
            return self.allowedTrackingDecision;

        case kUADSPrivacyModeNull:
            return self.allowedTrackingDecision;

        case kUADSPrivacyModeApp:
            return self.notAllowedDecision;

        case kUADSPrivacyModeUndefined:
            return self.notAllowedDecision;

        case kUADSPrivacyModeMixed:
            return self.mixedModeDecision;
    }

    return [UADSPIIDecisionData newIncludeWithAttributes: self.piiContentsFromTheStorage];
}

- (UADSPIIDecisionData *)allowedTrackingDecision {
    if (_piiConfig.isForcedUpdatePIIEnabled) {
        return [UADSPIIDecisionData newUpdateWithAttributes: self.piiContentsFromTheStorage];
    }

    return [UADSPIIDecisionData newIncludeWithAttributes: self.piiContentsFromTheStorage];
}

- (UADSPIIDecisionData *)mixedModeDecision {
    if (_statusReader.userNonBehavioralFlag) {
        return [UADSPIIDecisionData newIncludeWithAttributes: self.userNonBehavioralAttribute];
    } else {
        return [self.allowedTrackingDecision decisionAppending: self.userNonBehavioralAttribute];
    }
}

- (NSDictionary *)userNonBehavioralAttribute {
    return @{
        [UADSJsonStorageKeyNames userNonBehavioralFlagKey]: @(_statusReader.userNonBehavioralFlag)
    };
}

- (UADSPIIDecisionData *)notAllowedDecision {
    return [UADSPIIDecisionData newExclude];
}

- (NSDictionary *)piiContentsFromTheStorage {
    NSDictionary *contents = typecast([_jsonStorage getValueForKey: self.piiContainerKey], [NSDictionary class]) ? : @{};

    return [self normalized: contents];
}

- (NSString *)piiContainerKey {
    return [UADSJsonStorageKeyNames piiContainerKey];
}

- (NSString *)normalizeKeyToPII: (NSString *)original {
    return [UADSJsonStorageKeyNames attributeKeyForPIIContainer: original];
}

- (NSDictionary *)normalized: (NSDictionary *)original {
    return [original uads_mapKeys:^id _Nonnull (id _Nonnull key) {
        return [self normalizeKeyToPII: key];
    }];
}

@end
