#import <UIKit/UIKit.h>
#import "UADSConfiguration.h"
#import "UADSInvocation.h"
#import "UADSNativeCallback.h"

@interface UADSWebViewApp : NSObject

@property (nonatomic, assign) BOOL webAppLoaded;
@property (nonatomic, assign) BOOL webAppInitialized;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UADSConfiguration *configuration;
@property (nonatomic, strong) NSMutableDictionary *nativeCallbacks;

+ (UADSWebViewApp *)getCurrentApp;
+ (void)setCurrentApp:(UADSWebViewApp *)webViewApp;
+ (void)create:(UADSConfiguration *)configuration;

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration;
- (BOOL)invokeCallback:(UADSInvocation *)invocation;
- (BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className receiverClass:(NSString *)receiverClass callback:(NSString *)callback params:(NSArray *)params;
- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ...;
- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category params:(NSArray *)params;
- (void)addCallback:(UADSNativeCallback *)callback;
- (void)removeCallback:(UADSNativeCallback *)callback;
- (UADSNativeCallback *)getCallbackWithId:(NSString *)callbackId;

@end