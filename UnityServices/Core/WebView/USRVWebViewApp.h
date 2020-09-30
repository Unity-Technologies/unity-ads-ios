#import <UIKit/UIKit.h>
#import "USRVConfiguration.h"
#import "USRVInvocation.h"
#import "USRVWebViewBackgroundView.h"
#import "USRVNativeCallback.h"

@interface USRVWebViewApp : NSObject

@property (nonatomic, assign) BOOL webAppLoaded;
@property (nonatomic, strong) NSString* webAppFailureMessage;
@property (nonatomic, assign) NSNumber* webAppFailureCode;
@property (nonatomic, strong) UIView *webView;
@property (nonatomic, strong) USRVWebViewBackgroundView *backgroundView;
@property (nonatomic, strong) USRVConfiguration *configuration;
@property (nonatomic, strong) NSMutableDictionary *nativeCallbacks;

+ (USRVWebViewApp *)getCurrentApp;
+ (void)setCurrentApp:(USRVWebViewApp *)webViewApp;
+ (BOOL)create:(USRVConfiguration *)configuration view:(UIView*)view;
- (void)completeWebViewAppInitialization:(BOOL)initialized;
- (void)resetWebViewAppInitialization;
- (BOOL)isWebAppInitialized;
- (void)setWebAppFailureMessage:(NSString *)message;
- (void)setWebAppFailureCode:(NSNumber *) code;
- (NSString *)getWebAppFailureMessage;
- (NSNumber *)getWebAppFailureCode;

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration;
- (BOOL)invokeCallback:(USRVInvocation *)invocation;
- (BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className receiverClass:(NSString *)receiverClass callback:(NSString *)callback params:(NSArray *)params;
- (BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className context:(NSString *)context callback:(USRVNativeCallbackBlock)callback params:(NSArray *)params;
- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category params:(NSArray *)params;
- (void)addCallback:(USRVNativeCallback *)callback;
- (void)removeCallback:(USRVNativeCallback *)callback;
- (USRVNativeCallback *)getCallbackWithId:(NSString *)callbackId;
- (void)invokeJavascriptString:(NSString *)javaScriptString;
- (void)placeWebViewToBackgroundView;
- (void)createBackgroundView;
@end
