#import <Foundation/Foundation.h>
#import "UADSErrorState.h"

NSString * uads_errorStateString(UADSErrorState state) {
    switch (state) {
        case kUADSErrorStateInvalidHash:
            return @"invalid_hash";

        case kUADSErrorStateCreateWebview:
            return @"create_webview";

        case kUADSErrorStateNetworkConfigRequest:
            return @"network_config";

        case kUADSErrorStateNetworkWebviewRequest:
            return @"network_webview";

        case kUADSErrorStateMalformedWebviewRequest:
            return @"malformed_webview";

        case kUADSErrorStateCreateWebviewTimeout:
            return @"create_webview_timeout";

        case kUADSErrorStateCreateWebviewGameIdDisabled:
            return @"create_webview_game_id_disabled";

        case kUADSErrorStateCreateWebviewConfigError:
            return @"create_webview_config_error";

        case kUADSErrorStateCreateWebviewInvalidArgument:
            return @"create_webview_invalid_arg";
    }
    return nil;
}

BOOL uads_isWebViewErrorState(UADSErrorState state) {
    switch (state) {
        case kUADSErrorStateCreateWebview:
        case kUADSErrorStateCreateWebviewGameIdDisabled:
        case kUADSErrorStateCreateWebviewConfigError:
        case kUADSErrorStateCreateWebviewInvalidArgument:
            return true;

        default:
            return false;
    }
}

const int kPrivacyGameIdDisabledCode = 423;
