#import "UADSAdsModuleConfiguration.h"
#import "UMONMonetizationModuleConfiguration.h"

@implementation UMONMonetizationModuleConfiguration

-(NSArray<NSString *> *)getWebAppApiClassList {
    return @[@"UMONApiMonetizationListener",
            @"UMONApiPlacementContents"];
}

-(BOOL)resetState:(USRVConfiguration *)configuration {
    return false;
}

-(BOOL)initModuleState:(USRVConfiguration *)configuration {
    return false;
}

-(BOOL)initErrorState:(USRVConfiguration *)configuration state:(NSString *)state message:(NSString *)message {
    return false;
}

-(BOOL)initCompleteState:(USRVConfiguration *)configuration {
    return false;
}

@end
