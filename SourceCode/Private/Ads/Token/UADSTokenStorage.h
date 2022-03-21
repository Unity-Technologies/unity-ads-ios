#import "UADSTokenStorageEventProtocol.h"
#import "UADSHeaderBiddingTokenReaderBase.h"
NS_ASSUME_NONNULL_BEGIN

@protocol UADSHeaderBiddingTokenCRUD <NSObject>
- (void)createTokens: (NSArray<NSString *> *)tokens;
- (void)appendTokens: (NSArray<NSString *> *)tokens;
- (NSString *)  getToken;
- (void)        deleteTokens;
- (void)setPeekMode: (BOOL)mode;
- (void)setInitToken: (nullable NSString *)token;

@end

@interface UADSTokenStorage : NSObject<UADSHeaderBiddingTokenCRUD>


+ (instancetype)sharedInstance;

- (instancetype)initWithEventHandler: (id<UADSTokenStorageEventProtocol>)eventHandler;
- (void)createTokens: (NSArray<NSString *> *)tokens;
- (void)appendTokens: (NSArray<NSString *> *)tokens;
- (NSString *)  getToken;
- (void)        deleteTokens;
- (void)setPeekMode: (BOOL)mode;
- (void)setInitToken: (nullable NSString *)token;
@end

NS_ASSUME_NONNULL_END
