#import "USRVASWebAuthenticationSessionManager.h"

@interface USRVASWebAuthenticationSessionManager ()

@property (nonatomic, strong) dispatch_queue_t synchronize;
@property (nonatomic, strong) NSMutableDictionary<NSString *, USRVASWebAuthenticationSession *> *sessions;

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
    __weak USRVASWebAuthenticationSessionManager *weakSelf = self;
    dispatch_async(self.synchronize, ^{
        if (weakSelf) {
            [weakSelf.sessions setObject:session forKey:[session getSessionId]];
        }
    });
    return session;
}

- (void)getSessions:(GetSessionsCallback)callback {
    __weak USRVASWebAuthenticationSessionManager *weakSelf = self;
    dispatch_async(self.synchronize, ^{
        if (weakSelf) {
            callback([[NSDictionary alloc] initWithDictionary:weakSelf.sessions]);
        } else {
            callback([[NSDictionary alloc] init]);
        }
    });
}

- (void)removeSession:(NSString *)sessionId {
    __weak USRVASWebAuthenticationSessionManager *weakSelf = self;
    dispatch_async(self.synchronize, ^{
       if (weakSelf) {
           [weakSelf.sessions removeObjectForKey:sessionId];
       }
    });
}

- (void)cancelSession:(NSString *)sessionId {
    [self getSessions:^(NSDictionary *sessions) {
        USRVASWebAuthenticationSession *session = [sessions objectForKey:sessionId];
        if (session) {
            [session cancel];
        }
    }];
}

- (void)startSession:(NSString *)sessionId callback:(StartSessionCallback)callback {
    [self getSessions:^(NSDictionary *sessions) {
        USRVASWebAuthenticationSession *session = [sessions objectForKey:sessionId];
        if (session) {
            callback([session start]);
        }
    }];
}

// Private

- (instancetype)init {
    self = [super init];
    if (self) {
        self.synchronize = dispatch_queue_create("com.unity3d.ads.USRVASWebAuthenticationSessionManagerQueue", NULL);
        self.sessions = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
