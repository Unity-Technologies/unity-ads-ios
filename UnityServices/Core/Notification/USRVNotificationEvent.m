#import "USRVNotificationEvent.h"

static NSString *notificationEventAction = @"ACTION";

NSString *NSStringFromNotificationEvent(UnityServicesNotificationEvent event) {
    switch (event) {
        case kUnityServicesNotificatoinEventAction:
            return notificationEventAction;
    }
}
