#import "UADSApiNotification.h"
#import "UADSWebViewCallback.h"
#import "UADSNotificationObserver.h"

@implementation UADSApiNotification

+ (void)WebViewExposed_addNotificationObserver:(NSString *)name userInfoKeys:(NSArray *)keys callback:(UADSWebViewCallback *)callback {
    [UADSNotificationObserver addObserver:name userInfoKeys:keys];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeNotificationObserver:(NSString *)name callback:(UADSWebViewCallback *)callback {
    [UADSNotificationObserver removeObserver:name];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeAllNotificationObservers:(UADSWebViewCallback *)callback {
    [UADSNotificationObserver unregisterNotificationObserver];
    [callback invoke:nil];
}

@end
