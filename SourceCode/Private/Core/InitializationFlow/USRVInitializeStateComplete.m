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

- (void)startWithCompletion:(void (^)(void))completion error:(void (^)(NSError * _Nonnull))error {
    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration: moduleName];

        if (moduleConfiguration) {
            [moduleConfiguration initCompleteState: self.configuration];
        }
    }
    completion();
}

@end
