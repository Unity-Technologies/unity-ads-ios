#import "USRVResolve.h"
#import <netdb.h>
#import <arpa/inet.h>
#import "USRVResolveError.h"

@implementation USRVResolve

- (instancetype)initWithHostName:(NSString *)hostName {
    self = [super init];
    
    if (self) {
        [self setHostName:hostName];
        [self setCanceled:false];
    }
    
    return self;
}

- (void)resolve {
    self.blockCondition = [[NSCondition alloc] init];
    [self.blockCondition lock];

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
            self.error = NSStringFromResolveError(kUnityServicesResolveErrorUnknownHost);
            self.errorMessage = @"The host was invalid or unknown";
        }
        
        [self openBlock];
    });
    
    BOOL success = [self.blockCondition waitUntilDate:[[NSDate alloc] initWithTimeIntervalSinceNow:30]];
    [self.blockCondition unlock];
    
    if (!success) {
        self.error = NSStringFromResolveError(kUnityServicesResolveErrorTimedOut);
        self.errorMessage = @"Resolving host timed out";
    }
}

- (void)openBlock {
    [self.blockCondition lock];
    [self.blockCondition signal];
    [self.blockCondition unlock];
}

- (void)cancel {
    [self setCanceled:true];
    [self openBlock];
}

@end
