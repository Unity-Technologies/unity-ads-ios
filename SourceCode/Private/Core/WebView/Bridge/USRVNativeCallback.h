
typedef NS_ENUM (NSInteger, USRVNativeCallbackStatus) {
    USRVNativeCallbackStatusOk,
    USRVNativeCallbackStatusError
};

USRVNativeCallbackStatus USRVNativeCallbackStatusFromNSString(NSString *stringStatus);
NSString * NSStringFromUSRVNativeCallbackStatus(USRVNativeCallbackStatus status);

typedef void (^USRVNativeCallbackBlock)(USRVNativeCallbackStatus status, NSArray *params);

@interface USRVNativeCallback : NSObject

@property (nonatomic, strong) USRVNativeCallbackBlock callback;
@property (nonatomic, strong) NSString *callbackId;

- (instancetype)initWithCallback: (USRVNativeCallbackBlock)callback context: (NSString *)context;
- (instancetype)initWithMethod: (NSString *)method receiverClass: (NSString *)receiverClass;
- (void)invokeWithStatus: (NSString *)status params: (NSArray *)params;

@end
