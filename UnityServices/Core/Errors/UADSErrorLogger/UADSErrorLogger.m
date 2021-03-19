#import "UADSErrorLogger.h"
#import "USRVSDKMetrics.h"

static NSString * const kUADSShowModuleInvocationTimeoutString = @"native_show_callback_timeout";
static NSString * const kUADSShowModuleInvocationErrorString = @"native_show_callback_error";
static NSString * const kUADSShowModuleTimeoutString = @"native_show_timeout_error";

static NSString * const kUADSLoadModuleInvocationTimeoutString = @"native_load_callback_timeout";
static NSString * const kUADSLoadModuleInvocationErrorString = @"native_load_callback_error";
static NSString * const kUADSLoadModuleTimeoutString = @"native_load_timeout_error";

@interface UADSErrorLogger()
@property (nonatomic) UADSErrorHandlerType moduleType;
@end

@implementation UADSErrorLogger

+ (instancetype)newWithType:(UADSErrorHandlerType)type {
    UADSErrorLogger *logger = [self new];
    logger.moduleType = type;
    return logger;
}

- (void)catchError:(UADSInternalError *)error {
    NSString *metricString = [self loadErrorMessage: error] ?: [self showErrorMessage: error] ?: error.errorMessage;
    [[USRVSDKMetrics getInstance] sendEventWithTags: metricString tags: error.errorInfo];
}


- (NSString *)loadErrorMessage: (UADSInternalError *)error {
    if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode ==  kUADSInternalErrorWebViewInternal) {
        return kUADSLoadModuleInvocationErrorString;
    }
    
    if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode ==  kUADSInternalErrorWebViewTimeout) {
        return kUADSLoadModuleInvocationTimeoutString;
    }
    
    if (error.errorCode == kUADSInternalErrorAbstractModule && error.reasonCode ==  kUADSInternalErrorAbstractModuleTimeout) {
        return kUADSLoadModuleTimeoutString;
    }
    
    return nil;
};

- (NSString *)showErrorMessage: (UADSInternalError *)error {
    if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode ==  kUADSInternalErrorWebViewInternal) {
        return kUADSShowModuleInvocationErrorString;
    }
    
    if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode ==  kUADSInternalErrorWebViewTimeout) {
        return kUADSShowModuleInvocationTimeoutString;
    }
    
    if (error.errorCode == kUADSInternalErrorAbstractModule && error.reasonCode ==  kUADSInternalErrorAbstractModuleTimeout) {
        return kUADSShowModuleTimeoutString;
    }
    
    return nil;
};


@end