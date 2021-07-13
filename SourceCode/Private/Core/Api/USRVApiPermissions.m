#import "USRVApiPermissions.h"
#import "USRVWebViewCallback.h"
#import <AVFoundation/AVFoundation.h>
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"

@implementation USRVApiPermissions

+ (void)WebViewExposed_checkPermission: (NSString *)permission webViewCallback: (USRVWebViewCallback *)callback {
    if (permission && permission.length > 0) {
        NSString *mediaType;

        if ([permission isEqualToString: AVMediaTypeVideo] || [permission isEqualToString: AVMediaTypeAudio]) {
            mediaType = permission;
        } else {
            [callback error: @"INVALID_PERMISSION"
                       arg1: permission, nil];
            return;
        }

        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType: mediaType];
        [callback invoke: [NSNumber numberWithInteger: status], nil];
    } else {
        [callback error: @"NO_REQUESTED_PERMISSION"
                   arg1: nil];
    }
}

+ (void)WebViewExposed_requestPermission: (NSString *)permission webViewCallback: (USRVWebViewCallback *)callback {
    if (permission && permission.length > 0) {
        NSString *mediaType;

        if ([permission isEqualToString: AVMediaTypeVideo] || [permission isEqualToString: AVMediaTypeAudio]) {
            mediaType = permission;
        } else {
            [callback error: @"INVALID_PERMISSION"
                       arg1: permission, nil];
            return;
        }

        [AVCaptureDevice requestAccessForMediaType: mediaType
                                 completionHandler: ^(BOOL granted) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                        if ([USRVWebViewApp getCurrentApp]) {
                                                            [[USRVWebViewApp getCurrentApp] sendEvent: @"PERMISSIONS_RESULT"
                                                                                             category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryPermissions)
                                                                                               param1: permission, [NSNumber numberWithBool: granted],
                                                             nil];
                                                        }
                                                    });
                                 }];

        [callback invoke: nil];
    } else {
        [callback error: @"NO_REQUESTED_PERMISSION"
                   arg1: nil];
    }
} /* WebViewExposed_requestPermission */

@end
