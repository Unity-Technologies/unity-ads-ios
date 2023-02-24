#import "UADSHeaderBiddingTokenReaderWithSCARSignalsHybridStrategy.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy+Internal.h"

@implementation UADSHeaderBiddingTokenReaderWithSCARSignalsHybridStrategy {
    dispatch_queue_t queue;
}

- (instancetype)init {
    SUPER_INIT;
    queue = dispatch_queue_create("com.unity3d.scarhbhybrid.module", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (void)getToken:(UADSHeaderBiddingTokenCompletion)completion {
    __block UADSSCARSignals *_Nullable blockSignals;
    __block UADSHeaderBiddingToken *_Nullable blockToken;
    
    dispatch_group_t group = dispatch_group_create();
    //To avoid returning too quickly
    dispatch_group_enter(group);
    dispatch_group_enter(group);
    
    dispatch_group_notify(group, queue, ^{
        if (blockToken) {
            [self.scarSignalSender sendSCARSignalsWithUUIDString:blockToken.uuidString signals:blockSignals];
        }
    });
    
    
    id signalCompletion = ^(UADSSCARSignals *_Nullable signals) {
        blockSignals = signals;
        dispatch_group_leave(group);
    };
    
    [self.scarSignalReader requestSCARSignalsWithCompletion:signalCompletion];
    
    UADSHeaderBiddingTokenCompletion injectedCompletion = ^(UADSHeaderBiddingToken *_Nullable token) {
        token = [self setUUIDString:token.uuidString ifRemoteToken:token];
        if (token.isValid) {
            blockToken = token;
        }
        dispatch_group_leave(group);
        completion(token);
    };
    
    [super getToken:injectedCompletion];
}

@end
