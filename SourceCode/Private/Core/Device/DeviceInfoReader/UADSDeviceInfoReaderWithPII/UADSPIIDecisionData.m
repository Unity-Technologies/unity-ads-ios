#import "UADSPIIDecisionData.h"
#import "UADSJsonStorageKeyNames.h"
#import "NSDictionary+Merge.h"

@interface UADSPIIDecisionData ()
@property (strong, nonatomic) NSDictionary *attributes;
@end

@implementation UADSPIIDecisionData
+ (instancetype)newIncludeWithAttributes: (NSDictionary *)attributes {
    UADSPIIDecisionData *data = [UADSPIIDecisionData new];

    data.attributes = attributes;
    data.resultType = kUADSPIIDataSelectorResultInclude;
    return data;
}

+ (instancetype)newExclude {
    UADSPIIDecisionData *data = [UADSPIIDecisionData new];

    data.resultType = kUADSPIIDataSelectorResultExclude;
    data.attributes = @{};
    return data;
}

+ (instancetype)newUpdateWithAttributes: (NSDictionary *)attributes {
    UADSPIIDecisionData *data = [UADSPIIDecisionData new];

    data.resultType = kUADSPIIDataSelectorResultUpdate;
    data.attributes = attributes;
    return data;
}

- (instancetype)decisionAppending: (NSDictionary *)attributes {
    UADSPIIDecisionData *data = [UADSPIIDecisionData new];

    data.attributes = [self.attributes uads_newdictionaryByMergingWith: attributes];
    data.resultType = self.resultType;
    return data;
}

- (NSArray *)keys {
    return [_attributes allKeys] ? : @[];
}

- (BOOL)updateVendorID {
    return _attributes[self.vendorIDKey] != nil;
}

- (NSString *)vendorIDKey {
    return [UADSJsonStorageKeyNames attributeKeyForPIIContainer: kVendorIDKey];
}

- (BOOL)updateAdvertisingTrackingId {
    return _attributes[self.advertisingTrackingIdKey] != nil;
}

- (NSNumber *)userNonBehavioralFlag {
    return _attributes[self.userNonBehavioralFlagKey];
}

- (NSString *)userNonBehavioralFlagKey {
    return UADSJsonStorageKeyNames.userNonBehavioralFlagKey;
}

- (NSString *)advertisingTrackingIdKey {
    return [UADSJsonStorageKeyNames attributeKeyForPIIContainer: kAdvertisingTrackingIdKey];
}

@end
