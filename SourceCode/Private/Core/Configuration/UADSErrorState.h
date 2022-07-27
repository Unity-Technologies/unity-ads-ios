
typedef NS_ENUM (NSInteger, UADSErrorState) {
    kUADSErrorStateNetworkConfigRequest,
    kUADSErrorStateNetworkWebviewRequest,
    kUADSErrorStateInvalidHash,
    kUADSErrorStateCreateWebview,
    kUADSErrorStateCreateWebviewTimeout,
    kUADSErrorStateCreateWebviewGameIdDisabled,
    kUADSErrorStateCreateWebviewConfigError,
    kUADSErrorStateCreateWebviewInvalidArgument,
    kUADSErrorStateMalformedWebviewRequest
};

NSString * uads_errorStateString(UADSErrorState state);
BOOL uads_isWebViewErrorState(UADSErrorState state);
