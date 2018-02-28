#import "UADSWebViewEventCategory.h"

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

NSString *NSStringFromWebViewEventCategory(UnityAdsWebViewEventCategory category) {
    switch (category) {
        case kUnityAdsWebViewEventCategoryAdunit:
            return eventCategoryAdunit;
        case kUnityAdsWebViewEventCategoryCache:
            return eventCategoryCache;
        case kUnityAdsWebViewEventCategoryConnectivity:
            return eventCategoryConnectivity;
        case kUnityAdsWebViewEventCategoryResolve:
            return eventCategoryResolve;
        case kUnityAdsWebViewEventCategoryStorage:
            return eventCategoryStorage;
        case kUnityAdsWebViewEventCategoryUrl:
            return eventCategoryUrl;
        case kUnityAdsWebViewEventCategoryVideoPlayer:
            return eventCategoryVideoPlayer;
        case kUnityAdsWebViewEventCategoryWebViewApp:
            return eventCategoryWebViewApp;
        case kUnityAdsWebViewEventCategoryNotification:
            return eventCategoryNotification;
        case kUnityAdsWebViewEventCategoryAppSheet:
            return eventCategoryAppSheet;
        case kUnityAdsWebViewEventCategoryDeviceInfo:
            return eventCategoryDeviceInfo;
        case kUnityAdsWebViewEventCategoryWebPlayer:
            return eventCategoryWebPlayer;
            
    }
}
