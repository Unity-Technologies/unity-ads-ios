#import "UADSShowModuleOperation.h"

static NSString *kUADSShowModuleStateOrientationKey = @"orientation";
static NSString *kUADSShowModuleStateRotationKey = @"shouldAutorotate";
static NSString *kUADSShowModuleStateOptionsKey = @"showOptions";

@implementation UADSShowModuleOperation

- (NSDictionary *)dictionary {
    
    NSMutableDictionary *optionsDictionary = [NSMutableDictionary dictionaryWithDictionary: self.orientationState];
    optionsDictionary[kUADSShowModuleStateOptionsKey] = self.options.dictionary;
    optionsDictionary[kUADSShowModuleStateRotationKey] = @(self.shouldAutorotate);

    
    return @{
        kUADSOptionsDictionaryKey: optionsDictionary,
        kUADSTimestampKey: self.time,
        kUADSPlacementIDKey: self.placementID,
        kUADSListenerIDKey: self.id
    };
}

- (NSString *)methodName {
    return @"show";
}

@end
