

@interface USRVWebViewMethodInvokeOperation : NSOperation

@property (nonatomic, strong) NSString *webViewMethod;
@property (nonatomic, strong) NSString *webViewClass;
@property (nonatomic, strong) NSArray *parameters;
@property (nonatomic, assign) int waitTime;
@property (nonatomic, assign) BOOL success;

- (instancetype)initWithMethod:(NSString *)webViewMethod webViewClass:(NSString *)webViewClass parameters:(NSArray *)parameters waitTime:(int)waitTime;
+ (void)callback:(NSArray *)params;
@end
