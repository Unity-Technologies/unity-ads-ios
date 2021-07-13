#import "UADSTokenStorageEventProtocol.h"

@interface UADSTokenStorage : NSObject

+ (instancetype)sharedInstance;

- (instancetype)initWithEventHandler: (id<UADSTokenStorageEventProtocol>)eventHandler;

- (void)createTokens: (NSArray<NSString *> *)tokens;
- (void)appendTokens: (NSArray<NSString *> *)tokens;
- (NSString *)  getToken;
- (void)        deleteTokens;
- (void)setPeekMode: (BOOL)mode;

@end
