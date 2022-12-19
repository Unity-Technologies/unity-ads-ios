#import "USRVInitializeStateInitModules.h"
#import "USRVModuleConfiguration.h"
#import "USRVInitializeStateConfig.h"
@implementation USRVInitializeStateInitModules : USRVInitializeState

- (instancetype)execute {
    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration: moduleName];

        if (moduleConfiguration) {
            [moduleConfiguration initModuleState: self.configuration];
        }
    }

    id nextState = [[USRVInitializeStateConfig alloc] initWithConfiguration: self.configuration
                                                                    retries: 0
                                                                 retryDelay: [self.configuration retryDelay]];

    return nextState;
}


- (void)startWithCompletion:(void (^)(void))completion error:(void (^)(NSError * _Nonnull))error {
    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration: moduleName];

        if (moduleConfiguration) {
            [moduleConfiguration initModuleState: self.configuration];
        }
    }
    
    completion();

}
@end
