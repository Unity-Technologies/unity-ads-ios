#import "USRVWebViewEventCategory.h"

static NSString * const eventCategoryAdunit = @"ADUNIT";
static NSString * const eventCategoryCache = @"CACHE";
static NSString * const eventCategoryConnectivity = @"CONNECTIVITY";
static NSString * const eventCategoryResolve = @"RESOLVE";
static NSString * const eventCategoryStorage = @"STORAGE";
static NSString * const eventCategoryUrl = @"URL";
static NSString * const eventCategoryVideoPlayer = @"VIDEOPLAYER";
static NSString * const eventCategoryWebViewApp = @"WEBVIEWAPP";
static NSString * const eventCategoryNotification = @"NOTIFICATION";
static NSString * const eventCategoryAppSheet = @"APPSHEET";
static NSString * const eventCategoryDeviceInfo = @"DEVICEINFO";
static NSString * const eventCategoryWebPlayer = @"WEBPLAYER";
static NSString * const eventCategoryBanner = @"BANNER";
static NSString * const eventCategoryPermissions = @"PERMISSIONS";
static NSString * const eventCategoryAR = @"AR";
static NSString * const eventCategoryNativeError = @"NATIVE_ERROR";
static NSString * const eventCategoryWebAuthSession = @"WEB_AUTH_SESSION";
static NSString * const eventCategoryLoadApi = @"LOAD_API";

NSString *USRVNSStringFromWebViewEventCategory(UnityServicesWebViewEventCategory category) {
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
        case kUnityServicesWebViewEventCategoryNativeError:
            return eventCategoryNativeError;
        case kUnityServicesWebViewEventCategoryWebAuthSession:
            return eventCategoryWebAuthSession;
        case kUnityServicesWebViewEventCategoryLoadApi:
            return eventCategoryLoadApi;
    }
}
