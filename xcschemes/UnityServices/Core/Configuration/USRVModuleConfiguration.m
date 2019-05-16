#import "USRVModuleConfiguration.h"

@implementation USRVModuleConfiguration

- (NSArray<NSString*>*)getWebAppApiClassList {
    return NULL;
}

- (BOOL)resetState:(USRVConfiguration *)configuration {
    return true;
}

- (BOOL)initModuleState:(USRVConfiguration *)configuration {
    return true;
}

- (BOOL)initErrorState:(USRVConfiguration *)configuration state:(NSString *)state message:(NSString *)message {
    return true;
}

- (BOOL)initCompleteState:(USRVConfiguration *)configuration {
    return true;
}


@end
