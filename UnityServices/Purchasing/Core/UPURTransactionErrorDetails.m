
#import "UPURTransactionErrorDetails.h"

@interface UPURTransactionErrorDetails ()
@property(nonatomic) UPURTransactionError transactionError;
@property(strong, nonatomic) NSString *exceptionMessage;
@property(nonatomic) UPURStore store;
@property(strong, nonatomic) NSString *storeSpecificErrorCode;
@property(strong, nonatomic) NSDictionary *extras;
@end

@implementation UPURTransactionErrorDetails

-(instancetype)initWithBuilder:(UPURTransactionErrorDetailsBuilder *)builder {
    if (self = [super init]) {
        self.transactionError = builder.transactionError;
        self.exceptionMessage = builder.exceptionMessage;
        self.store = builder.store;
        self.storeSpecificErrorCode = builder.storeSpecificErrorCode;
        self.extras = [builder.extras mutableCopy];
    }
    return self;
}

+(instancetype)build:(void (^)(UPURTransactionErrorDetailsBuilder *))buildBlock {
    UPURTransactionErrorDetailsBuilder *builder = [[UPURTransactionErrorDetailsBuilder alloc] init];
    buildBlock(builder);
    return [[UPURTransactionErrorDetails alloc] initWithBuilder:builder];
}

@end

@implementation UPURTransactionErrorDetailsBuilder
-(instancetype)init {
    if (self = [super init]) {
        self.transactionError = kUPURTransactionErrorUnknownError;
        self.store = kUPURStoreNotSpecified;
        self.extras = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)putExtra:(NSString *)key value:(NSObject *)value {
    [self.extras setObject:value forKey: key];
}
@end
