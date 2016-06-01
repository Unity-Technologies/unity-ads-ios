#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsAppSheetEvent) {
    kAppSheetPrepared,
    kAppSheetOpened,
    kAppSheetClosed,
    kAppSheetFailed,    
};

NSString *NSStringFromAppSheetEvent(UnityAdsAppSheetEvent);
