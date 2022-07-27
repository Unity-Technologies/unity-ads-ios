#import "UADSUserAgentStorage.h"
#import "USRVPreferences.h"
#import "WKWebView+UserAgent.h"
#import "USRVDevice.h"

NSString *const kUADSLastKnownSystemVersionKey = @"com.unity.ads.lastSystemVersion";
NSString *const kUADSLastKnownUserAgent = @"com.unity.ads.lastKnownUserAgent";

@implementation UADSUserAgentStorage

- (NSString *)userAgent {
    __block NSString *userAgent;

    dispatch_on_main_sync(^{
        userAgent = self.shouldGenerateNew ? [self generateAndSave] : self.lastKnownUserAgent;
    });
    return userAgent;
}

- (void)generateAndSaveIfNeed {
    if (self.shouldGenerateNew) {
        [self generateAndSave];
    }
}

- (NSString *)generateAndSave {
    NSString *newUserAgent = [WKWebView uads_getUserAgentSync];

    [USRVPreferences setString: newUserAgent
                        forKey: kUADSLastKnownUserAgent];
    return newUserAgent;
}

- (NSString *)lastKnownUserAgent {
    return [USRVPreferences getString: kUADSLastKnownUserAgent];
}

- (NSString *)lastKnownSystem {
    NSString *system = [USRVPreferences getString: kUADSLastKnownSystemVersionKey];

    if (![system isEqual: [USRVDevice getOsVersion]]) {
        [self saveCurrentSystem];
    }

    return system;
}

- (void)saveCurrentSystem {
    NSString *system = [USRVDevice getOsVersion];

    [USRVPreferences setString: system
                        forKey: kUADSLastKnownSystemVersionKey];
}

- (BOOL)shouldGenerateNew {
    return ![self.lastKnownSystem isEqual: [USRVDevice getOsVersion]];
}

@end
