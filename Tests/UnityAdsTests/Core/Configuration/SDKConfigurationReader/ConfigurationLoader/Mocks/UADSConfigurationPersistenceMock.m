#import "UADSConfigurationPersistenceMock.h"
#import "UADSTools.h"

@implementation UADSConfigurationPersistenceMock

- (instancetype)init {
    SUPER_INIT;
    self.receivedConfig = @[];
    return self;
}

- (void)saveConfiguration: (USRVConfiguration *)configuration {
    _receivedConfig = [_receivedConfig arrayByAddingObjectsFromArray: @[configuration]];
}

@end
