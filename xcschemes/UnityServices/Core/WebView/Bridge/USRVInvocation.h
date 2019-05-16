#import "USRVWebViewCallback.h"

@interface USRVInvocation : NSObject

@property (nonatomic, strong) NSMutableArray<NSInvocation*> *invocations;
@property (nonatomic, strong) NSMutableArray<NSArray*> *responses;
@property (nonatomic, assign) int invocationId;

- (void)addInvocation:(NSString *)className methodName:(NSString *)methodName parameters:(NSArray *)parameters callback:(USRVWebViewCallback *)callback;
- (BOOL)nextInvocation;
- (void)setInvocationResponseWithStatus:(NSString *)status error:(NSString *)error params:(NSArray *)params;
- (void)sendInvocationCallback;

+ (USRVInvocation *)getInvocationWithId:(int)invocationId;
+ (void)setClassTable:(NSArray<NSString*> *)allowedClasses;

@end
