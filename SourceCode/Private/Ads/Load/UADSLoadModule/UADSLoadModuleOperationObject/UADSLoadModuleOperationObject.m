#import "UADSLoadModuleOperationObject.h"

@implementation UADSLoadModuleOperationObject
- (NSString *)methodName {
    return @"load";
}

- (nonnull NSString *)className {
    return kWebViewClassName;
}

@end
