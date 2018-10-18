#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityServicesAppSheetError) {
    kUnityServicesAppSheetErrorAlreadyPreparing,
    kUnityServicesAppSheetErrorAlreadyPresenting,
    kUnityServicesAppSheetErrorNotFound,
    kUnityServicesAppSheetErrorNoAppSheetFound,
    kUnityServicesAppSheetErrorTimeout
    
};

NSString *NSStringFromAppSheetError(UnityServicesAppSheetError);
