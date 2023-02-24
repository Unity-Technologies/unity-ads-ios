#import "UADSShowModuleOperation.h"

@implementation UADSShowModuleOperation

- (NSString *)methodName {
    return @"show";
}

- (nonnull NSString *)className {
    return kWebViewClassName;
}

- (NSDictionary *)dictionary {
    return @{
        kUADSOptionsDictionaryKey: self.options.dictionary,
        kUADSTimestampKey: self.time,
        kUADSPlacementIDKey: self.placementID,
        kUADSListenerIDKey: self.id
    };
}

@end
