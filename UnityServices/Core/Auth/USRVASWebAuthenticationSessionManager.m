#import "USRVASWebAuthenticationSessionManager.h"

@interface USRVASWebAuthenticationSessionManager ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, USRVASWebAuthenticationSession *> *sessions;

@end

@implementation USRVASWebAuthenticationSessionManager

// Public

+ (instancetype)sharedInstance {
    static USRVASWebAuthenticationSessionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[USRVASWebAuthenticationSessionManager alloc] init];
    });
    return sharedInstance;
}

- (USRVASWebAuthenticationSession *)createSession:(NSURL *)authUrl callbackUrlScheme:(NSString *)callbackUrlScheme {
    USRVASWebAuthenticationSession *session = [[USRVASWebAuthenticationSession alloc] initWithAuthUrl:authUrl callbackUrlScheme:callbackUrlScheme];
    @synchronized (self) {
        [self.sessions setObject:session forKey:[session getSessionId]];
    }
    return session;
}

- (NSDictionary *_Nonnull)getSessions {
    @synchronized (self) {
        return [[NSDictionary alloc] initWithDictionary:self.sessions];
    }
}

- (void)removeSession:(NSString *)sessionId {
    @synchronized (self) {
        [self.sessions removeObjectForKey:sessionId];
    }
}

- (void)cancelSession:(NSString *)sessionId {
    NSDictionary *sessions = [self getSessions];
    USRVASWebAuthenticationSession *session = [sessions objectForKey:sessionId];
    if (session) {
        [session cancel];
    }
}

- (BOOL)startSession:(NSString *)sessionId {
    NSDictionary *sessions = [self getSessions];
    USRVASWebAuthenticationSession *session = [sessions objectForKey:sessionId];
    if (session) {
        return [session start];
    } else {
        return NO;
    }
}

// Private

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessions = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
