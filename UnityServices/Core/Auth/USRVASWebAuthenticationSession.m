#import "USRVASWebAuthenticationSession.h"
#import "USRVDevice.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import "USRVWebAuthSession.h"

@interface USRVASWebAuthenticationSession ()

@property (nonatomic, strong) NSUUID *sessionId;
@property (nonatomic, strong) NSURL *authUrl;
@property (nonatomic, strong) NSString *callbackUrlScheme;
@property (nonatomic, strong) id authSession;

@end

@implementation USRVASWebAuthenticationSession

- (instancetype)initWithAuthUrl:(NSURL *)authSessionUrl callbackUrlScheme:(NSString *)callbackUrlScheme  {
    self = [super init];
    if (self) {
        self.authUrl = authSessionUrl;
        self.callbackUrlScheme = callbackUrlScheme;
        self.sessionId = [NSUUID UUID];
        [self createSession];
    }
    return self;
}

- (void)dealloc {
    self.authSession = nil;
}

// necessary create session wrapper for init. Otherwise assigning authSession in init replaces USRVASWebAuthenticationSession with ASWebAuthenticationSession
- (void)createSession {
    self.authSession = [self initAuthSession:self.authUrl callbackUrlScheme:self.callbackUrlScheme];
}

- (id)initAuthSession:(NSURL *)authUrl callbackUrlScheme:(NSString *)callbackUrlScheme {
    BOOL isAuthenticationServicesFrameworkLoaded = [self loadAuthenticationServicesFramework];

    if (isAuthenticationServicesFrameworkLoaded) {
        NSString *sessionId = [self getSessionId];
        id sessionClass = objc_getClass("ASWebAuthenticationSession");
        if (sessionClass) {
            id sessionAlloc = [sessionClass alloc];
            SEL initSelector = NSSelectorFromString(@"initWithURL:callbackURLScheme:completionHandler:");
            if ([sessionAlloc respondsToSelector:initSelector]) {
                USRVLogDebug(@"ASWebAuthenticationSession responds to init selector");
                IMP initImp = [sessionAlloc methodForSelector:initSelector];
                if (initImp) {
                    USRVLogDebug(@"Got init implementation");
                    id (*initFunc)(id, SEL, id, id, void (^)(NSURL *callbackURL, NSError *error)) = (void *) initImp;
                    return initFunc(sessionAlloc, initSelector, authUrl, callbackUrlScheme, ^(NSURL *callbackURL, NSError *error) {
                        // send an event to the webview
                        [USRVWebAuthSession sendSessionResult:sessionId callbackUrl:callbackURL error:error];
                    });
                }
            }
        }
    }

    return nil;
}

- (NSString *)getSessionId {
    return [_sessionId UUIDString];
}

- (void)cancel {
    if (self.authSession) {
        SEL cancelSelector = NSSelectorFromString(@"cancel");
        if ([self.authSession respondsToSelector:cancelSelector]) {
            USRVLogDebug(@"session responds to cancel selector");
            IMP cancelImp = [self.authSession methodForSelector:cancelSelector];
            if (cancelImp) {
                USRVLogDebug(@"Got cancel implementation");
                BOOL (*cancelFunc)(id, SEL) = (void *) cancelImp;
                USRVLogDebug(@"Trying to cancel authentication session");
                cancelFunc(self.authSession, cancelSelector);
            }
        }
    }
}

- (BOOL)start {
    if (self.authSession) {
        SEL startSelector = NSSelectorFromString(@"start");
        if ([self.authSession respondsToSelector:startSelector]) {
            USRVLogDebug(@"session responds to start selector");
            IMP startImp = [self.authSession methodForSelector:startSelector];
            if (startImp) {
                USRVLogDebug(@"Got start implementation");
                BOOL (*startFunc)(id, SEL) = (void *) startImp;
                USRVLogDebug(@"Trying to start authentication session");
                return startFunc(self.authSession, startSelector);
            }
        }
    }
    return NO;
}

- (BOOL)loadAuthenticationServicesFramework {
    NSString *frameworkLocation;

    if (!objc_getClass("ASWebAuthenticationSession")) {
        USRVLogDebug(@"AuthenticationServices framework not present, trying to load it");
        if ([USRVDevice isSimulator]) {
            NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];
            if (frameworkPath) {
                frameworkLocation = [NSString pathWithComponents:@[frameworkPath, @"AuthenticationServices.framework", @"AuthenticationServices"]];
            }
        }
        else {
            frameworkLocation = [NSString stringWithFormat:@"/System/Library/Frameworks/AuthenticationServices.framework/AuthenticationServices"];
        }

        dlopen([frameworkLocation cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LAZY);

        if (!objc_getClass("ASWebAuthenticationSession")) {
            USRVLogError(@"ASWebAuthenticationSession still not present!");
            return NO;
        }
        else {
            USRVLogDebug(@"Succesfully loaded AuthenticationServices framework");
        }
    }
    else {
        USRVLogDebug(@"AuthenticationServices framework already present");
    }

    return YES;
}

@end
