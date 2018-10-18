#import "USRVNotificationObserver.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"
#import "USRVNotificationEvent.h"

static NSMutableDictionary *notificationKeyDictionary;

@implementation USRVNotificationObserver

+ (void)addObserver:(NSString *)name userInfoKeys:(NSArray *)keys targetObject:(id)targetObject {
    [self removeObserver:name targetObject:nil];
    if (!notificationKeyDictionary) {
        notificationKeyDictionary = [[NSMutableDictionary alloc]init];
    }
    [notificationKeyDictionary removeObjectForKey:name];
    if (keys) {
        [notificationKeyDictionary setObject:keys forKey:name];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nsNotificationReceived:) name:name object:targetObject];
}

+ (void)removeObserver:(NSString *)name targetObject:(id)targetObject {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:targetObject];
}

+ (void)unregisterNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

    if ([USRVWebViewApp getCurrentApp]) {
        [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromNotificationEvent(kUnityServicesNotificatoinEventAction)
                                         category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryNotification)
                                           param1:notification.name, notificationInfo, nil];
    }
}


@end
