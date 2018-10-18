#import "USRVWebViewEventCategory.h"

static NSString * eventCategoryAdunit = @"ADUNIT";
static NSString * eventCategoryCache = @"CACHE";
static NSString * eventCategoryConnectivity = @"CONNECTIVITY";
static NSString * eventCategoryResolve = @"RESOLVE";
static NSString * eventCategoryStorage = @"STORAGE";
static NSString * eventCategoryUrl = @"URL";
static NSString * eventCategoryVideoPlayer = @"VIDEOPLAYER";
static NSString * eventCategoryWebViewApp = @"WEBVIEWAPP";
static NSString * eventCategoryNotification = @"NOTIFICATION";
static NSString * eventCategoryAppSheet = @"APPSHEET";
static NSString * eventCategoryDeviceInfo = @"DEVICEINFO";
static NSString * eventCategoryWebPlayer = @"WEBPLAYER";
static NSString * eventCategoryBanner = @"BANNER";
static NSString * eventCategoryPermissions = @"PERMISSIONS";
static NSString * eventCategoryAR = @"AR";

NSString *NSStringFromWebViewEventCategory(UnityServicesWebViewEventCategory category) {
    switch (category) {
        case kUnityServicesWebViewEventCategoryAdunit:
            return eventCategoryAdunit;
        case kUnityServicesWebViewEventCategoryCache:
            return eventCategoryCache;
        case kUnityServicesWebViewEventCategoryConnectivity:
            return eventCategoryConnectivity;
        case kUnityServicesWebViewEventCategoryResolve:
            return eventCategoryResolve;
        case kUnityServicesWebViewEventCategoryStorage:
            return eventCategoryStorage;
        case kUnityServicesWebViewEventCategoryUrl:
            return eventCategoryUrl;
        case kUnityServicesWebViewEventCategoryVideoPlayer:
            return eventCategoryVideoPlayer;
        case kUnityServicesWebViewEventCategoryWebViewApp:
            return eventCategoryWebViewApp;
        case kUnityServicesWebViewEventCategoryNotification:
            return eventCategoryNotification;
        case kUnityServicesWebViewEventCategoryAppSheet:
            return eventCategoryAppSheet;
        case kUnityServicesWebViewEventCategoryDeviceInfo:
            return eventCategoryDeviceInfo;
        case kUnityServicesWebViewEventCategoryWebPlayer:
            return eventCategoryWebPlayer;
        case kUnityServicesWebViewEventCategoryBanner:
            return eventCategoryBanner;
        case kUnityServicesWebViewEventCategoryPermissions:
            return eventCategoryPermissions;
        case kUnityServicesWebViewEventCategoryAR:
            return eventCategoryAR;
    }
}
