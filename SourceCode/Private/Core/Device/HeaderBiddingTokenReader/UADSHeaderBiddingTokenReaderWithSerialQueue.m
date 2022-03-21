#import "UADSHeaderBiddingTokenReaderWithSerialQueue.h"
#import "UADSInitializationStatusReader.h"

@interface UADSHeaderBiddingTokenReaderWithSerialQueue ()
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> original;
@property (nonatomic, strong) id<UADSInitializationStatusReader> statusReader;
@property (nonatomic) dispatch_queue_t serialQueue;
@end

@implementation UADSHeaderBiddingTokenReaderWithSerialQueue

+ (instancetype)newWithOriginalReader: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original
                      andStatusReader: (id<UADSInitializationStatusReader>)statusReader {
    UADSHeaderBiddingTokenReaderWithSerialQueue *decorator = [self new];

    decorator.statusReader = statusReader;
    decorator.original = original;
    decorator.serialQueue = dispatch_queue_create("com.unity3d.ads.async.token.reader", DISPATCH_QUEUE_SERIAL);
    return decorator;
}

- (void)getToken: (nonnull UADSHeaderBiddingTokenCompletion)completion {
    dispatch_async(_serialQueue, ^{
        [self getTokenIfAllowed: completion];
    });
}

- (void)getTokenIfAllowed: (nonnull UADSHeaderBiddingTokenCompletion)completion {
    switch (_statusReader.currentState) {
        case INITIALIZING:
        case INITIALIZED_SUCCESSFULLY:
            [_original getToken: completion];
            break;

        case INITIALIZED_FAILED:
        case NOT_INITIALIZED:
            completion(nil, kUADSTokenRemote);
            break;
    }
}

- (void)appendTokens: (nonnull NSArray<NSString *> *)tokens {
    dispatch_async(_serialQueue, ^{
        [self.original appendTokens: tokens];
    });
}

- (void)createTokens: (nonnull NSArray<NSString *> *)tokens {
    dispatch_async(_serialQueue, ^{
        [self.original createTokens: tokens];
    });
}

- (void)deleteTokens {
    dispatch_async(_serialQueue, ^{
        [self.original deleteTokens];
    });
}

- (nonnull NSString *)getToken {
    return [self.original getToken];
}

- (void)setInitToken: (nullable NSString *)token {
    dispatch_async(_serialQueue, ^{
        [self.original setInitToken: token];
    });
}

- (void)setPeekMode: (BOOL)mode {
    dispatch_async(_serialQueue, ^{
        [self.original setPeekMode: mode];
    });
}

@end
