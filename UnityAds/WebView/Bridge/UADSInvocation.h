#import "UADSWebViewCallback.h"

@interface UADSInvocation : NSObject

@property (nonatomic, retain) NSMutableArray<NSInvocation*> *invocations;
@property (nonatomic, retain) NSMutableArray<NSArray*> *responses;
@property (nonatomic, assign) int invocationId;

- (void)addInvocation:(NSString *)className methodName:(NSString *)methodName parameters:(NSArray *)parameters callback:(UADSWebViewCallback *)callback;
- (BOOL)nextInvocation;
- (void)setInvocationResponseWithStatus:(NSString *)status error:(NSString *)error params:(NSArray *)params;
- (void)sendInvocationCallback;

+ (UADSInvocation *)getInvocationWithId:(int)invocationId;
+ (void)setClassTable:(NSArray<NSString*> *)allowedClasses;

@end