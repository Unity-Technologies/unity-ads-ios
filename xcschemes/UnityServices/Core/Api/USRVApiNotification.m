#import "USRVApiNotification.h"
#import "USRVWebViewCallback.h"
#import "USRVNotificationObserver.h"
#import <AVFoundation/AVFoundation.h>

@implementation USRVApiNotification

+ (void)WebViewExposed_addNotificationObserver:(NSString *)name userInfoKeys:(NSArray *)keys callback:(USRVWebViewCallback *)callback {
    [USRVNotificationObserver addObserver:name userInfoKeys:keys targetObject:nil];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeNotificationObserver:(NSString *)name callback:(USRVWebViewCallback *)callback {
    [USRVNotificationObserver removeObserver:name targetObject:nil];
    [callback invoke:nil];
}

+ (void)WebViewExposed_addAVNotificationObserver:(NSString *)name userInfoKeys:(NSArray *)keys callback:(USRVWebViewCallback *)callback {
    [USRVNotificationObserver addObserver:name userInfoKeys:keys targetObject:[AVAudioSession sharedInstance]];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeAVNotificationObserver:(NSString *)name callback:(USRVWebViewCallback *)callback {
    [USRVNotificationObserver removeObserver:name targetObject:[AVAudioSession sharedInstance]];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeAllNotificationObservers:(USRVWebViewCallback *)callback {
    [USRVNotificationObserver unregisterNotificationObserver];
    [callback invoke:nil];
}

@end
