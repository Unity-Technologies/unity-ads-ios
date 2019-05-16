

@interface USRVWebViewCallback : NSObject

@property (nonatomic, assign) NSString *callbackId;
@property (nonatomic, assign) int invocationId;
@property (nonatomic, assign) BOOL invoked;

- (instancetype)initWithCallbackId:(NSString *)callbackId invocationId:(int)invocationId;
- (void)invoke:(id)arg1, ...;
- (void)error:(NSString *)error arg1:(id)arg1, ...;
@end
