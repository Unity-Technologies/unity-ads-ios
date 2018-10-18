#import "UADSAdsModuleConfiguration.h"
#import "UPURPurchasingModuleConfiguration.h"

@implementation UPURPurchasingModuleConfiguration

-(NSArray<NSString *> *)getWebAppApiClassList {
    return @[@"UPURApiCustomPurchasing"];
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
