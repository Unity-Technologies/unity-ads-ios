#import "UnityAds.h"
#import "UADSWebViewMethodInvokeOperation.h"
#import "UADSWebViewApp.h"

@implementation UADSWebViewMethodInvokeOperation

static NSCondition *lock;

- (instancetype)initWithMethod:(NSString *)webViewMethod webViewClass:(NSString *)webViewClass parameters:(NSArray *)parameters waitTime:(int)waitTime {
    self = [super init];
    
    if (self) {
        [self setWebViewClass:webViewClass];
        [self setWebViewMethod:webViewMethod];
        [self setWaitTime:waitTime];
        [self setParameters:parameters];
        [self setSuccess:false];
    }
    
    return self;
}

- (void)main {
    NSString *receiverClass = NSStringFromClass(self.class);
    NSString *receiverSelector = @"callback:";

    [[UADSWebViewApp getCurrentApp] invokeMethod:self.webViewMethod className:self.webViewClass receiverClass:receiverClass callback:receiverSelector params:self.parameters];
    
    if (self.waitTime > 0) {
        UADSLog(@"Locking");
        lock = [[NSCondition alloc] init];
        [lock lock];
        self.success = [lock waitUntilDate:[[NSDate alloc] initWithTimeIntervalSinceNow:self.waitTime]];
        [lock unlock];
        
        if (!self.success) {
            UADSLog(@"Callback timed out!");
        }
    }
}

+ (void)callback:(NSArray *)params {
    if (lock) {
        UADSLog(@"Unlocking");
        [lock lock];
        [lock signal];
        [lock unlock];
    }
}

@end