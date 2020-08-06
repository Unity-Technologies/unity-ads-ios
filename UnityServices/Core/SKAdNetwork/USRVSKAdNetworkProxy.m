#import "USRVSKAdNetworkProxy.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import "USRVDevice.h"

@interface USRVSKAdNetworkProxy ()
@property (strong, nonatomic) Class skAdNetworkClass;
@end

@implementation USRVSKAdNetworkProxy

-(instancetype)init {
    if (self = [super init]) {
        if (![USRVSKAdNetworkProxy loadFramework]) {
            USRVLogDebug(@"Can't load StoreKit Dll");
        }
        self.skAdNetworkClass = NSClassFromString(@"SKAdNetwork");
    }
    return self;
}

-(BOOL)available {
    return self.skAdNetworkClass != nil;
}

-(void)updateConversionValue:(NSInteger)conversionValue {
    if (!self.available) {
        return;
    }
    SEL requestSelector = NSSelectorFromString(@"updateConversionValue:");
    if ([self.skAdNetworkClass respondsToSelector:requestSelector]) {
        NSNumber *val = [NSNumber numberWithInteger:conversionValue];
        [self.skAdNetworkClass performSelector:requestSelector withObject:val];
    }
}

-(void)registerAppForAdNetworkAttribution{
    if (!self.available) {
        return;
    }
    SEL requestSelector = NSSelectorFromString(@"registerAppForAdNetworkAttribution:");
    if ([self.skAdNetworkClass respondsToSelector:requestSelector]) {
       [self.skAdNetworkClass performSelector:requestSelector];
    }
}

+(USRVSKAdNetworkProxy*)sharedInstance {
    static USRVSKAdNetworkProxy* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[USRVSKAdNetworkProxy alloc] init];
    });
    return instance;
}

+ (BOOL)isFrameworkPresent {
    id attClass = objc_getClass("SKAdNetwork");
    
    if (attClass) {
        return YES;
    }
    return NO;
}

+ (BOOL)loadFramework {
    NSString *frameworkLocation;
    
    if (![USRVSKAdNetworkProxy isFrameworkPresent]) {
        USRVLogDebug(@"StoreKit.framework is not present, trying to load it.");
        if ([USRVDevice isSimulator]) {
            NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];
            if (frameworkPath) {
                frameworkLocation = [NSString pathWithComponents:@[frameworkPath, @"StoreKit.framework", @"SkAdNetwork"]];
            }
        }
        else {
            frameworkLocation = [NSString stringWithFormat:@"/System/Library/Frameworks/StoreKit.framework/SkAdNetwork"];
        }
        
        dlopen([frameworkLocation cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LAZY);
        
        if (![USRVSKAdNetworkProxy isFrameworkPresent]) {
            USRVLogError(@"StoreKit.framework still not present!");
            return NO;
        }
        else {
            USRVLogDebug(@"Succesfully loaded StoreKit.framework");
            return YES;
        }
    }
    else {
        USRVLogDebug(@"StoreKit.framework already present");
        return YES;
    }
}

@end
