#import "UnityAds+Testability.h"

@class UnityAds;
@class UADSSdkProperties;

@implementation UnityAds (Testability)
+(void)resetForTest {
    NSLog(@"resetting UnityAds for testing");
    [UADSSdkProperties setInitialized:NO];
}
@end
