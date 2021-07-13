#import "GMAVersionReaderV7.h"
#import "NSInvocation+Convenience.h"
static NSString *const kGMASDKVersionSelector =  @"sdkVersion";
@implementation GMAVersionReaderV7

+ (NSArray<NSString *> *)requiredSelectors {
    return @[kGMASDKVersionSelector];
}

+ (NSString *)sdkVersion {
    return [NSInvocation uads_invokeWithReturnedUsingMethod: kGMASDKVersionSelector
                                                  classType: [[self class] getClass]
                                                     target: nil
                                                       args: @[]];
}

@end
