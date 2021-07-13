#import "USRVWebViewAsyncOperation.h"
NS_ASSUME_NONNULL_BEGIN

@interface USRVWebViewAsyncOperationStorage : NSObject
@property (nonatomic) dispatch_queue_t operationQueue;
@property (nonatomic) dispatch_queue_t syncQueue;
@property (nonatomic) USRVWebViewAsyncOperationStatus status;
@property (nonatomic) NSString *statusCode;
@property (nonatomic) NSCondition *_Nullable lock;

+ (instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END
