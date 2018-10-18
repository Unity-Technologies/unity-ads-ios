#import "USRVWebViewApp.h"

@interface USRVWKWebViewUtilities : NSObject
+(id)initWebView:(const char *)className frame:(CGRect)frame configuration:(id)configuration;

+(void)loadUrl:(id)webView url:(NSURLRequest *)url;

+(BOOL)loadFileUrl:(id)webView url:(NSURL *)url allowReadAccess:(NSURL *)allowReadAccess;

+(BOOL)loadData:(id)webView data:(NSData *)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding baseUrl:(NSURL *)baseUrl;

+(void)evaluateJavaScript:(id)webView string:(NSString *)string;

+(id)getObjectFromClass:(const char *)className;

+(id)addUserContentControllerMessageHandlers:(id)wkConfiguration delegate:(id)delegate handledMessages:(NSArray *)handledMessages;

+(void)removeUserContentControllerMessageHandler:(id)wkConfiguration handledMessages:(NSArray<NSString *> *)handledMessages;

+(BOOL)isFrameworkPresent;
@end
