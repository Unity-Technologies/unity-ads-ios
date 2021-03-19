#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityServicesAppSheetError) {
    kUnityServicesAppSheetErrorAlreadyPreparing,
    kUnityServicesAppSheetErrorAlreadyPresenting,
    kUnityServicesAppSheetErrorNotFound,
    kUnityServicesAppSheetErrorNoAppSheetFound,
    kUnityServicesAppSheetErrorNoRootViewControllerFound,
    kUnityServicesAppSheetErrorTimeout
    
};

NSString *USRVNSStringFromAppSheetError(UnityServicesAppSheetError);
