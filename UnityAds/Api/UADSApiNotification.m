#import "UADSApiNotification.h"
#import "UADSWebViewCallback.h"
#import "UADSNotificationObserver.h"
#import <AVFoundation/AVFoundation.h>

@implementation UADSApiNotification

+ (void)WebViewExposed_addNotificationObserver:(NSString *)name userInfoKeys:(NSArray *)keys callback:(UADSWebViewCallback *)callback {
    [UADSNotificationObserver addObserver:name userInfoKeys:keys targetObject:nil];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeNotificationObserver:(NSString *)name callback:(UADSWebViewCallback *)callback {
    [UADSNotificationObserver removeObserver:name targetObject:nil];
    [callback invoke:nil];
}

+ (void)WebViewExposed_addAVNotificationObserver:(NSString *)name userInfoKeys:(NSArray *)keys callback:(UADSWebViewCallback *)callback {
    [UADSNotificationObserver addObserver:name userInfoKeys:keys targetObject:[AVAudioSession sharedInstance]];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeAVNotificationObserver:(NSString *)name callback:(UADSWebViewCallback *)callback {
    [UADSNotificationObserver removeObserver:name targetObject:[AVAudioSession sharedInstance]];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeAllNotificationObservers:(UADSWebViewCallback *)callback {
    [UADSNotificationObserver unregisterNotificationObserver];
    [callback invoke:nil];
}

@end
