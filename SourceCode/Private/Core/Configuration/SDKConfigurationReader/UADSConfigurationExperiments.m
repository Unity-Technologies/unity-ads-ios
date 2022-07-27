#import "UADSConfigurationExperiments.h"
#import "NSDictionary+Filter.h"

#define NEXT_SESSION_FLAGS     @[@"tsi", @"tsi_upii", @"tsi_p", @"tsi_nt", @"tsi_prr", @"tsi_prw"]
#define NEXT_SESSION_FLAGS_SET [NSSet setWithArray: NEXT_SESSION_FLAGS]


@interface UADSConfigurationExperiments ()
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *json;
@end

@implementation UADSConfigurationExperiments
+ (instancetype)newWithJSON: (NSDictionary<NSString *, NSString *> *)json {
    UADSConfigurationExperiments *obj = [UADSConfigurationExperiments new];

    obj.json = json;
    return obj;
}

- (BOOL)isTwoStageInitializationEnabled {
    return [_json[@"tsi"] boolValue] ? : false;
}

- (BOOL)isForcedUpdatePIIEnabled {
    return [_json[@"tsi_upii"] boolValue] ? : false;
}

- (BOOL)isPOSTMethodInConfigRequestEnabled {
    return [_json[@"tsi_p"] boolValue] ? : false;
}

- (BOOL)isForwardExperimentsToWebViewEnabled {
    return [_json[@"fff"] boolValue] ? : false;
}

- (BOOL)isHeaderBiddingTokenGenerationEnabled {
    return [_json[@"tsi_nt"] boolValue] ? : false;
}

- (BOOL)isPrivacyRequestEnabled {
    return [_json[@"tsi_prr"] boolValue] ? : false;
}

- (BOOL)isPrivacyWaitEnabled {
    return [_json[@"tsi_prw"] boolValue] ? : false;
}

- (NSDictionary<NSString *, NSString *> *)nextSessionFlags {
    return [self.json uads_filter:^BOOL (NSString *_Nonnull key, NSString *_Nonnull obj) {
        return [NEXT_SESSION_FLAGS_SET containsObject: key];
    }];
}

- (NSDictionary<NSString *, NSString *> *)currentSessionFlags {
    return [self.json uads_filter:^BOOL (NSString *_Nonnull key, NSString *_Nonnull obj) {
        return ![NEXT_SESSION_FLAGS_SET containsObject: key];
    }];
}

@end
