#import "UADSResolve.h"
#import <netdb.h>
#import <arpa/inet.h>
#import "UADSResolveError.h"

@implementation UADSResolve

- (instancetype)initWithHostName:(NSString *)hostName {
    self = [super init];
    
    if (self) {
        [self setHostName:hostName];
    }
    
    return self;
}

- (void)resolve {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        const char* hostnameCstring = [self.hostName UTF8String];
        struct hostent *host_entry = gethostbyname(hostnameCstring);
        char *buff;
        
        if (host_entry) {
            buff = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
            self.address = [NSString stringWithCString:buff encoding:NSUTF8StringEncoding];
        }
        else {
            self.address = NULL;
            self.error = NSStringFromResolveError(kUnityAdsResolveErrorUnknownHost);
            self.errorMessage = @"The host was invalid or unknown";
        }
        
        [self openBlock];
    });
    
    self.blockCondition = [[NSCondition alloc] init];
    [self.blockCondition lock];
    BOOL success = [self.blockCondition waitUntilDate:[[NSDate alloc] initWithTimeIntervalSinceNow:30]];
    [self.blockCondition unlock];
    
    if (!success) {
        self.error = NSStringFromResolveError(kUnityAdsResolveErrorTimedOut);
        self.errorMessage = @"Resolving host timed out";
    }
}

- (void)openBlock {
    [self.blockCondition lock];
    [self.blockCondition signal];
    [self.blockCondition unlock];
}

@end