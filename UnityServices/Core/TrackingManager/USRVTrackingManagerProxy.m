#import <dlfcn.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#import "USRVDevice.h"
#import "USRVTrackingManagerProxy.h"
#import "USRVWebViewApp.h"

@interface USRVTrackingManagerProxy ()
@property (strong, nonatomic) Class trackingManagerClass;
@end

@implementation USRVTrackingManagerProxy

-(instancetype)init {
    if (self = [super init]) {
        if (![USRVTrackingManagerProxy loadFramework]) {
            USRVLogDebug(@"Can't load ATTrackingManager");
        }
        self.trackingManagerClass = NSClassFromString(@"ATTrackingManager");
    }
    return self;
}

-(BOOL)available {
    return self.trackingManagerClass != nil && [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSUserTrackingUsageDescription"] != nil;
}

-(void)requestTrackingAuthorization{
    if (!self.available) {
        return;
    }
    
    id handler = ^(NSUInteger result) {
        [[USRVWebViewApp getCurrentApp] sendEvent:@"TRACKING_AUTHORIZATION_RESPONSE" category:@"TRACKING_MANAGER" param1:[NSNumber numberWithUnsignedInteger:result], nil];
    };
    SEL requestSelector = NSSelectorFromString(@"requestTrackingAuthorizationWithCompletionHandler:");
    if ([self.trackingManagerClass respondsToSelector:requestSelector]) {
        [self.trackingManagerClass performSelector:requestSelector withObject:handler];
    }
}

-(NSUInteger)trackingAuthorizationStatus {
    if (!self.available) {
        return 0;
    }
    NSUInteger value = [[self.trackingManagerClass valueForKey:@"trackingAuthorizationStatus"] unsignedIntegerValue];
    return value;
}

+(USRVTrackingManagerProxy*)sharedInstance {
    static USRVTrackingManagerProxy* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[USRVTrackingManagerProxy alloc] init];
    });
    return instance;
}

+ (BOOL)isFrameworkPresent {
    id attClass = objc_getClass("ATTrackingManager");

    if (attClass) {
        return YES;
    }
    return NO;
}

+ (BOOL)loadFramework {
    NSString *frameworkLocation;

    if (![USRVTrackingManagerProxy isFrameworkPresent]) {
        USRVLogDebug(@"AppTrackingTransparency Framework is not present, trying to load it.");
        if ([USRVDevice isSimulator]) {
            NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];
            if (frameworkPath) {
                frameworkLocation = [NSString pathWithComponents:@[frameworkPath, @"AppTrackingTransparency.framework", @"AppTrackingTransparency"]];
            }
        }
        else {
            frameworkLocation = [NSString stringWithFormat:@"/System/Library/Frameworks/AppTrackingTransparency.framework/AppTrackingTransparency"];
        }

        dlopen([frameworkLocation cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LAZY);

        if (![USRVTrackingManagerProxy isFrameworkPresent]) {
            USRVLogError(@"AppTrackingTransparency still not present!");
            return NO;
        }
        else {
            USRVLogDebug(@"Succesfully loaded AppTrackingTransparency framework");
            return YES;
        }
    }
    else {
        USRVLogDebug(@"AppTrackingTransparency framework already present");
        return YES;
    }
}

@end
