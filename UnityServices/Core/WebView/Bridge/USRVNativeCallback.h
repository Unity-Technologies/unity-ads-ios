

@interface USRVNativeCallback : NSObject

@property (nonatomic, strong) NSString *callback;
@property (nonatomic, strong) NSString *callbackId;
@property (nonatomic, strong) NSString *receiverClass;

- (instancetype)initWithCallback:(NSString *)callback receiverClass:(NSString *)receiverClass;
- (void)invokeWithStatus:(NSString *)status params:(NSArray *)params;

@end
