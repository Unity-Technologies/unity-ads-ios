#import "UADSConfigurationExperimentValue.h"

#define NEXT_SESSION_FLAGS     @[@"tsi_prw", @"s_init", @"s_pte", @"s_ntf", @"s_nrq", @"s_wvrq", @"s_wd"]
#define NEXT_SESSION_FLAGS_SET [NSSet setWithArray: NEXT_SESSION_FLAGS]

@implementation UADSConfigurationExperimentValue
+ (instancetype)newWithKey: (NSString *)key json: (id)value {
    UADSConfigurationExperimentValue *obj = [UADSConfigurationExperimentValue new];

    if ([value isKindOfClass: NSDictionary.class]) {
        NSString *applied = [value valueForKey: @"applied"];
        obj.nextSession = applied != nil ? [applied isEqualToString: @"next"] : true; // default is next session
        obj.enabled = [[value valueForKey: @"value"] boolValue];
    } else {
        obj.nextSession = [NEXT_SESSION_FLAGS_SET containsObject: key];
        obj.enabled = [value boolValue];
    }

    return obj;
}

@end
