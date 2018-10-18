#import "UADSBannerModuleConfiguration.h"
#import "UADSPlacement.h"

@implementation UADSBannerModuleConfiguration

-(NSArray<NSString *> *)getWebAppApiClassList {
    return @[
            @"UADSApiBanner",
            @"UADSApiBannerListener"
    ];
}

-(BOOL)resetState:(USRVConfiguration *)configuration {
    return true;
}

-(BOOL)initModuleState:(USRVConfiguration *)configuration {
    return true;
}

-(BOOL)initErrorState:(USRVConfiguration *)configuration state:(NSString *)state message:(NSString *)message {
    return true;
}

-(BOOL)initCompleteState:(USRVConfiguration *)configuration {
    return true;
}


@end
