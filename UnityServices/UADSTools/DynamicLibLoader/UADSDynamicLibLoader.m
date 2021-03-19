#import "UADSDynamicLibLoader.h"
#import "UADSTools.h"
#import <dlfcn.h>

static NSString *const kDeviceFrameworkPathTemplate = @"/System/Library/Frameworks/%@.framework/%@";

static void *uads_load_framework_dynamically_at_path(const char *path) {
  return dlopen(path, RTLD_LAZY);
}

void *uads_load_framework_with_name(NSString *framework) {
    NSString *path = [NSString stringWithFormat:kDeviceFrameworkPathTemplate, framework, framework];
    const char *pathChar = path.fileSystemRepresentation;
    void *handle = uads_load_framework_dynamically_at_path(pathChar);
    if (handle) {
        USRVLogDebug(@"Dynamically loaded library %@ at %s", framework, pathChar);
    } else {
        USRVLogError(@"Failed to load library %@ at %s",framework, pathChar);
    }
    return  handle;
}

@interface UADSDynamicLibLoaderContext : NSObject
@property (nonatomic) UADSDynamicLibLoaderState loadState;
@property (nonatomic) void *handle;
@property (nonatomic, copy) NSString *frameworkName;
@end

@implementation UADSDynamicLibLoaderContext
@end

@interface UADSDynamicLibLoader()
@property (nonatomic) UADSDynamicLibLoaderState loadState;
@property (nonatomic) void *handle;
@end

@implementation UADSDynamicLibLoader
static NSMutableDictionary<NSString*, UADSDynamicLibLoaderContext*>* contexts;
static dispatch_queue_t serialSyncQueue;

+(UADSDynamicLibLoaderState)loadState {
    return self.myContext.loadState;
}

+(void)setLoadState: (UADSDynamicLibLoaderState)state {
    self.myContext.loadState = state;
}

+(void *)handle {
    return self.myContext.handle;
}

+(void)setHandle: (void *)handle {
    self.myContext.handle = handle;
}

+ (void)load {
    [super load];
    serialSyncQueue = dispatch_queue_create("com.uads.libloader.queue", DISPATCH_QUEUE_SERIAL);
    contexts = [NSMutableDictionary new];
}

+ (UADSDynamicLibLoaderState)frameworkState {
    return self.loadState;
}

+(UADSDynamicLibLoaderState)loadFrameworkOnce  {
    [self setCurrentLoadState];
    
    self.handle = uads_load_framework_with_name(self.frameworkName);
    
    if (self.handle) {
        self.loadState = kUADSDynamicLibLoaderStateLoaded;
    } else {
        self.loadState = kUADSDynamicLibLoaderStateFailed;
    }
    return self.loadState ;
}

+(UADSDynamicLibLoaderState)loadFrameworkIfNotLoaded {
    if (self.isLoaded) {
        return self.loadState;
    }

    return [self loadFrameworkOnce];
}

+(void)setCurrentLoadState {
    if ([self exists]) {
        self.loadState = kUADSDynamicLibLoaderStateLoaded;
    } else {
        self.loadState = kUADSDynamicLibLoaderStateNotLoaded;
    }
}

+ (NSString *)frameworkName {
    return @"";
}

+ (NSString *)classNameForCheck {
    return @"";
}

+ (BOOL)isLoaded {
    return self.loadState == kUADSDynamicLibLoaderStateLoaded;
}

+ (BOOL)exists {
    return NSClassFromString(self.classNameForCheck) != nil;
}

+ (void)close {
    if (self.handle) {
        dlclose(self.handle);
        self.handle = nil;
    }
    self.loadState = kUADSDynamicLibLoaderStateNotLoaded;
}

+(UADSDynamicLibLoaderContext *)createContext {
    UADSDynamicLibLoaderContext *context = [UADSDynamicLibLoaderContext new];
    context.frameworkName = [self frameworkName];
    return context;
}

+(UADSDynamicLibLoaderContext *)myContext {
    __block UADSDynamicLibLoaderContext *returnedContext;
    dispatch_sync(serialSyncQueue , ^{
        UADSDynamicLibLoaderContext *context = contexts[self.frameworkName];
        if (!context) {
            context = [self createContext];
            context.loadState = kUADSDynamicLibLoaderStateNotLoaded;
            contexts[self.frameworkName] = context;
        }
        returnedContext = context;
    });
    
    return returnedContext;
}
@end
