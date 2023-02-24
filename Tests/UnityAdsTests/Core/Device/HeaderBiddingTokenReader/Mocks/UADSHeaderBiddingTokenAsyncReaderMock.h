#import <Foundation/Foundation.h>
#import "UADSHeaderBiddingTokenReaderBase.h"
#import "UADSTokenStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenAsyncReaderMock : NSObject<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>
@property (nonatomic, assign) NSInteger getTokenCount;
@property (nonatomic, assign) NSInteger getTokenSyncCount;
@property (nonatomic, assign) NSInteger setInitTokenCount;
@property (nonatomic, assign) NSInteger createTokenCount;
@property (nonatomic, assign) NSInteger deleteTokenCount;
@property (nonatomic, assign) NSInteger appendTokenCount;
@property (nonatomic, assign) NSInteger setPeekModeCount;
@property (nonatomic, strong) NSString *expectedToken;
@property (nonatomic, assign) BOOL shoudSkipCompletion;
@property (nonatomic, assign) UADSTokenType tokenType;
@property (nonatomic, assign) NSMutableDictionary* info;
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader> original;
-(void)triggerGetTokenCompletion;
@end

NS_ASSUME_NONNULL_END
