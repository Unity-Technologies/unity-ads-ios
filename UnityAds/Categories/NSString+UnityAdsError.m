#import "NSString+UnityAdsError.h"

@implementation NSString (UnityAdsError)

- (UnityAdsError)unityAdsErrorFromString {
    NSDictionary <NSString*,NSNumber*> *errors = @{
                                                   @"NOT_INITIALIZED": @(kUnityAdsErrorNotInitialized),
                                                   @"INITIALIZE_FAILED": @(kUnityAdsErrorInitializedFailed),
                                                   @"INVALID_ARGUMENT": @(kUnityAdsErrorInvalidArgument),
                                                   @"VIDEO_PLAYER_ERROR": @(kUnityAdsErrorVideoPlayerError),
                                                   @"INIT_SANITY_CHECK_FAIL": @(kUnityAdsErrorInitSanityCheckFail),
                                                   @"AD_BLOCKER_DETECTED": @(kUnityAdsErrorAdBlockerDetected),
                                                   @"FILE_IO_ERROR": @(kUnityAdsErrorFileIoError),
                                                   @"DEVICE_ID_ERROR": @(kUnityAdsErrorDeviceIdError),
                                                   @"SHOW_ERROR": @(kUnityAdsErrorShowError),
                                                   @"INTERNAL_ERROR": @(kUnityAdsErrorInternalError),
                                                   };
    return errors[self].integerValue;
}
@end
