#import "UADSNotificationEvent.h"

static NSString *notificationEventAction = @"ACTION";

NSString *NSStringFromNotificationEvent(UnityAdsNotificationEvent event) {
    switch (event) {
        case kUnityAdsNotificatoinEventAction:
            return notificationEventAction;
    }
}
