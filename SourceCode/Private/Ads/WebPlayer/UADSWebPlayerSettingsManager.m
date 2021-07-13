#import "UADSWebPlayerSettingsManager.h"

@interface UADSWebPlayerSettingsManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *webPlayerSettings;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *webPlayerEventSettings;

@end

@implementation UADSWebPlayerSettingsManager

// Public

+ (instancetype)sharedInstance {
    static UADSWebPlayerSettingsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[UADSWebPlayerSettingsManager alloc] init];
    });
    return sharedInstance;
}

- (void)addWebPlayerSettings: (NSString *)viewId settings: (NSDictionary *)settings {
    @synchronized (self) {
        [self.webPlayerSettings setObject: settings
                                   forKey: viewId];
    }
}

- (void)removeWebPlayerSettings: (NSString *)viewId {
    @synchronized (self) {
        [self.webPlayerSettings removeObjectForKey: viewId];
    }
}

- (NSDictionary *_Nonnull)getWebPlayerSettings: (NSString *)viewId {
    @synchronized (self) {
        NSDictionary *settings = [self.webPlayerSettings objectForKey: viewId];

        if (!settings) {
            settings = [[NSDictionary alloc] init];
        }

        return settings;
    }
}

- (void)addWebPlayerEventSettings: (NSString *)viewId settings: (NSDictionary *)settings {
    @synchronized (self) {
        [self.webPlayerEventSettings setObject: settings
                                        forKey: viewId];
    }
}

- (void)removeWebPlayerEventSettings: (NSString *)viewId {
    @synchronized (self) {
        [self.webPlayerEventSettings removeObjectForKey: viewId];
    }
}

- (NSDictionary *_Nonnull)getWebPlayerEventSettings: (NSString *)viewId {
    @synchronized (self) {
        NSDictionary *settings = [self.webPlayerEventSettings objectForKey: viewId];

        if (!settings) {
            settings = [[NSDictionary alloc] init];
        }

        return settings;
    }
}

// Private

- (instancetype)init {
    self = [super init];

    if (self) {
        self.webPlayerSettings = [[NSMutableDictionary alloc] init];
        self.webPlayerEventSettings = [[NSMutableDictionary alloc] init];
    }

    return self;
}

@end
