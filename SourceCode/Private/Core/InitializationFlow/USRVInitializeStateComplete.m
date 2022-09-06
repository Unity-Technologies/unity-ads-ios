#import "USRVInitializeStateComplete.h"
#import "USRVModuleConfiguration.h"

@implementation USRVInitializeStateComplete : USRVInitializeState
- (instancetype)execute {
    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration: moduleName];

        if (moduleConfiguration) {
            [moduleConfiguration initCompleteState: self.configuration];
        }
    }

    return NULL;
}

@end
