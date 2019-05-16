#import <UIKit/UIKit.h>
#import "USRVConfiguration.h"
#import "USRVInvocation.h"
#import "USRVNativeCallback.h"
#import "USRVWebViewBackgroundView.h"

@interface USRVWebViewApp : NSObject

@property (nonatomic, assign) BOOL webAppLoaded;
@property (nonatomic, assign) BOOL webAppInitialized;
@property (nonatomic, strong) UIView *webView;
@property (nonatomic, strong) USRVWebViewBackgroundView *backgroundView;
@property (nonatomic, strong) USRVConfiguration *configuration;
@property (nonatomic, strong) NSMutableDictionary *nativeCallbacks;

+ (USRVWebViewApp *)getCurrentApp;
+ (void)setCurrentApp:(USRVWebViewApp *)webViewApp;
+ (void)create:(USRVConfiguration *)configuration;

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration;
- (BOOL)invokeCallback:(USRVInvocation *)invocation;
- (BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className receiverClass:(NSString *)receiverClass callback:(NSString *)callback params:(NSArray *)params;
- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category params:(NSArray *)params;
- (void)addCallback:(USRVNativeCallback *)callback;
- (void)removeCallback:(USRVNativeCallback *)callback;
- (USRVNativeCallback *)getCallbackWithId:(NSString *)callbackId;
- (void)invokeJavascriptString:(NSString *)javaScriptString;
- (void)placeWebViewToBackgroundView;
- (void)createBackgroundView;
@end
