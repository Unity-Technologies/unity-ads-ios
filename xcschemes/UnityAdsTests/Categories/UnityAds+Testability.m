#import "UnityAds+Testability.h"

@class UnityAds;
@class USRVSdkProperties;

@implementation UnityAds (Testability)
+(void)resetForTest {
    NSLog(@"resetting UnityAds for testing");
    [USRVSdkProperties setInitialized:NO];
}
@end
