#import "UADSNotificationObserver.h"
#import "UADSWebViewApp.h"
#import "UADSWebViewEventCategory.h"
#import "UADSNotificationEvent.h"

static NSMutableDictionary *notificationKeyDictionary;

@implementation UADSNotificationObserver

+ (void)addObserver:(NSString *)name userInfoKeys:(NSArray *)keys {
    [self removeObserver:name];
    if (!notificationKeyDictionary) {
        notificationKeyDictionary = [[NSMutableDictionary alloc]init];
    }
    [notificationKeyDictionary removeObjectForKey:name];
    if (keys) {
        [notificationKeyDictionary setObject:keys forKey:name];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nsNotificationReceived:) name:name object:nil];
}

+ (void)removeObserver:(NSString *)name {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
}

+ (void)unregisterNotificationObserver {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

+ (void)nsNotificationReceived:(NSNotification *)notification {
    NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc]init];

    if ([notification userInfo] && [notificationKeyDictionary objectForKey:notification.name]) {
        for (NSString *key in [notificationKeyDictionary objectForKey:notification.name]) {
            if ([[notification userInfo]objectForKey:key]) {
                [notificationInfo setObject:[[notification userInfo]objectForKey:key] forKey:key];
            }
        }
    }

    if ([UADSWebViewApp getCurrentApp]) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromNotificationEvent(kUnityAdsNotificatoinEventAction)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryNotification)
                                           param1:notification.name, notificationInfo, nil];
    }
}


@end
