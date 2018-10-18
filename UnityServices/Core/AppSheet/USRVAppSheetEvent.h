#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityServicesAppSheetEvent) {
    kAppSheetPrepared,
    kAppSheetOpened,
    kAppSheetClosed,
    kAppSheetFailed,    
};

NSString *NSStringFromAppSheetEvent(UnityServicesAppSheetEvent);
