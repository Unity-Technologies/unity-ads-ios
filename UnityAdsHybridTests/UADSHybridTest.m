#import <Foundation/Foundation.h>
#import "USRVWebViewCallback.h"
#import "UADSHybridTest.h"

static BOOL finished = NO;
static int fails = 0;

@implementation UADSHybridTest : NSObject 

+ (void)WebViewExposed_onTestResult:(NSNumber *)failures callback:(USRVWebViewCallback *)callback {
    fails = [failures intValue];
    finished = YES;
}

+ (BOOL)didFinish {
    return finished;
}

+ (int)getFailures {
    return fails;
}

@end
