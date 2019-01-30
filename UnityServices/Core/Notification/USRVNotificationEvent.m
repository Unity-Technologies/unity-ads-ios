#import "USRVNotificationEvent.h"

static NSString *notificationEventAction = @"ACTION";

NSString *USRVNSStringFromNotificationEvent(UnityServicesNotificationEvent event) {
    switch (event) {
        case kUnityServicesNotificatoinEventAction:
            return notificationEventAction;
    }
}
