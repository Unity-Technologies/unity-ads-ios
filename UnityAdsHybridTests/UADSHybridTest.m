#import <Foundation/Foundation.h>
#import "UADSWebViewCallback.h"
#import "UADSHybridTest.h"

static BOOL finished = NO;

@implementation UADSHybridTest : NSObject 

+ (void)WebViewExposed_onTestResult:(NSNumber *)failures callback:(UADSWebViewCallback *)callback {
    NSAssert(failures.integerValue == 0, @"Hybrid Tests have FAILED - check logs");
    finished = YES;
}

+(BOOL)didFinish {
    return finished;
}

@end