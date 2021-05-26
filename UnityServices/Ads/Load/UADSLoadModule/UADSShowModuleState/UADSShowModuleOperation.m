#import "UADSShowModuleOperation.h"

@implementation UADSShowModuleOperation

- (NSString *)methodName {
    return @"show";
}

-(NSDictionary *)dictionary {
    return @{
        kUADSOptionsDictionaryKey: self.options.dictionary,
        kUADSTimestampKey: self.time,
        kUADSPlacementIDKey: self.placementID,
        kUADSListenerIDKey: self.id
    };
}

@end
